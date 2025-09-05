import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/daily_state.dart';
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
          if (!state.initialized) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final totalProgress = (state.pushUpsRatio + state.sitUpsRatio + state.squatsRatio + state.waterRatio) / 4;
          
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
                  'Hello Amir! 💪',
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
}

