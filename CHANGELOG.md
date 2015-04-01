## 1.1.0

  * Added `iterations` optional named argument to the `exercise` and `warmup` 
    methods which controls how many times `run` is called.
  * Added `maxIterations` optional named argument to the `measureFor` method.
    If supplied then the benchmark will exit immediately once `f` has
    been called that many times, regardless of the `minimumMillis` setting.
  * Added various optional named arguments to the `measure` method.
    * `minimumWarmupMillis`: The minimum amount of time to warmup for.
    * `minimumBenchmarkMillis`: The minimum amount of time to run the benchmark.
    * `maxWarmupIterations`: The maximum number of times to call `warmup`.
    * `maxExerciseIterations`: The maximum number of times to call `exercise`. 
    * `runsPerWarmup`: How many times `run` should be called by `warmup`.
    * `runsPerExercise`: How many times `run` should be called by `exercise`.
