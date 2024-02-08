// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'benchmark_base.dart';
import 'score_emitter.dart';

const perfControlFifoVariable = 'PERF_CONTROL_FIFO';
const perfControlAckVariable = 'PERF_CONTROL_ACK';

class PerfBenchmarkBase extends BenchmarkBase {
  PerfBenchmarkBase(super.name, {super.emitter = const PrintEmitter()});

  String? perfControlFifo;
  late RandomAccessFile openedFifo;
  String? perfControlAck;
  late RandomAccessFile openedAck;
  late Process perfProcess;

  Future<void> _startPerfStat() async {
    perfControlFifo = Platform.environment[perfControlFifoVariable];
    perfControlAck = Platform.environment[perfControlAckVariable];
    print(perfControlFifo);
    if (perfControlFifo != null) {
      openedFifo = File(perfControlFifo!).openSync(mode: FileMode.writeOnly);
      if (perfControlAck != null) {
        openedAck = File(perfControlAck!).openSync();
        openedFifo.writeStringSync('enable\n');
        _waitForAck();
      } else {
        openedFifo.writeStringSync('enable\n');
      }
    }
  }

  Future<void> _stopPerfStat(int totalIterations) async {
    if (perfControlFifo != null) {
      openedFifo.writeStringSync('disable\n');
      openedFifo.closeSync();
      if (perfControlAck != null) {
        _waitForAck();
        openedAck.closeSync();
      }
      emitter.emit('$name.totalIterations', totalIterations.toDouble());
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
}
