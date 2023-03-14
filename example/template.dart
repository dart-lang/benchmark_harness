// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Import BenchmarkBase class.
import 'package:benchmark_harness/benchmark_harness.dart';

// Create a new benchmark by extending BenchmarkBase
class TemplateBenchmark extends BenchmarkBase {
  const TemplateBenchmark() : super('Template');

  static void main() {
    const TemplateBenchmark().report();
  }

  // The benchmark code.
  @override
  void run() {}

  // Not measured setup code executed prior to the benchmark runs.
  @override
  void setup() {}

  // Not measures teardown code executed after the benchmark runs.
  @override
  void teardown() {}

  // To opt into the reporting the time per run() instead of per 10 run() calls.
  //@override
  //void exercise() => run();
}

void main() {
  // Run TemplateBenchmark
  TemplateBenchmark.main();
}
