import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/daily_state.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Tracker'),
        actions: [
          IconButton(
            tooltip: 'Reset Today',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _showResetDialog(context, ref.read(dailyNotifierProvider.notifier)),
          )
        ],
      ),
      body: Builder(
        builder: (context) {
          final state = ref.watch(dailyNotifierProvider);
          final notifier = ref.read(dailyNotifierProvider.notifier);
          if (!state.initialized) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final totalProgress = (state.pushUpsRatio + state.sitUpsRatio + state.squatsRatio + state.waterRatio) / 4;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _GoalsHeader(colorScheme: colorScheme, textTheme: textTheme),
                const SizedBox(height: 12),
                _OverallProgressCard(
                  progress: totalProgress,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                const SizedBox(height: 12),
                _ProgressCard(
                  title: 'Push Ups',
                  value: state.progress.pushUps,
                  goal: state.goals.pushUpsGoal,
                  ratio: state.pushUpsRatio,
                  onIncrement: () => notifier.addPushUps(10),
                  onDecrement: () => notifier.addPushUps(-10),
                  icon: Icons.fitness_center,
                  color: Colors.orange,
                ),
                _ProgressCard(
                  title: 'Sit Ups',
                  value: state.progress.sitUps,
                  goal: state.goals.sitUpsGoal,
                  ratio: state.sitUpsRatio,
                  onIncrement: () => notifier.addSitUps(10),
                  onDecrement: () => notifier.addSitUps(-10),
                  icon: Icons.accessibility_new,
                  color: Colors.green,
                ),
                _ProgressCard(
                  title: 'Squats',
                  value: state.progress.squats,
                  goal: state.goals.squatsGoal,
                  ratio: state.squatsRatio,
                  onIncrement: () => notifier.addSquats(10),
                  onDecrement: () => notifier.addSquats(-10),
                  icon: Icons.directions_run,
                  color: Colors.blue,
                ),
                _WaterIntakeCard(
                  value: state.progress.waterMl,
                  goal: state.goals.waterMlGoal,
                  ratio: state.waterRatio,
                  onAdd: (ml) => notifier.addWater(ml),
                ),
                const SizedBox(height: 8),
                Text(
                  '💪 Tip: Tap + / - to adjust. Water adds 250ml quickly.',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showResetDialog(BuildContext context, DailyNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Today\'s Progress'),
        content: const Text('Are you sure you want to reset all progress for today? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              notifier.resetToday();
              Navigator.of(context).pop();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _GoalsHeader extends StatelessWidget {
  const _GoalsHeader({required this.colorScheme, required this.textTheme});
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primaryContainer, colorScheme.primaryContainer.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag_rounded, color: colorScheme.primary, size: 24),
              const SizedBox(width: 8),
              Text('Today\'s Goals', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _GoalChip(label: '100 Push Ups', icon: Icons.fitness_center),
              _GoalChip(label: '100 Sit Ups', icon: Icons.accessibility_new),
              _GoalChip(label: '100 Squats', icon: Icons.directions_run),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalChip extends StatelessWidget {
  const _GoalChip({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _OverallProgressCard extends StatelessWidget {
  const _OverallProgressCard({
    required this.progress,
    required this.colorScheme,
    required this.textTheme,
  });
  
  final double progress;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).round();
    final isComplete = progress >= 1.0;
    
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isComplete 
            ? LinearGradient(
                colors: [Colors.green.shade100, Colors.green.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overall Progress',
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (isComplete)
                  Icon(Icons.celebration, color: Colors.green, size: 24)
                else
                  Text(
                    '$percentage%',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 12,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isComplete ? Colors.green : colorScheme.primary,
                ),
              ),
            ),
            if (isComplete) ...[
              const SizedBox(height: 8),
              Text(
                '🎉 All goals completed for today!',
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.title,
    required this.value,
    required this.goal,
    required this.ratio,
    required this.onIncrement,
    required this.onDecrement,
    required this.icon,
    required this.color,
  });

  final String title;
  final int value;
  final int goal;
  final double ratio;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isComplete = ratio >= 1.0;
    
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: isComplete 
            ? Border.all(color: Colors.green.shade300, width: 2)
            : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 20),
                    const SizedBox(width: 8),
                    Text(title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '$value / $goal',
                      style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    if (isComplete) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ratio.clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isComplete ? Colors.green : color,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDecrement,
                    icon: const Icon(Icons.remove_rounded),
                    label: const Text('-10'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onIncrement,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('+10'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _WaterIntakeCard extends StatelessWidget {
  const _WaterIntakeCard({
    required this.value,
    required this.goal,
    required this.ratio,
    required this.onAdd,
  });

  final int value;
  final int goal;
  final double ratio;
  final void Function(int ml) onAdd;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isComplete = ratio >= 1.0;
    
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: isComplete 
            ? Border.all(color: Colors.green.shade300, width: 2)
            : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_drink_rounded, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text('Water Intake', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '${value}ml / ${goal}ml',
                      style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    if (isComplete) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ratio.clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isComplete ? Colors.green : Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onAdd(-250),
                    icon: const Icon(Icons.local_drink_outlined),
                    label: const Text('-250ml'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => onAdd(250),
                    icon: const Icon(Icons.local_drink_rounded),
                    label: const Text('+250ml'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
