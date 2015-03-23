// Copyright (c) 2014, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library benchmark_harness_test;

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:unittest/unittest.dart';

void main() {
  group('benchmark_harness', () {
    test('run is called', () {
      MockBenchmark benchmark = new MockBenchmark();
      double micros = benchmark.measure();
      expect(micros, isPositive);
      expect(benchmark.runCount, isPositive);
    });

    test('can set warmup and excersize iterations and runs per iteration', () {
      MockBenchmark benchmark = new MockBenchmark();
      double micros = benchmark.measure(
          maxWarmupIterations: 5, maxExerciseIterations: 5,
          runsPerWarmup: 5, runsPerExercise: 5);
      // 25 total runs from each (5 * 5)
      expect(benchmark.runCount, 50);
      expect(benchmark.warmupCount, 5);
      expect(benchmark.exerciseCount, 5);
    });

    test('can customize the time a benchmark will run', () {
      MockBenchmark benchmark100 = new MockBenchmark()
        ..measure(minimumBenchmarkMillis: 100, minimumWarmupMillis: 100);

      MockBenchmark benchmark500 = new MockBenchmark()
        ..measure(minimumBenchmarkMillis: 500, minimumWarmupMillis: 500);

      expect(benchmark100.exerciseCount, lessThan(benchmark500.exerciseCount));
      expect(benchmark100.warmupCount, lessThan(benchmark500.warmupCount));
    });
  });
}

class MockBenchmark extends BenchmarkBase {
  int runCount = 0;
  int warmupCount = 0;
  int exerciseCount = 0;

  MockBenchmark() : super('mock benchmark');

  @override
  void exercise({int iterations: 10}) {
    exerciseCount++;
    super.exercise(iterations: iterations);
  }

  @override
  void warmup({int iterations: 1}) {
    warmupCount++;
    super.warmup(iterations: iterations);
  }

  @override
  void run() {
    runCount++;
  }
}
