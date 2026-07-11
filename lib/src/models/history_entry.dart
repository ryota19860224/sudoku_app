import '../models/difficulty.dart';

class HistoryEntry {
  final Difficulty difficulty;
  final String result;
  final DateTime time;
  final int? correctCount;
  final int? totalCount;
  final double? accuracy;

  HistoryEntry({
    required this.difficulty,
    required this.result,
    required this.time,
    this.correctCount,
    this.totalCount,
    this.accuracy,
  });
}
