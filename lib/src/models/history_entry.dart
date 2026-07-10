import '../models/difficulty.dart';

class HistoryEntry {
  final Difficulty difficulty;
  final String result;
  final DateTime time;

  HistoryEntry({
    required this.difficulty,
    required this.result,
    required this.time,
  });
}
