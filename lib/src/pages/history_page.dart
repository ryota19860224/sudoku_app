import 'package:flutter/material.dart';
import '../models/difficulty.dart';
import '../models/history_entry.dart';

class HistoryPage extends StatelessWidget {
  final List<HistoryEntry> history;

  const HistoryPage({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プレイ履歴'),
      ),
      body: history.isEmpty
          ? const Center(
              child: Text(
                'まだ履歴がありません。',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final entry = history[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo.shade100,
                      child: Text(entry.difficulty.label.substring(0, 1)),
                    ),
                    title: Text('${entry.difficulty.label} - ${entry.result}'),
                    subtitle: Text(
                      '${entry.time.year}/${entry.time.month.toString().padLeft(2, '0')}/${entry.time.day.toString().padLeft(2, '0')} '
                      '${entry.time.hour.toString().padLeft(2, '0')}:${entry.time.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                );
              },
            ),
    );
  }
}
