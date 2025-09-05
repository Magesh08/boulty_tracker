import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../state/timer_state.dart';
import '../state/run_state.dart';
import '../state/run_history_state.dart';

class RunScreen extends ConsumerWidget {
  const RunScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(timerProvider);
    final controller = ref.read(timerProvider.notifier);
    final run = ref.watch(runProvider);
    final runCtrl = ref.read(runProvider.notifier);
    final history = ref.read(runHistoryProvider.notifier);

    String format(Duration d) {
      final h = d.inHours;
      final m = d.inMinutes.remainder(60);
      final s = d.inSeconds.remainder(60);
      if (h > 0) {
        return '${NumberFormat('00').format(h)}:${NumberFormat('00').format(m)}:${NumberFormat('00').format(s)}';
      }
      return '${NumberFormat('00').format(m)}:${NumberFormat('00').format(s)}';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Run Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Timer', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(
                      format(timer.elapsed),
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: timer.running ? null : controller.start,
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('Start'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: timer.running ? controller.pause : null,
                            icon: const Icon(Icons.pause_rounded),
                            label: const Text('Pause'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: controller.reset,
                            icon: const Icon(Icons.stop_rounded),
                            label: const Text('Reset'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Distance', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text('${(run.distanceMeters / 1000).toStringAsFixed(2)} km',
                        style: Theme.of(context).textTheme.displaySmall),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: run.running ? null : runCtrl.start,
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('Start Run'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: run.running && !run.paused ? runCtrl.pause : (run.paused ? runCtrl.resume : null),
                            icon: Icon(run.paused ? Icons.play_arrow_rounded : Icons.pause_rounded),
                            label: Text(run.paused ? 'Resume' : 'Pause'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: run.running || run.paused
                                ? () {
                                    history.add(RunEntry(date: DateTime.now(), duration: run.elapsed, distanceMeters: run.distanceMeters));
                                    runCtrl.stop();
                                  }
                                : null,
                            icon: const Icon(Icons.stop_rounded),
                            label: const Text('Stop'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


