// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:test/test.dart';

void main() {
  group('benchmark_harness', () {
    test('run is called', () {
      final benchmark = MockBenchmark();
      final micros = benchmark.measure();
      expect(micros, isPositive);
      expect(benchmark.runCount, isPositive);
    });
    test('async run is awaited', () async {
      final benchmark = MockAsyncBenchmark();
      final micros = await benchmark.measure();
      expect(micros, isPositive);
      expect(benchmark.runCount, isPositive);
    });
  });
}

class MockBenchmark extends BenchmarkBase {
  int runCount = 0;

  MockBenchmark() : super('mock benchmark');

  @override
  void run() {
    runCount++;
  }
}

class MockAsyncBenchmark extends AsyncBenchmarkBase {
  int runCount = 0;
  MockAsyncBenchmark() : super('mock benchmark');

  @override
  Future<void> run() async {
    await Future<void>.delayed(Duration.zero);
    runCount++;
  }
}
