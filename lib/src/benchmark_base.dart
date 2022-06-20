// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of benchmark_harness;

class BenchmarkBase {
  final String name;
  final ScoreEmitter emitter;

  // Empty constructor.
  const BenchmarkBase(this.name, {this.emitter = const PrintEmitter()});

  // The benchmark code.
  // This function is not used, if both [warmup] and [exercise] are overwritten.
  void run() {}

  // Runs a short version of the benchmark. By default invokes [run] once.
  void warmup() {
    run();
  }

  // Exercises the benchmark. By default invokes [run] 10 times.
  void exercise() {
    for (var i = 0; i < 10; i++) {
      run();
    }
  }

  // Not measured setup code executed prior to the benchmark runs.
  void setup() {}

  // Not measures teardown code executed after the benchmark runs.
  void teardown() {}

  // Measures the score for this benchmark by executing it repeatedly until
  // time minimum has been reached.
  static double measureFor(void Function() f, int minimumMillis) {
    final minimumMicros = minimumMillis * 1000;
    var iter = 1;
    var elapsed = 0;
    final watch = Stopwatch()..start();
    while (true) {
      watch.reset();
      for (var i = 0; i < iter; i++) {
        f();
      }
      elapsed = watch.elapsedMicroseconds;
      if (elapsed >= minimumMicros) {
        return elapsed / iter;
      }
      iter *= 2;
    }
  }

  // Measures the score for the benchmark and returns it.
  double measure() {
    setup();
    // Warmup for at least 100ms. Discard result.
    measureFor(warmup, 100);
    // Run the benchmark for at least 2000ms.
    var result = measureFor(exercise, 2000);
    teardown();
    return result;
  }

  void report() {
    emitter.emit(name, measure());
  }
}
