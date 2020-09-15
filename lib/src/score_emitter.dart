abstract class ScoreEmitter {
  const ScoreEmitter();

  /// Override this method to report scores.
  void emit(String testName, double value);
}

class PrintEmitter implements ScoreEmitter {
  const PrintEmitter();

  @override
  void emit(String testName, double value) =>
      print('$testName(RunTime): $value us.');
}
