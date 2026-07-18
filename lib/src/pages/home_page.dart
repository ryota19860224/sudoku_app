import 'package:flutter/material.dart';
import '../models/difficulty.dart';
import 'sudoku_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _openSudoku(Difficulty difficulty) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SudokuPage(difficulty: difficulty),
      ),
    );
  }

  IconData _iconForDifficulty(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return Icons.wb_sunny_outlined;
      case Difficulty.medium:
        return Icons.filter_vintage_outlined;
      case Difficulty.hard:
        return Icons.local_fire_department_outlined;
    }
  }

  Color _colorForDifficulty(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return const Color(0xFF0E9F6E);
      case Difficulty.medium:
        return const Color(0xFF2563EB);
      case Difficulty.hard:
        return const Color(0xFFDC2626);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF9F4E7), Color(0xFFE8F2F9)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              left: -30,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD8A8).withOpacity(0.34),
                  borderRadius: BorderRadius.circular(110),
                ),
              ),
            ),
            Positioned(
              bottom: -70,
              right: -20,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFBDE0FE).withOpacity(0.40),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.88),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFFE7DBC7)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.09),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'SUDOKU',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.5,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '難易度を選んでチャレンジ開始',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.blueGrey.shade700,
                              ),
                            ),
                            const SizedBox(height: 22),
                            for (final difficulty in Difficulty.values)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: _colorForDifficulty(difficulty),
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size.fromHeight(72),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  onPressed: () => _openSudoku(difficulty),
                                  child: Row(
                                    children: [
                                      Icon(_iconForDifficulty(difficulty), size: 24),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              difficulty.label,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              difficulty.description,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.play_arrow_rounded),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              'ヒント: ミスは赤色表示されます',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
