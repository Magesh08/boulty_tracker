import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../state/timer_state.dart';
import '../state/run_state.dart';
import '../state/run_history_state.dart';

class RunScreen extends ConsumerStatefulWidget {
  const RunScreen({super.key});

  @override
  ConsumerState<RunScreen> createState() => _RunScreenState();
}

class _RunScreenState extends ConsumerState<RunScreen> {
  final List<Duration> _laps = <Duration>[];
  String _phase = 'Run'; // Warm-up | Run | Cool-down

  String _format(Duration d, {bool withMs = false}) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    final ms = d.inMilliseconds.remainder(1000) ~/ 10; // 2-digit centiseconds
    final base = h > 0
        ? '${NumberFormat('00').format(h)}:${NumberFormat('00').format(m)}:${NumberFormat('00').format(s)}'
        : '${NumberFormat('00').format(m)}:${NumberFormat('00').format(s)}';
    if (withMs) {
      return '$base:${NumberFormat('00').format(ms)}';
    }
    return base;
  }

  Map<String, dynamic> _computeStats(List<RunEntry> history) {
    final now = DateTime.now();
    final startToday = DateTime(now.year, now.month, now.day);
    final endToday = startToday.add(const Duration(days: 1));

    double todayMeters = 0;
    Duration todayDur = Duration.zero;

    for (final e in history) {
      if (e.date.isAfter(startToday) && e.date.isBefore(endToday)) {
        todayMeters += e.distanceMeters;
        todayDur += e.duration;
      }
    }
    return {
      'todayKm': todayMeters / 1000,
      'todayDur': todayDur,
    };
  }

  (String, String) _paceBadge(double meters, Duration dur) {
    if (meters <= 0 || dur.inSeconds <= 0) return ('—', '');
    final km = meters / 1000;
    final paceMinPerKm = dur.inMinutes / km + (dur.inSeconds % 60) / 60 / km;
    if (paceMinPerKm >= 8.0) return ('🐢', 'Turtle');
    if (paceMinPerKm >= 6.0) return ('🐇', 'Rabbit');
    if (paceMinPerKm >= 4.5) return ('🐆', 'Cheetah');
    return ('🚅', 'Bullet');
  }

  List<int> _computeSplitsSeconds(double meters, Duration duration) {
    final km = (meters / 1000).floor();
    if (km <= 0) return [];
    final paceSecPerKm = (duration.inSeconds / (meters / 1000));
    return List<int>.generate(km, (_) => paceSecPerKm.round());
  }

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(timerProvider);
    final controller = ref.read(timerProvider.notifier);
    final run = ref.watch(runProvider);
    final runCtrl = ref.read(runProvider.notifier);
    final historyList = ref.watch(runHistoryProvider);

    final stats = _computeStats(historyList);
    final (badgeIcon, badgeText) = _paceBadge(run.distanceMeters, run.elapsed == Duration.zero ? timer.elapsed : run.elapsed);

    final todayRuns = historyList.where((e) {
      final now = DateTime.now();
      final startToday = DateTime(now.year, now.month, now.day);
      final endToday = startToday.add(const Duration(days: 1));
      return e.date.isAfter(startToday) && e.date.isBefore(endToday);
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(title: const Text('Run Tracker')),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: ListView(
          children: [
            // Phase chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: ['Warm-up', 'Run', 'Cool-down'].map((p) {
                  final selected = _phase == p;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(p),
                      selected: selected,
                      onSelected: (_) => setState(() => _phase = p),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            // Stopwatch
            _buildTimerCard(context, timer, controller, run, runCtrl, badgeIcon, badgeText),
            const SizedBox(height: 16),
            // Distance controls
            _buildDistanceCard(context, run, runCtrl),
            const SizedBox(height: 16),
            // Today Stats
            _buildStatsCard(stats),
            const SizedBox(height: 16),
            // Today runs
            _buildTodayRuns(todayRuns),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _laps.add(timer.elapsed)),
        tooltip: 'Add Lap',
        child: const Icon(Icons.flag),
      ),
    );
  }

  Widget _buildTimerCard(
    BuildContext context,
    TimerState timer,
    TimerNotifier controller,
    RunState run,
    RunNotifier runCtrl,
    String badgeIcon,
    String badgeText,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Timer', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              _format(timer.elapsed, withMs: true),
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 6),
            if (badgeIcon != '—')
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(badgeIcon, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Text(badgeText, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: timer.running ? null : controller.start,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Start', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      minimumSize: const Size.fromHeight(40),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: timer.running ? controller.pause : null,
                    icon: const Icon(Icons.pause_rounded),
                    label: const Text('Pause', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      minimumSize: const Size.fromHeight(40),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _laps.add(timer.elapsed)),
                    icon: const Icon(Icons.flag_circle_outlined),
                    label: const Text('Lap', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      minimumSize: const Size.fromHeight(40),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() => _laps.clear());
                      controller.reset();
                    },
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Reset', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      minimumSize: const Size.fromHeight(40),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                children: _laps
                    .asMap()
                    .entries
                    .map((e) => Chip(label: Text('Lap ${e.key + 1}: ${_format(e.value, withMs: true)}')))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistanceCard(BuildContext context, RunState run, RunNotifier runCtrl) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Distance', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('${(run.distanceMeters / 1000).toStringAsFixed(2)} km', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: run.running ? null : runCtrl.start,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Start Run', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      minimumSize: const Size.fromHeight(40),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: run.running && !run.paused ? runCtrl.pause : (run.paused ? runCtrl.resume : null),
                    icon: Icon(run.paused ? Icons.play_arrow_rounded : Icons.pause_rounded),
                    label: Text(run.paused ? 'Resume' : 'Pause', style: const TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      minimumSize: const Size.fromHeight(40),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: run.running || run.paused
                        ? () {
                            final end = DateTime.now();
                            final splits = _computeSplitsSeconds(run.distanceMeters, run.elapsed);
                            ref.read(runHistoryProvider.notifier).add(
                                  RunEntry(
                                    date: end,
                                    duration: run.elapsed,
                                    distanceMeters: run.distanceMeters,
                                    startAt: run.startedAt,
                                    endAt: end,
                                    splitsSeconds: splits,
                                  ),
                                );
                            runCtrl.stop();
                          }
                        : null,
                    icon: const Icon(Icons.stop_rounded),
                    label: const Text('Stop', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      minimumSize: const Size.fromHeight(40),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(Map<String, dynamic> stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildStatTile('Today', '${(stats['todayKm'] as double).toStringAsFixed(2)} km', _format(stats['todayDur'] as Duration)),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayRuns(List<RunEntry> runs) {
    if (runs.isEmpty) {
      return const SizedBox();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Today\'s Runs', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...runs.map((r) {
              final start = r.startAt ?? r.date.subtract(r.duration);
              final end = r.endAt ?? r.date;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${(r.distanceMeters / 1000).toStringAsFixed(2)} km • ${_format(r.duration)}'),
                subtitle: Text('${DateFormat('hh:mm a').format(start)} - ${DateFormat('hh:mm a').format(end)}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showRunDetail(r),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showRunDetail(RunEntry r) {
    final start = r.startAt ?? r.date.subtract(r.duration);
    final end = r.endAt ?? r.date;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.directions_run),
                    const SizedBox(width: 8),
                    Text('${(r.distanceMeters / 1000).toStringAsFixed(2)} km', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text(_format(r.duration)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Start: ${DateFormat('EEE, MMM d • hh:mm a').format(start)}'),
                Text('End:   ${DateFormat('EEE, MMM d • hh:mm a').format(end)}'),
                const SizedBox(height: 12),
                const Text('Splits (per km):', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                if ((r.splitsSeconds ?? []).isEmpty)
                  const Text('— No splits available')
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (r.splitsSeconds ?? [])
                        .asMap()
                        .entries
                        .map((e) => Chip(label: Text('${e.key + 1}. ${_format(Duration(seconds: e.value))}')))
                        .toList(),
                  ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatTile(String title, String primary, String secondary) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(primary, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(secondary, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}


