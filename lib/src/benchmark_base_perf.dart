// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'benchmark_base.dart' as base;
import 'score_emitter.dart';

const perfControlFifoVariable = 'PERF_CONTROL_FIFO';

class BenchmarkBase extends base.BenchmarkBase {
  BenchmarkBase(super.name, {super.emitter = const PrintEmitter()});

  String? perfControlFifo;
  late RandomAccessFile openedFifo;

  @override
  void beforeTimedRuns() {
    perfControlFifo = Platform.environment[perfControlFifoVariable];
    if (perfControlFifo != null) {
      openedFifo = File(perfControlFifo!).openSync();
      openedFifo.writeStringSync('enable\n');
      // TODO: read 'ack\n' from second ack fifo, before proceeding.
    }
  }

  @override
  void afterTimedRuns(int totalIterations) {
    if (perfControlFifo != null) {
      openedFifo.writeStringSync('disable\n');
    }
    // TODO: await ack.
    openedFifo.closeSync();
    emitter.emit('$name.totalIterations', totalIterations.toDouble());
  }
}
