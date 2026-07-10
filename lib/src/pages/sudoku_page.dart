import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/difficulty.dart';
import '../models/history_entry.dart';

class SudokuPage extends StatefulWidget {
  final Difficulty difficulty;
  final void Function(HistoryEntry entry) onAddHistory;

  const SudokuPage({
    super.key,
    required this.difficulty,
    required this.onAddHistory,
  });

  @override
  State<SudokuPage> createState() => _SudokuPageState();
}

class _SudokuPageState extends State<SudokuPage> {
  static const Map<Difficulty, List<List<int>>> _puzzles = {
    Difficulty.easy: [
      [5, 3, 0, 0, 7, 0, 0, 0, 0],
      [6, 0, 0, 1, 9, 5, 0, 0, 0],
      [0, 9, 8, 0, 0, 0, 0, 6, 0],
      [8, 0, 0, 0, 6, 0, 0, 0, 3],
      [4, 0, 0, 8, 0, 3, 0, 0, 1],
      [7, 0, 0, 0, 2, 0, 0, 0, 6],
      [0, 6, 0, 0, 0, 0, 2, 8, 0],
      [0, 0, 0, 4, 1, 9, 0, 0, 5],
      [0, 0, 0, 0, 8, 0, 0, 7, 9],
    ],
    Difficulty.medium: [
      [0, 0, 0, 0, 0, 7, 3, 0, 0],
      [0, 0, 0, 3, 0, 0, 0, 2, 5],
      [0, 0, 1, 0, 0, 0, 0, 7, 0],
      [0, 0, 2, 0, 6, 0, 4, 0, 8],
      [0, 9, 0, 4, 0, 1, 0, 3, 0],
      [7, 0, 8, 0, 2, 0, 1, 0, 0],
      [0, 7, 0, 0, 0, 0, 9, 0, 0],
      [5, 2, 0, 0, 0, 3, 0, 0, 0],
      [0, 0, 4, 5, 0, 0, 0, 0, 0],
    ],
    Difficulty.hard: [
      [0, 0, 0, 6, 0, 0, 4, 0, 0],
      [7, 0, 0, 0, 0, 3, 6, 0, 0],
      [0, 0, 0, 0, 9, 1, 0, 8, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 5, 0, 1, 8, 0, 0, 0, 3],
      [0, 0, 0, 3, 0, 6, 0, 4, 5],
      [0, 4, 0, 2, 0, 0, 0, 6, 0],
      [9, 0, 3, 0, 0, 0, 0, 0, 0],
      [0, 2, 0, 0, 0, 0, 1, 0, 0],
    ],
  };

  static const Map<Difficulty, List<List<int>>> _solutions = {
    Difficulty.easy: [
      [5, 3, 4, 6, 7, 8, 9, 1, 2],
      [6, 7, 2, 1, 9, 5, 3, 4, 8],
      [1, 9, 8, 3, 4, 2, 5, 6, 7],
      [8, 5, 9, 7, 6, 1, 4, 2, 3],
      [4, 2, 6, 8, 5, 3, 7, 9, 1],
      [7, 1, 3, 9, 2, 4, 8, 5, 6],
      [9, 6, 1, 5, 3, 7, 2, 8, 4],
      [2, 8, 7, 4, 1, 9, 6, 3, 5],
      [3, 4, 5, 2, 8, 6, 1, 7, 9],
    ],
    Difficulty.medium: [
      [4, 6, 9, 8, 1, 7, 3, 5, 2],
      [8, 1, 7, 3, 4, 2, 0, 2, 5],
      [3, 5, 1, 9, 4, 2, 8, 7, 6],
      [1, 3, 2, 7, 6, 5, 4, 9, 8],
      [2, 9, 5, 4, 8, 1, 7, 3, 0],
      [7, 4, 8, 2, 2, 9, 1, 6, 0],
      [6, 7, 3, 1, 5, 4, 9, 0, 7],
      [5, 2, 0, 6, 7, 3, 2, 1, 4],
      [9, 8, 4, 5, 2, 0, 6, 0, 3],
    ],
    Difficulty.hard: [
      [1, 9, 2, 6, 3, 5, 4, 7, 8],
      [7, 8, 5, 9, 4, 3, 6, 1, 2],
      [4, 6, 3, 7, 9, 1, 5, 8, 0],
      [2, 1, 4, 8, 5, 7, 3, 9, 6],
      [6, 5, 9, 1, 8, 4, 2, 7, 3],
      [8, 7, 1, 3, 2, 6, 9, 4, 5],
      [3, 4, 8, 2, 1, 9, 7, 6, 4],
      [9, 2, 3, 4, 6, 8, 1, 5, 7],
      [5, 2, 6, 0, 7, 0, 1, 3, 4],
    ],
  };

  late List<List<int>> _board;
  late List<List<bool>> _fixed;
  late List<List<bool>> _hasError;
  late List<List<TextEditingController>> _controllers;
  bool _solved = false;
  String _message = '空欄を埋めてチェックしてください。';
  Duration _elapsed = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _resetBoard();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final row in _controllers) {
      for (final controller in row) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  List<List<int>> get _initialPuzzle => _puzzles[widget.difficulty]!;
  List<List<int>> get _solution => _solutions[widget.difficulty]!;

  void _resetBoard() {
    _board = List.generate(
      9,
      (row) => List.generate(9, (col) => _initialPuzzle[row][col]),
    );
    _fixed = List.generate(
      9,
      (row) => List.generate(9, (col) => _initialPuzzle[row][col] != 0),
    );
    _hasError = List.generate(9, (_) => List.generate(9, (_) => false));
    _controllers = List.generate(
      9,
      (row) => List.generate(9, (col) {
        final controller = TextEditingController(
          text: _initialPuzzle[row][col] == 0 ? '' : _initialPuzzle[row][col].toString(),
        );
        return controller;
      }),
    );
    _solved = false;
    _message = '空欄を埋めてチェックしてください。';
    _elapsed = Duration.zero;
    _startTimer();
  }

  void _clearEntries() {
    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 9; col++) {
        if (!_fixed[row][col]) {
          _board[row][col] = 0;
          _controllers[row][col].clear();
        }
        _hasError[row][col] = false;
      }
    }
    setState(() {
      _solved = false;
      _message = '入力を消しました。';
    });
  }

  bool _isValidCell(int row, int col) {
    final value = _board[row][col];
    if (value == 0) {
      return false;
    }

    for (var x = 0; x < 9; x++) {
      if (x != col && _board[row][x] == value) {
        return false;
      }
      if (x != row && _board[x][col] == value) {
        return false;
      }
    }

    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (var r = boxRow; r < boxRow + 3; r++) {
      for (var c = boxCol; c < boxCol + 3; c++) {
        if ((r != row || c != col) && _board[r][c] == value) {
          return false;
        }
      }
    }
    return true;
  }

  void _addHistory(String result) {
    widget.onAddHistory(
      HistoryEntry(
        difficulty: widget.difficulty,
        result: result,
        time: DateTime.now(),
      ),
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed += const Duration(seconds: 1);
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _checkPuzzle() {
    var valid = true;
    var complete = true;

    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 9; col++) {
        final cellValue = _board[row][col];
        final cellValid = cellValue != 0 && _isValidCell(row, col);
        _hasError[row][col] = !cellValid;
        if (cellValue == 0) {
          complete = false;
        }
        if (!cellValid) {
          valid = false;
        }
      }
    }

    setState(() {
      if (valid && complete) {
        _solved = true;
        _message = '正解です！おめでとうございます。';
        _stopTimer();
        _addHistory('正解');
      } else if (valid) {
        _solved = false;
        _message = 'まだ空欄があります。続けてください。';
        _addHistory('途中');
      } else {
        _solved = false;
        _message = '重複または無効な入力があります。赤で示しました。';
        _addHistory('間違い');
      }
    });
  }

  void _solvePuzzle() {
    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 9; col++) {
        _board[row][col] = _solution[row][col];
        _controllers[row][col].text = _solution[row][col].toString();
        _hasError[row][col] = false;
      }
    }
    _stopTimer();
    setState(() {
      _solved = true;
      _message = '答えを表示しました。';
      _addHistory('答え表示');
    });
  }

  Widget _buildCell(int row, int col) {
    final isFixed = _fixed[row][col];
    final hasError = _hasError[row][col];
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: row % 3 == 0 ? 2 : 0.5, color: Colors.black87),
          left: BorderSide(width: col % 3 == 0 ? 2 : 0.5, color: Colors.black87),
          right: BorderSide(width: col == 8 ? 2 : 0.5, color: Colors.black87),
          bottom: BorderSide(width: row == 8 ? 2 : 0.5, color: Colors.black87),
        ),
        color: isFixed ? Colors.indigo.shade50 : Colors.white,
      ),
      child: Center(
        child: TextField(
          controller: _controllers[row][col],
          enabled: !isFixed,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: isFixed ? FontWeight.bold : FontWeight.w600,
            color: hasError ? Colors.red.shade800 : Colors.black,
          ),
          maxLength: 1,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            FilteringTextInputFormatter.allow(RegExp('[1-9]')),
            LengthLimitingTextInputFormatter(1),
          ],
          decoration: InputDecoration(
            counterText: '',
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onChanged: (value) {
            setState(() {
              _board[row][col] = value.isEmpty ? 0 : int.parse(value);
              _hasError[row][col] = false;
              _solved = false;
              _message = '再チェックしてください。';
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('数独 - ${widget.difficulty.label}'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer, size: 20, color: Colors.black54),
                  const SizedBox(width: 8),
                  Text(
                    _formatDuration(_elapsed),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Table(
                          border: TableBorder.all(color: Colors.transparent),
                          children: List.generate(9, (row) {
                            return TableRow(
                              children: List.generate(9, (col) {
                                return _buildCell(row, col);
                              }),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _message,
                style: TextStyle(
                  fontSize: 16,
                  color: _solved ? Colors.green.shade800 : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _clearEntries,
                    icon: const Icon(Icons.clear),
                    label: const Text('クリア'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _checkPuzzle,
                    icon: const Icon(Icons.check),
                    label: const Text('チェック'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _solvePuzzle,
                    icon: const Icon(Icons.visibility),
                    label: const Text('答え'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _resetBoard();
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('リセット'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                '固定数字はグレー、赤は間違いです。',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
