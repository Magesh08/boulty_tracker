import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/schedule_state.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduleProvider);
    final notifier = ref.read(scheduleProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Schedule'),
        actions: [
          IconButton(
            onPressed: notifier.resetWeek,
            tooltip: 'Reset Week',
            icon: const Icon(Icons.restore_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final day in Weekday.values)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(day.name.toUpperCase(), style: Theme.of(context).textTheme.titleSmall),
                              const SizedBox(height: 6),
                              TextField(
                                controller: TextEditingController(text: state.routines[day]?.title ?? ''),
                                decoration: const InputDecoration(hintText: 'Title'),
                                onSubmitted: (v) => notifier.setTitle(day, v),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          tooltip: 'Mark done',
                          onPressed: () => notifier.toggleCompleted(day),
                          icon: Icon(
                            state.routines[day]?.completed == true ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: state.routines[day]?.completed == true ? Colors.green : null,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Details', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 6),
                    Text(
                      state.routines[day]?.details ?? '',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final updated = await _editDetailsDialog(
                            context,
                            initial: state.routines[day]?.details ?? '',
                            title: state.routines[day]?.title ?? '',
                          );
                          if (updated != null) {
                            await notifier.setDetails(day, updated);
                          }
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Details'),
                      ),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<String?> _editDetailsDialog(BuildContext context, {required String initial, required String title}) async {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit: $title'),
        content: TextField(
          controller: controller,
          maxLines: 8,
          decoration: const InputDecoration(hintText: 'Enter detailed plan, sets/reps...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
        ],
      ),
    );
  }
}


