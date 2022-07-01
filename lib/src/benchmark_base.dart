// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of benchmark_harness;

class BenchmarkBase {
  final String name;
  final ScoreEmitter emitter;

  const BenchmarkBase(this.name, {this.emitter = const PrintEmitter()});

  /// The benchmark code.
  ///
  /// This function is not used, if both [warmup] and [exercise] are overwritten.
  void run() {}

  /// Runs a short version of the benchmark. By default invokes [run] once.
  void warmup() {
    run();
  }

  /// Exercises the benchmark. By default invokes [run] 10 times.
  void exercise() {
    for (var i = 0; i < 10; i++) {
      run();
    }
  }

  /// Not measured setup code executed prior to the benchmark runs.
  void setup() {}

  /// Not measured teardown code executed after the benchmark runs.
  void teardown() {}

  /// Measures the score for this benchmark by executing it enough times
  /// to reach [minimumMillis].
  ///
  /// This function searches for the requisite number of iterations by
  /// starting at [initialIter].
  static _Measurement _measureForImpl(
      void Function() f, int minimumMillis, int initialIter) {
    final minimumMicros = minimumMillis * 1000;
    var iter = initialIter;
    var elapsed = 0;
    final watch = Stopwatch()..start();
    while (true) {
      watch.reset();
      for (var i = 0; i < iter; i++) {
        f();
      }
      elapsed = watch.elapsedMicroseconds;
      if (elapsed >= minimumMicros) {
        return _Measurement(elapsed, iter);
      }
      if (elapsed == 0) {
        iter *= 1000;
      } else {
        iter = (iter * math.max(minimumMicros / elapsed, 2.0)).ceil();
      }
    }
  }

  /// Measures the score for this benchmark by executing it repeatedly until
  /// time minimum has been reached.
  static double measureFor(void Function() f, int minimumMillis) =>
      _measureForImpl(f, minimumMillis, 1).score;

  /// Measures the score for the benchmark and returns it.
  double measure() {
    setup();
    // Warmup for at least 100ms. Discard result.
    final measurement = _measureForImpl(warmup, 100, 1);
    // Run the benchmark for at least 2000ms.
    var result = _measureForImpl(exercise, 2000, measurement.iterations);
    teardown();
    return result.score;
  }

  void report() {
    emitter.emit(name, measure());
  }
}

class _Measurement {
  final int elapsedMicros;
  final int iterations;

  _Measurement(this.elapsedMicros, this.iterations);

  double get score => elapsedMicros / iterations;
}
