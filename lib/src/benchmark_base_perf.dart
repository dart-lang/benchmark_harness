// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'benchmark_base.dart' as base;
import 'score_emitter.dart';

const perfControlFifoVariable = 'PERF_CONTROL_FIFO';
const perfControlAckVariable = 'PERF_CONTROL_ACK';

class BenchmarkBase extends base.BenchmarkBase {
  BenchmarkBase(super.name, {super.emitter = const PrintEmitter()});

  String? perfControlFifo;
  late RandomAccessFile openedFifo;
  String? perfControlAck;
  late RandomAccessFile openedAck;

  @override
  void beforeTimedRuns() {
    perfControlFifo = Platform.environment[perfControlFifoVariable];
    perfControlAck = Platform.environment[perfControlAckVariable];
    if (perfControlFifo != null) {
      openedFifo = File(perfControlFifo!).openSync(mode: FileMode.writeOnly);
      if (perfControlAck != null) {
        openedAck = File(perfControlAck!).openSync();
        openedFifo.writeStringSync('enable\n');
        waitForAck();
      } else {
        openedFifo.writeStringSync('enable\n');
      }
    }
  }

  @override
  void afterTimedRuns(int totalIterations) {
    if (perfControlFifo != null) {
      openedFifo.writeStringSync('disable\n');
      openedFifo.closeSync();
      if (perfControlAck != null) {
        waitForAck();
        openedAck.closeSync();
      }
      emitter.emit('$name.totalIterations', totalIterations.toDouble());
    }
  }

  void waitForAck() {
    var ack = <int>[...openedAck.readSync(4)];
    while (ack.length < 4) {
      ack.addAll(openedAck.readSync(4 - ack.length));
      print('reading $ack');
    }
    if (String.fromCharCodes(ack) != 'ack\n') {
      print('Ack was $ack');
    }
  }
}
