import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/daily_state.dart';
import '../state/run_history_state.dart';
import '../models/tracking_models.dart';
import '../widgets/tracking_category_card.dart';
import '../screens/enhanced_expense_tracker_screen.dart';
import '../screens/dynamic_activities_screen.dart';
import '../theme/design_system.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Builder(
        builder: (context) {
          final state = ref.watch(dailyNotifierProvider);
          final notifier = ref.read(dailyNotifierProvider.notifier);
          final runHistory = ref.watch(runHistoryProvider);
          if (!state.initialized) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final totalProgress = (state.pushUpsRatio + state.sitUpsRatio + state.squatsRatio + state.waterRatio) / 4;
          final todaysRun = _getTodaysRun(runHistory);
          
          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, ref, totalProgress),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeHeader(),
                      const SizedBox(height: 24),
                      _buildOverallProgressCard(totalProgress),
                      const SizedBox(height: 20),
                      _buildTodaysRunSection(context, todaysRun),
                      const SizedBox(height: 20),
                      _buildComprehensiveTrackingSection(context),
                      const SizedBox(height: 20),
                      _buildTasksSection(state, notifier),
                      const SizedBox(height: 20),
                      _buildMotivationalTip(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, WidgetRef ref, double totalProgress) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667EEA),
                Color(0xFF764BA2),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Track Your Day',
                        style: DesignSystem.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(totalProgress * 100).round()}% Complete',
                        style: DesignSystem.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => _showResetDialog(context, ref.read(dailyNotifierProvider.notifier)),
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF6B6B),
            Color(0xFFFF8E53),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello Magesh! 💪',
                  style: DesignSystem.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ready to crush your fitness goals today?',
                  style: DesignSystem.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallProgressCard(double progress) {
    final percentage = (progress * 100).round();
    final isComplete = progress >= 1.0;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Progress',
                style: DesignSystem.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),
              if (isComplete)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Complete!',
                        style: DesignSystem.textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  strokeWidth: 8,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isComplete ? Colors.green : const Color(0xFF667EEA),
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    '$percentage%',
                    style: DesignSystem.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isComplete ? Colors.green : const Color(0xFF667EEA),
                    ),
                  ),
                  Text(
                    'Complete',
                    style: DesignSystem.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF718096),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTasksSection(TrackerState state, DailyNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Tasks',
          style: DesignSystem.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        _buildTaskCard(
          title: 'Push Ups',
          value: state.progress.pushUps,
          goal: state.goals.pushUpsGoal,
          ratio: state.pushUpsRatio,
          onIncrement: () => notifier.addPushUps(10),
          onDecrement: () => notifier.addPushUps(-10),
          icon: Icons.fitness_center,
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
          ),
        ),
        const SizedBox(height: 12),
        _buildTaskCard(
          title: 'Sit Ups',
          value: state.progress.sitUps,
          goal: state.goals.sitUpsGoal,
          ratio: state.sitUpsRatio,
          onIncrement: () => notifier.addSitUps(10),
          onDecrement: () => notifier.addSitUps(-10),
          icon: Icons.accessibility_new,
          gradient: const LinearGradient(
            colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
          ),
        ),
        const SizedBox(height: 12),
        _buildTaskCard(
          title: 'Squats',
          value: state.progress.squats,
          goal: state.goals.squatsGoal,
          ratio: state.squatsRatio,
          onIncrement: () => notifier.addSquats(10),
          onDecrement: () => notifier.addSquats(-10),
          icon: Icons.directions_run,
          gradient: const LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
        ),
        const SizedBox(height: 12),
        _buildWaterCard(
          value: state.progress.waterMl,
          goal: state.goals.waterMlGoal,
          ratio: state.waterRatio,
          onAdd: (ml) => notifier.addWater(ml),
        ),
      ],
    );
  }

  Widget _buildTaskCard({
    required String title,
    required int value,
    required int goal,
    required double ratio,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required IconData icon,
    required LinearGradient gradient,
  }) {
    final isComplete = ratio >= 1.0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: isComplete 
          ? Border.all(color: Colors.green.withOpacity(0.3), width: 2)
          : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: DesignSystem.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$value / $goal',
                      style: DesignSystem.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ),
              if (isComplete)
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 18),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(
                isComplete ? Colors.green : gradient.colors.first,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  onPressed: onDecrement,
                  icon: Icons.remove_rounded,
                  label: '-10',
                  isPrimary: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  onPressed: onIncrement,
                  icon: Icons.add_rounded,
                  label: '+10',
                  isPrimary: true,
                  gradient: gradient,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaterCard({
    required int value,
    required int goal,
    required double ratio,
    required void Function(int ml) onAdd,
  }) {
    final isComplete = ratio >= 1.0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: isComplete 
          ? Border.all(color: Colors.green.withOpacity(0.3), width: 2)
          : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF36D1DC), Color(0xFF5B86E5)],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: const Icon(Icons.local_drink_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Water Intake',
                      style: DesignSystem.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${value}ml / ${goal}ml',
                      style: DesignSystem.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ),
              if (isComplete)
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 18),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(
                isComplete ? Colors.green : const Color(0xFF36D1DC),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  onPressed: () => onAdd(-250),
                  icon: Icons.local_drink_outlined,
                  label: '-250ml',
                  isPrimary: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  onPressed: () => onAdd(250),
                  icon: Icons.local_drink_rounded,
                  label: '+250ml',
                  isPrimary: true,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF36D1DC), Color(0xFF5B86E5)],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required bool isPrimary,
    LinearGradient? gradient,
  }) {
    if (isPrimary && gradient != null) {
      return Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: DesignSystem.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF718096),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildMotivationalTip() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '💪 Tip: Stay consistent! Small daily progress leads to big results.',
              style: DesignSystem.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, DailyNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Reset Today\'s Progress',
          style: DesignSystem.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to reset all progress for today? This cannot be undone.',
          style: DesignSystem.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF718096),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              notifier.resetToday();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  RunEntry? _getTodaysRun(List<RunEntry> runHistory) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    
    for (final run in runHistory) {
      if (run.date.isAfter(todayStart) && run.date.isBefore(todayEnd)) {
        return run;
      }
    }
    return null;
  }

  Widget _buildTodaysRunSection(BuildContext context, RunEntry? todaysRun) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Run',
          style: DesignSystem.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
            border: todaysRun != null 
              ? Border.all(color: Colors.green.withOpacity(0.3), width: 2)
              : null,
          ),
          child: todaysRun != null 
            ? _buildCompletedRunCard(todaysRun)
            : _buildNoRunCard(context),
        ),
      ],
    );
  }

  Widget _buildCompletedRunCard(RunEntry run) {
    final duration = run.duration;
    final distance = run.distanceMeters / 1000; // Convert to km
    final pace = duration.inMinutes / distance; // Minutes per km
    
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: const Icon(Icons.directions_run, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Run Completed! 🎉',
                    style: DesignSystem.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Great job on your run today!',
                    style: DesignSystem.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF718096),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildRunStat(
                'Distance',
                '${distance.toStringAsFixed(2)} km',
                Icons.straighten,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildRunStat(
                'Duration',
                '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                Icons.timer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildRunStat(
                'Pace',
                '${pace.toStringAsFixed(1)} min/km',
                Icons.speed,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoRunCard(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6B7280), Color(0xFF4B5563)],
                ),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: const Icon(Icons.directions_run, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No Run Today',
                    style: DesignSystem.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ready to go for a run?',
                    style: DesignSystem.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF718096),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // Navigate to run screen by changing the bottom navigation index
              _navigateToRunScreen(context);
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start Run'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRunStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF10B981), size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: DesignSystem.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),
          Text(
            label,
            style: DesignSystem.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToRunScreen(BuildContext context) {
    // For now, we'll show a snackbar indicating the user should use the bottom navigation
    // In a real app, you might use a navigation provider or callback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Use the bottom navigation to go to the Run screen'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildComprehensiveTrackingSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Life Tracking',
              style: DesignSystem.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D3748),
              ),
            ),
            TextButton.icon(
              onPressed: () => _showAllCategories(context),
              icon: const Icon(Icons.grid_view, size: 18),
              label: const Text('View All'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF667EEA),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Show first 3 categories as preview
        ...TrackingCategories.all.take(3).map((category) {
          return TrackingCategoryCard(
            category: category,
            completedCount: _getCompletedCountForCategory(category.id),
            totalCount: category.subcategories.length,
            progress: _getProgressForCategory(category.id),
            onTap: () => _navigateToCategory(context, category),
          );
        }).toList(),
        const SizedBox(height: 12),
        // Quick access to expense tracker
        Container(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const EnhancedExpenseTrackerScreen()),
            ),
            icon: const Icon(Icons.account_balance_wallet),
            label: const Text('💵 Expense Tracker'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  int _getCompletedCountForCategory(String categoryId) {
    // This would be implemented based on actual tracking data
    // For now, return a placeholder value
    switch (categoryId) {
      case 'personal_growth':
        return 2;
      case 'health_fitness':
        return 3;
      case 'mind_mental_health':
        return 1;
      default:
        return 0;
    }
  }

  double _getProgressForCategory(String categoryId) {
    // This would be implemented based on actual tracking data
    // For now, return a placeholder value
    switch (categoryId) {
      case 'personal_growth':
        return 0.5; // 2/4 completed
      case 'health_fitness':
        return 0.6; // 3/5 completed
      case 'mind_mental_health':
        return 0.33; // 1/3 completed
      default:
        return 0.0;
    }
  }

  void _navigateToCategory(BuildContext context, TrackingCategory category) {
    // Navigate to dynamic activities screen based on category
    String categoryId;
    switch (category.id) {
      case 'personal_growth':
        categoryId = 'personal_growth';
        break;
      case 'health_fitness':
        categoryId = 'fitness';
        break;
      case 'mind_mental_health':
        categoryId = 'mind_wellness';
        break;
      default:
        categoryId = 'personal_growth';
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DynamicActivitiesScreen(category: categoryId),
      ),
    );
  }

  void _showAllCategories(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'All Categories',
                style: DesignSystem.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: TrackingCategories.all.length,
                itemBuilder: (context, index) {
                  final category = TrackingCategories.all[index];
                  return TrackingCategoryCard(
                    category: category,
                    completedCount: _getCompletedCountForCategory(category.id),
                    totalCount: category.subcategories.length,
                    progress: _getProgressForCategory(category.id),
                    onTap: () {
                      Navigator.of(context).pop();
                      _navigateToCategory(context, category);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

