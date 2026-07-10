import 'package:flutter/material.dart';
import '../models/difficulty.dart';
import '../models/history_entry.dart';
import 'history_page.dart';
import 'sudoku_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<HistoryEntry> _history = [];

  void _addHistory(HistoryEntry entry) {
    setState(() {
      _history.insert(0, entry);
    });
  }

  void _openSudoku(Difficulty difficulty) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SudokuPage(
          difficulty: difficulty,
          onAddHistory: _addHistory,
        ),
      ),
    );
  }

  void _openHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HistoryPage(history: _history),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数独'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: '履歴を見る',
            onPressed: _openHistory,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '難易度を選んでスタートしよう',
                  style: TextStyle(fontSize: 20, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                for (final difficulty in Difficulty.values)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                      ),
                      onPressed: () => _openSudoku(difficulty),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            difficulty.label,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            difficulty.description,
                            style: const TextStyle(fontSize: 14, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _openHistory,
                  icon: const Icon(Icons.history),
                  label: const Text('履歴を見る'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
