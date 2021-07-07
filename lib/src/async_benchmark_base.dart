// Copyright 2011 Google Inc. All Rights Reserved.

part of benchmark_harness;

class AsyncBenchmarkBase {
  final String name;
  final ScoreEmitter emitter;

  // Empty constructor.
  const AsyncBenchmarkBase(this.name, {this.emitter = const PrintEmitter()});

  // The benchmark code.
  // This function is not used, if both [warmup] and [exercise] are overwritten.
  Future<void> run() async {}

  // Runs a short version of the benchmark. By default invokes [run] once.
  Future<void> warmup() async {
    await run();
  }

  // Exercises the benchmark.
  Future<void> exercise() async {
    await run();
  }

  // Not measured setup code executed prior to the benchmark runs.
  Future<void> setup() async {}

  // Not measures teardown code executed after the benchark runs.
  Future<void> teardown() async {}

  // Measures the score for this benchmark by executing it repeately until
  // time minimum has been reached.
  static Future<double> measureFor(Function f, int minimumMillis) async {
    final minimumMicros = minimumMillis * 1000;
    int iter = 0;
    Stopwatch watch = Stopwatch();
    watch.start();
    int elapsed = 0;
    while (elapsed < minimumMicros) {
      await f();
      elapsed = watch.elapsedMicroseconds;
      iter++;
    }
    return elapsed / iter;
  }

  // Measures the score for the benchmark and returns it.
  Future<double> measure() async {
    await setup();
    try {
      // Warmup for at least 100ms. Discard result.
      await measureFor(warmup, 100);
      // Run the benchmark for at least 2000ms.
      return await measureFor(exercise, 2000);
    } finally {
      await teardown();
    }
  }

  Future<void> report() async {
    emitter.emit(name, await measure());
  }
}
