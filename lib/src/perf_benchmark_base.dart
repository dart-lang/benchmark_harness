// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'benchmark_base.dart';
import 'score_emitter.dart';

class PerfBenchmarkBase extends BenchmarkBase {
  PerfBenchmarkBase(super.name, {super.emitter = const PrintEmitter()});

  late final Directory fifoDir;
  late final String perfControlFifo;
  late final RandomAccessFile openedFifo;
  late final String perfControlAck;
  late final RandomAccessFile openedAck;
  late final Process perfProcess;

  Future<void> _createFifos() async {
    fifoDir = await Directory.systemTemp.createTemp('fifo');
    perfControlFifo = '${fifoDir.path}/perf_control_fifo';
    perfControlAck = '${fifoDir.path}/perf_control_ack';

    try {
      final fifoResult = await Process.run('mkfifo', [perfControlFifo]);
      if (fifoResult.exitCode != 0) {
        throw ProcessException('mkfifo', [perfControlFifo],
            'Cannot create fifo: ${fifoResult.stderr}', fifoResult.exitCode);
      }
      final ackResult = await Process.run('mkfifo', [perfControlAck]);
      if (ackResult.exitCode != 0) {
        throw ProcessException('mkfifo', [perfControlAck],
            'Cannot create fifo: ${ackResult.stderr}', ackResult.exitCode);
      }
    } catch (e) {
      await fifoDir.delete(recursive: true);
      rethrow;
    }
  }

  Future<void> _startPerfStat() async {
    await _createFifos();
    try {
      perfProcess = await Process.start('perf', [
        'stat',
        '--delay',
        '-1',
        '--control',
        'fifo:$perfControlFifo,$perfControlAck',
        '-j',
        '-p',
        '$pid'
      ]);
      //await Future<void>.delayed(const Duration(seconds: 2));

      openedFifo = File(perfControlFifo).openSync(mode: FileMode.writeOnly);

      openedAck = File(perfControlAck).openSync();
      openedFifo.writeStringSync('enable\n');
      _waitForAck();
    } catch (e) {
      await fifoDir.delete(recursive: true);
      rethrow;
    }
  }

  Future<void> _stopPerfStat(int totalIterations) async {
    try {
      openedFifo.writeStringSync('disable\n');
      openedFifo.closeSync();
      _waitForAck();
      openedAck.closeSync();
      perfProcess.kill(ProcessSignal.sigint);
      final lines =
          utf8.decoder.bind(perfProcess.stderr).transform(const LineSplitter());
      // Exit code from perf is -2 when terminated with SIGINT.
      final exitCode = await perfProcess.exitCode;
      if (exitCode != 0 && exitCode != -2) {
        throw ProcessException(
            'perf',
            [
              'stat',
              '--delay',
              '-1',
              '--control',
              'fifo:$perfControlFifo,$perfControlAck',
              '-j',
              '-p',
              '$pid'
            ],
            (await lines.toList()).join('\n'),
            exitCode);
      }
      final events = [
        await for (final line in lines)
          if (line.startsWith('{"counter-value" : '))
            jsonDecode(line) as Map<String, dynamic>
      ];
      _reportPerfStats(events, totalIterations);
    } finally {
      await fifoDir.delete(recursive: true);
    }
  }

  /// Measures the score for the benchmark and returns it.
  Future<double> measurePerf() async {
    setup();
    // Warmup for at least 100ms. Discard result.
    measureForImpl(warmup, 100);
    await _startPerfStat();
    // Run the benchmark for at least 2000ms.
    var result = measureForImpl(exercise, minimumMeasureDurationMillis);
    await _stopPerfStat(result.totalIterations);
    teardown();
    return result.score;
  }

  Future<void> reportPerf() async {
    emitter.emit(name, await measurePerf());
  }

  void _waitForAck() {
    var ack = <int>[...openedAck.readSync(5)];
    while (ack.length < 5) {
      ack.addAll(openedAck.readSync(5 - ack.length));
    }
    if (String.fromCharCodes(ack) != 'ack\n\x00') {
      print('Ack was $ack');
    }
  }

  void _reportPerfStats(List<Map<String, dynamic>> events, int iterations) {
    for (final {'event': String event, 'counter-value': String counterString}
        in events) {
      final metric =
          {'cycles:u': 'CpuCycles', 'page-faults:u': 'MajorPageFaults'}[event];
      if (metric != null) {
        emitter.emit(
            '$name($metric)', double.parse(counterString) / iterations);
      }
    }
    emitter.emit('$name.totalIterations', iterations.toDouble());
  }
}
