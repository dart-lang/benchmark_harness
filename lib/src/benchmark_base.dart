// Copyright 2011 Google Inc. All Rights Reserved.

part of benchmark_harness;

class BenchmarkBase {
  final String name;
  final ScoreEmitter emitter;

  /// Empty constructor.
  const BenchmarkBase(String name,
      { ScoreEmitter emitter: const PrintEmitter() })
      : this.name = name,
        this.emitter = emitter;

  /// The benchmark code.
  /// This function is not used if both [warmup] and [exercise] are overwritten.
  void run() { }

  /// Runs a short version of the benchmark. By default invokes [run] once.
  void warmup({int iterations: 1}) {
    for (int i = 0; i < iterations; i++) {
      run();
    }
  }

  /// Exercises the benchmark. By default invokes [run] 10 times.
  void exercise({int iterations: 10}) {
    for (int i = 0; i < iterations; i++) {
      run();
    }
  }

  /// Not measured setup code executed prior to the benchmark runs.
  void setup() { }

  /// Not measured teardown code executed after the benchark runs.
  void teardown() { }

  /// Measures the score for this benchmark by executing it repeately until
  /// either the [minimumMillis] or [maxIterations] has been reached.
  static double measureFor(Function f, int minimumMillis,
      {int maxIterations: null}) {
    int minimumMicros = minimumMillis * 1000;
    int time = 0;
    int iter = 0;
    Stopwatch watch = new Stopwatch();
    watch.start();
    int elapsed = 0;
    while (elapsed < minimumMicros) {
      if (maxIterations != null && iter >= maxIterations) break;
      f();
      elapsed = watch.elapsedMicroseconds;
      iter++;
    }
    return elapsed / iter;
  }

  /// Measures the score for the benchmark and returns it.
  ///
  /// Performs a warmup for either [minimumWarmupMillis] or
  /// [maxWarmupIterations] * [runsPerWarmup] iterations, and discards the
  /// result. Then runs the benchmark for either [minimumBenchmarkMillis] or
  /// [maxExerciseIterations] * [runsPerExercise] iterations and returns the
  /// result.
  double measure(
      {int minimumWarmupMillis: 100, int minimumBenchmarkMillis: 2000,
      int maxWarmupIterations: null, int runsPerWarmup: 1,
      int maxExerciseIterations: null, int runsPerExercise: 10}) {
    setup();
    // Run the warmup.
    measureFor(
        () { this.warmup(iterations: runsPerWarmup); },
        minimumWarmupMillis, maxIterations: maxWarmupIterations);
    // Run the benchmark.
    double result = measureFor(
        () {this.exercise(iterations: runsPerExercise); },
        minimumBenchmarkMillis, maxIterations: maxExerciseIterations);
    teardown();
    return result;
  }

  void report() {
    emitter.emit(name, measure());
  }

}
