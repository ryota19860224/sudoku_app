enum Difficulty { easy, medium, hard }

extension DifficultyExtension on Difficulty {
  String get label {
    switch (this) {
      case Difficulty.easy:
        return 'かんたん';
      case Difficulty.medium:
        return 'ふつう';
      case Difficulty.hard:
        return 'むずかしい';
    }
  }

  String get description {
    switch (this) {
      case Difficulty.easy:
        return 'はじめての人向け';
      case Difficulty.medium:
        return 'ちょうどいいむずかしさ';
      case Difficulty.hard:
        return 'じっくり挑戦';
    }
  }
}
