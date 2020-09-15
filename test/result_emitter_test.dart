library result_emitter_test;

import 'package:test/test.dart' show equals, expect, group, test;

import 'package:benchmark_harness/benchmark_harness.dart'
    show BenchmarkBase, ScoreEmitter;

void main() => benchmarkHarnessTest();

class MockResultEmitter extends ScoreEmitter {
  int emitCount = 0;

  @override
  void emit(String name, double value) => emitCount++;
}

// Create a new benchmark which has an emitter.
class BenchmarkWithResultEmitter extends BenchmarkBase {
  const BenchmarkWithResultEmitter(ScoreEmitter emitter)
      : super('Template', emitter: emitter);

  @override
  void run() {}

  @override
  void setup() {}

  @override
  void teardown() {}
}

void benchmarkHarnessTest() {
  group('ResultEmitter', () {
    test('should be called when emitter is provided', () {
      final emitter = MockResultEmitter(),
          testBenchmark = BenchmarkWithResultEmitter(emitter);

      testBenchmark.report();

      expect(emitter.emitCount, equals(1));
    });
  });
}
