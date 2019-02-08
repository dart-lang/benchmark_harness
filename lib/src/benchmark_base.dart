// Copyright 2011 Google Inc. All Rights Reserved.

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

  // Exercices the benchmark. By default invokes [run] 10 times.
  void exercise() {
    for (int i = 0; i < 10; i++) {
      run();
    }
  }

  // Not measured setup code executed prior to the benchmark runs.
  void setup() {}

  // Not measures teardown code executed after the benchark runs.
  void teardown() {}

  // Measures the score for this benchmark by executing it repeately until
  // time minimum has been reached.
  static double measureFor(Function f, int minimumMillis) {
    int minimumMicros = minimumMillis * 1000;
    int iter = 1;
    int elapsed = 0;
    Stopwatch watch = Stopwatch();
    watch.start();
    while (iter > 0) {
      watch.reset();

      for (int i = 0; i < iter; i++) {
        f();
      }

      elapsed = watch.elapsedMicroseconds;
      if (elapsed >= minimumMicros) {
        return elapsed / iter;
      }

      iter *= 2;
    }
    throw "Iteration counter overflowed.  Use a smaller minimum time.";
  }

  // Measures the score for the benchmark and returns it.
  double measure() {
    setup();
    // Warmup for at least 100ms. Discard result.
    measureFor(warmup, 100);
    // Run the benchmark for at least 2000ms.
    double result = measureFor(exercise, 2000);
    teardown();
    return result;
  }

  void report() {
    emitter.emit(name, measure());
  }
}
