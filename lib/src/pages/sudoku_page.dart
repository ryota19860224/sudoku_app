import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/difficulty.dart';

class SudokuPage extends StatefulWidget {
  final Difficulty difficulty;

  const SudokuPage({
    super.key,
    required this.difficulty,
  });

  @override
  State<SudokuPage> createState() => _SudokuPageState();
}

class _SudokuPageState extends State<SudokuPage> {
  static const String _cellNumberFontFamily = 'monospace';

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
      [8, 1, 7, 3, 4, 2, 9, 6, 5],
      [3, 5, 2, 9, 6, 8, 1, 7, 4],
      [1, 3, 4, 7, 5, 6, 2, 9, 8],
      [2, 9, 5, 4, 8, 1, 6, 3, 7],
      [7, 8, 6, 2, 3, 9, 4, 1, 5],
      [6, 7, 3, 1, 2, 4, 8, 5, 9],
      [5, 2, 8, 6, 9, 3, 7, 4, 1],
      [9, 4, 1, 5, 7, 0, 2, 8, 6],
    ],
    Difficulty.hard: [
      [1, 9, 2, 6, 3, 5, 4, 7, 8],
      [7, 8, 5, 9, 4, 3, 6, 1, 2],
      [4, 6, 3, 7, 9, 1, 5, 8, 2],
      [2, 1, 4, 8, 5, 7, 3, 9, 6],
      [6, 5, 9, 1, 8, 4, 2, 7, 3],
      [8, 7, 1, 3, 2, 6, 9, 4, 5],
      [3, 4, 8, 2, 1, 9, 7, 6, 4],
      [9, 2, 3, 4, 6, 8, 1, 5, 7],
      [5, 3, 6, 7, 2, 1, 8, 9, 4],
    ],
  };

  List<List<int>> _board = [];
  List<List<bool>> _fixed = [];
  List<List<bool>> _hasError = [];
  List<List<TextEditingController>> _controllers = [];
  List<List<Set<int>>> _notes = [];
  List<List<int>> _initialPuzzle = [];
  bool _solved = false;
  bool _completed = false;
  bool _memoMode = false;
  Duration _elapsed = Duration.zero;
  Timer? _timer;

  List<Color> get _difficultyGradient {
    switch (widget.difficulty) {
      case Difficulty.easy:
        return const [Color(0xFFF7EFE2), Color(0xFFE9F5F4)];
      case Difficulty.medium:
        return const [Color(0xFFF2E9D8), Color(0xFFE2EBF7)];
      case Difficulty.hard:
        return const [Color(0xFFEEE1D2), Color(0xFFD9DFEC)];
    }
  }

  String? get _difficultyBackgroundAsset {
    switch (widget.difficulty) {
      case Difficulty.easy:
        return 'assets/images/ねこ_背景１.png';
      case Difficulty.medium:
        return 'assets/images/ねこ_背景２.png';
      case Difficulty.hard:
        return 'assets/images/ねこ_背景３.png';
    }
  }

  Color get _difficultyAccent {
    switch (widget.difficulty) {
      case Difficulty.easy:
        return Colors.teal.shade700;
      case Difficulty.medium:
        return Colors.indigo.shade700;
      case Difficulty.hard:
        return Colors.deepOrange.shade700;
    }
  }

  Color get _difficultyOverlayColor {
    switch (widget.difficulty) {
      case Difficulty.easy:
        return Colors.white.withOpacity(0.55);
      case Difficulty.medium:
        return Colors.white.withOpacity(0.70);
      case Difficulty.hard:
        return Colors.white.withOpacity(0.74);
    }
  }

  Future<void> _showActionMessageWindow({
    required String action,
    required String text,
    IconData icon = Icons.info_outline,
    Color color = Colors.indigo,
  }) async {
    if (!mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: const Color(0xFFF7F1E8),
              border: Border.all(color: const Color(0xFFE7DCCB)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: color),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          action,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.35,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('閉じる'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _initialPuzzle = _buildPuzzleFromSolution(_solution);
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

  List<List<int>> get _solution => _solutions[widget.difficulty]!;

  List<List<int>> _buildPuzzleFromSolution(List<List<int>> solution) {
    final puzzle = List.generate(
      9,
      (row) => List.generate(9, (col) => solution[row][col]),
    );
    final int blanksToClear = switch (widget.difficulty) {
      Difficulty.easy => 36,
      Difficulty.medium => 44,
      Difficulty.hard => 50,
    };
    final indices = List<int>.generate(81, (index) => index)..shuffle(Random());
    for (var i = 0; i < blanksToClear; i++) {
      final index = indices[i];
      final row = index ~/ 9;
      final col = index % 9;
      puzzle[row][col] = 0;
    }
    return puzzle;
  }

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
    _notes = List.generate(9, (_) => List.generate(9, (_) => <int>{}));

    for (final row in _controllers) {
      for (final controller in row) {
        controller.dispose();
      }
    }
    _controllers = List.generate(
      9,
      (row) => List.generate(9, (col) {
        final controller = TextEditingController(
          text: _initialPuzzle[row][col] == 0
              ? ''
              : _initialPuzzle[row][col].toString(),
        );
        return controller;
      }),
    );
    _solved = false;
    _completed = false;
    _memoMode = false;
    _elapsed = Duration.zero;
    _startTimer();
  }

  Future<void> _clearEntries() async {
    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 9; col++) {
        if (!_fixed[row][col]) {
          _board[row][col] = 0;
          _controllers[row][col].clear();
          _notes[row][col] = <int>{};
        }
        _hasError[row][col] = false;
      }
    }
    setState(() {
      _solved = false;
      _completed = false;
    });
    await _showActionMessageWindow(
      action: 'クリア',
      text: '入力を消しました。',
      icon: Icons.cleaning_services,
      color: Colors.blue,
    );
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

  Future<void> _checkPuzzle() async {
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

    late String dialogMessage;
    late IconData dialogIcon;
    late Color dialogColor;

    setState(() {
      if (valid && complete) {
        _solved = true;
        _stopTimer();
        dialogMessage = '正解です。おめでとうございます。';
        dialogIcon = Icons.verified;
        dialogColor = Colors.green;
      } else if (valid) {
        _solved = false;
        dialogMessage = '空欄があります。続けてください。';
        dialogIcon = Icons.edit_note;
        dialogColor = Colors.orange;
      } else {
        _solved = false;
        dialogMessage = '重複または無効な入力があります。';
        dialogIcon = Icons.warning_amber_rounded;
        dialogColor = Colors.red;
      }
    });

    await _showActionMessageWindow(
      action: 'チェック',
      text: dialogMessage,
      icon: dialogIcon,
      color: dialogColor,
    );
  }

  Future<void> _changePuzzle() async {
    setState(() {
      _initialPuzzle = _buildPuzzleFromSolution(_solution);
      _resetBoard();
    });

    await _showActionMessageWindow(
      action: '問題変更',
      text: '新しい問題に切り替えました。',
      icon: Icons.swap_horiz,
      color: Colors.indigo,
    );
  }

  Future<void> _completeGame() async {
    var correctCount = 0;
    var editableCount = 0;

    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 9; col++) {
        if (_fixed[row][col]) {
          _hasError[row][col] = false;
          continue;
        }

        editableCount += 1;
        final value = _board[row][col];
        if (value == _solution[row][col]) {
          correctCount += 1;
          _hasError[row][col] = false;
        } else {
          _hasError[row][col] = true;
        }
      }
    }

    final mistakeCount = editableCount - correctCount;
    final accuracy = editableCount == 0
        ? 0.0
        : correctCount / editableCount * 100;
    setState(() {
      _completed = true;
      _solved = true;
      _stopTimer();
    });

    await _showActionMessageWindow(
      action: '完了',
      text:
          '採点結果を表示しました。\n正答 ${correctCount}/$editableCount (${accuracy.toStringAsFixed(1)}%)\n間違い $mistakeCount 件',
      icon: Icons.done_all,
      color: Colors.red,
    );
  }

  Future<void> _showMemoDialog(int row, int col) async {
    final selectedNumbers = <int>{..._notes[row][col]};
    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('メモを編集'),
              content: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(9, (index) {
                  final number = index + 1;
                  return FilterChip(
                    label: Text(number.toString()),
                    selected: selectedNumbers.contains(number),
                    onSelected: (isSelected) {
                      setDialogState(() {
                        if (isSelected) {
                          selectedNumbers.add(number);
                        } else {
                          selectedNumbers.remove(number);
                        }
                      });
                      setState(() {
                        _notes[row][col] = Set<int>.from(selectedNumbers);
                      });
                    },
                  );
                }),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('閉じる'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  TextStyle _numberTextStyle({
    double fontSize = 24,
    Color color = Colors.black,
    TextDecoration? decoration,
    Color? decorationColor,
    double? decorationThickness,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      fontFamily: _cellNumberFontFamily,
      color: color,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationThickness: decorationThickness,
    );
  }

  Widget _buildCell(int row, int col) {
    final isFixed = _fixed[row][col];
    final hasError = _hasError[row][col];
    final notes = _notes[row][col].toList()..sort();
    final hasValue = _board[row][col] != 0;

    if (isFixed) {
      return Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              width: row % 3 == 0 ? 2 : 0.5,
              color: Colors.black87,
            ),
            left: BorderSide(
              width: col % 3 == 0 ? 2 : 0.5,
              color: Colors.black87,
            ),
            right: BorderSide(width: col == 8 ? 2 : 0.5, color: Colors.black87),
            bottom: BorderSide(
              width: row == 8 ? 2 : 0.5,
              color: Colors.black87,
            ),
          ),
          color: Colors.indigo.shade50,
        ),
        child: SizedBox.expand(
          child: Center(
            child: Text(
              _board[row][col].toString(),
              style: _numberTextStyle(),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: row % 3 == 0 ? 2 : 0.5, color: Colors.black87),
          left: BorderSide(
            width: col % 3 == 0 ? 2 : 0.5,
            color: Colors.black87,
          ),
          right: BorderSide(width: col == 8 ? 2 : 0.5, color: Colors.black87),
          bottom: BorderSide(width: row == 8 ? 2 : 0.5, color: Colors.black87),
        ),
        color: Colors.white,
      ),
      child: _completed
          ? _buildCompletedCellContent(row, col)
          : _memoMode
          ? InkWell(
              onTap: () => _showMemoDialog(row, col),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: hasValue
                    ? Center(
                        child: Text(
                          _board[row][col].toString(),
                          style: _numberTextStyle(
                            color: hasError ? Colors.red.shade800 : Colors.black,
                          ),
                        ),
                      )
                    : notes.isEmpty
                    ? const Center(
                        child: Icon(
                          Icons.note_alt_outlined,
                          size: 16,
                          color: Colors.indigo,
                        ),
                      )
                    : Wrap(
                        spacing: 1,
                        runSpacing: 1,
                        children: notes
                            .map(
                              (value) => SizedBox(
                                width: 10,
                                child: Text(
                                  value.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 7,
                                    color: Colors.indigo,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
              ),
            )
          : Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TextField(
                    enabled: !_completed,
                    controller: _controllers[row][col],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: _cellNumberFontFamily,
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
                      });
                    },
                  ),
                  if (!hasValue && notes.isNotEmpty)
                    IgnorePointer(
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Wrap(
                          spacing: 1,
                          runSpacing: 1,
                          children: notes
                              .map(
                                (value) => SizedBox(
                                  width: 10,
                                  child: Text(
                                    value.toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 7,
                                      color: Colors.indigo.withOpacity(0.45),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildCompletedCellContent(int row, int col) {
    final enteredValue = _board[row][col];
    final answerValue = _solution[row][col];

    if (enteredValue == answerValue) {
      return Center(
        child: Text(
          answerValue.toString(),
          style: _numberTextStyle(),
        ),
      );
    }

    if (enteredValue == 0) {
      return Center(
        child: Text(
          answerValue.toString(),
          style: _numberTextStyle(
            color: Colors.red.shade800,
          ),
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            enteredValue.toString(),
            style: _numberTextStyle(
              fontSize: 14,
              color: Colors.red.shade700,
              decoration: TextDecoration.lineThrough,
              decorationColor: Colors.red.shade700,
              decorationThickness: 2,
            ),
          ),
          Text(
            answerValue.toString(),
            style: _numberTextStyle(
              fontSize: 18,
              color: Colors.red.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoardGrid(double boardSize) {
    return Center(
      child: SizedBox(
        width: boardSize,
        height: boardSize,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(4),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 81,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 9,
              childAspectRatio: 1,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
            ),
            itemBuilder: (context, index) {
              final row = index ~/ 9;
              final col = index % 9;
              return _buildCell(row, col);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildActionPanel({
    required double panelWidth,
    required bool splitButtons,
  }) {
    final buttons = <Widget>[
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(140, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: _completed ? null : _clearEntries,
        icon: const Icon(Icons.clear),
        label: const Text('クリア'),
      ),
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(140, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: _completed ? null : _checkPuzzle,
        icon: const Icon(Icons.check),
        label: const Text('チェック'),
      ),
      OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(140, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: _completed
            ? null
            : () {
                setState(() {
                  _memoMode = !_memoMode;
                });
                _showActionMessageWindow(
                  action: 'メモ',
                  text: _memoMode ? 'メモモードをオンにしました。' : 'メモモードをオフにしました。',
                  icon: _memoMode ? Icons.note_alt : Icons.note_alt_outlined,
                  color: Colors.teal,
                );
              },
        icon: Icon(_memoMode ? Icons.note_alt : Icons.note_alt_outlined),
        label: Text(_memoMode ? 'メモ中' : 'メモ'),
      ),
    ];

    return SizedBox(
      width: panelWidth,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white.withOpacity(0.92),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (!splitButtons) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < buttons.length; i++) ...[
                      buttons[i],
                      if (i != buttons.length - 1) const SizedBox(height: 8),
                    ],
                  ],
                );
              }

              final buttonWidth = (constraints.maxWidth - 8) / 2;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final button in buttons)
                    SizedBox(width: buttonWidth, child: button),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryActionPanel({required double panelWidth}) {
    return SizedBox(
      width: panelWidth,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.indigo.withOpacity(0.10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(140, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _completed ? null : _completeGame,
                icon: const Icon(Icons.done_all),
                label: const Text('完了'),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(140, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _changePuzzle,
                icon: const Icon(Icons.swap_horiz),
                label: const Text('問題を変える'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionSummaryPanel({required double panelWidth}) {
    return SizedBox(
      width: panelWidth,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white.withOpacity(0.92),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                '正答率 ${_calculateAccuracy().toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '間違い ${_calculateMistakes()} 件',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundAsset = _difficultyBackgroundAsset;
    final hasBackgroundAsset = backgroundAsset != null;

    return Scaffold(
      appBar: AppBar(
        title: Text('数独 - ${widget.difficulty.label}'),
        centerTitle: true,
        backgroundColor: _difficultyAccent,
        foregroundColor: Colors.white,
      ),
      body: Container(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _difficultyGradient,
                  ),
                ),
              ),
            ),
            if (hasBackgroundAsset)
              Positioned.fill(
                child: Image.asset(
                  backgroundAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            Positioned.fill(
              child: hasBackgroundAsset
                  ? BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 1.6, sigmaY: 1.6),
                      child: Container(color: _difficultyOverlayColor),
                    )
                  : Container(color: _difficultyOverlayColor),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 820;
                    final maxBoardByWidth = isWide
                        ? constraints.maxWidth * 0.62
                        : constraints.maxWidth;
                    final boardSize = max(280.0, min(maxBoardByWidth, 520.0));
                    final panelWidth = isWide
                        ? max(
                            220.0,
                            min(300.0, constraints.maxWidth - boardSize - 24),
                          )
                        : constraints.maxWidth;
                    final splitButtons = !isWide && panelWidth >= 360;

                    return Column(
                      children: [
                        Card(
                          elevation: 0,
                          color: Colors.white.withOpacity(0.92),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.timer,
                                  size: 20,
                                  color: Colors.black54,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatDuration(_elapsed),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (isWide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildBoardGrid(boardSize),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: panelWidth,
                                child: Column(
                                  children: [
                                    _buildPrimaryActionPanel(
                                      panelWidth: panelWidth,
                                    ),
                                    const SizedBox(height: 10),
                                    _buildActionPanel(
                                      panelWidth: panelWidth,
                                      splitButtons: false,
                                    ),
                                    if (_completed) ...[
                                      const SizedBox(height: 10),
                                      _buildCompletionSummaryPanel(
                                        panelWidth: panelWidth,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildBoardGrid(boardSize),
                              const SizedBox(height: 12),
                              _buildPrimaryActionPanel(panelWidth: panelWidth),
                              const SizedBox(height: 10),
                              _buildActionPanel(
                                panelWidth: panelWidth,
                                splitButtons: splitButtons,
                              ),
                              if (_completed) ...[
                                const SizedBox(height: 10),
                                _buildCompletionSummaryPanel(
                                  panelWidth: panelWidth,
                                ),
                              ],
                            ],
                          ),
                        const SizedBox(height: 16),
                        Text(
                          '固定数字はグレー、赤は間違いです。',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateAccuracy() {
    var correctCount = 0;
    var editableCount = 0;
    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 9; col++) {
        if (_fixed[row][col]) {
          continue;
        }
        editableCount += 1;
        final value = _board[row][col];
        if (value == _solution[row][col]) {
          correctCount += 1;
        }
      }
    }
    if (editableCount == 0) {
      return 0.0;
    }
    return correctCount / editableCount * 100;
  }

  int _calculateMistakes() {
    var mistakeCount = 0;
    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 9; col++) {
        if (_fixed[row][col]) {
          continue;
        }
        final value = _board[row][col];
        if (value != _solution[row][col]) {
          mistakeCount += 1;
        }
      }
    }
    return mistakeCount;
  }
}
