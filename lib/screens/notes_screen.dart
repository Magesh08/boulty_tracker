import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../state/notes_state.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    final notifier = ref.read(notesProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final item = notes[index];
          return Dismissible(
            key: ValueKey(item.id),
            background: Container(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.error, borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            secondaryBackground: Container(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.error, borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerRight,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => notifier.remove(item.id),
            child: Card(
              child: ListTile(
                title: Text(item.text),
                subtitle: Text(DateFormat.yMMMd().add_jm().format(item.createdAt)),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final updated = await _showNoteDialog(context, initial: item.text);
                    if (updated != null && updated.trim().isNotEmpty) {
                      notifier.update(item.id, updated.trim());
                    }
                  },
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemCount: notes.length,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final text = await _showNoteDialog(context);
          if (text != null && text.trim().isNotEmpty) {
            notifier.add(text.trim());
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<String?> _showNoteDialog(BuildContext context, {String? initial}) async {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(initial == null ? 'New Note' : 'Edit Note'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(hintText: 'Write your note...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
        ],
      ),
    );
  }
}


