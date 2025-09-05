import 'dart:convert';

// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyGoals {
  final int pushUpsGoal;
  final int sitUpsGoal;
  final int squatsGoal;
  final int waterMlGoal;

  const DailyGoals({
    this.pushUpsGoal = 100,
    this.sitUpsGoal = 100,
    this.squatsGoal = 100,
    this.waterMlGoal = 2000,
  });
}

class DailyProgress {
  final int pushUps;
  final int sitUps;
  final int squats;
  final int waterMl;

  const DailyProgress({
    this.pushUps = 0,
    this.sitUps = 0,
    this.squats = 0,
    this.waterMl = 0,
  });

  DailyProgress copyWith({int? pushUps, int? sitUps, int? squats, int? waterMl}) => DailyProgress(
        pushUps: pushUps ?? this.pushUps,
        sitUps: sitUps ?? this.sitUps,
        squats: squats ?? this.squats,
        waterMl: waterMl ?? this.waterMl,
      );

  Map<String, dynamic> toJson() => {
        'pushUps': pushUps,
        'sitUps': sitUps,
        'squats': squats,
        'waterMl': waterMl,
      };

  static DailyProgress fromJson(Map<String, dynamic> json) => DailyProgress(
        pushUps: json['pushUps'] ?? 0,
        sitUps: json['sitUps'] ?? 0,
        squats: json['squats'] ?? 0,
        waterMl: json['waterMl'] ?? 0,
      );
}

class TrackerState {
  final DailyProgress progress;
  final bool initialized;
  final DailyGoals goals;

  const TrackerState({
    required this.progress,
    required this.goals,
    this.initialized = false,
  });

  double get pushUpsRatio => _ratio(progress.pushUps, goals.pushUpsGoal);
  double get sitUpsRatio => _ratio(progress.sitUps, goals.sitUpsGoal);
  double get squatsRatio => _ratio(progress.squats, goals.squatsGoal);
  double get waterRatio => _ratio(progress.waterMl, goals.waterMlGoal);

  TrackerState copyWith({DailyProgress? progress, bool? initialized, DailyGoals? goals}) => TrackerState(
        progress: progress ?? this.progress,
        goals: goals ?? this.goals,
        initialized: initialized ?? this.initialized,
      );

  static double _ratio(int value, int goal) => goal == 0 ? 0 : value / goal;
}

final goalsProvider = Provider<DailyGoals>((ref) => const DailyGoals());

class DailyNotifier extends StateNotifier<TrackerState> {
  DailyNotifier({required this.goals}) : super(TrackerState(progress: const DailyProgress(), goals: goals));

  final DailyGoals goals;
  static const _storageKeyPrefix = 'daily_progress_';

  String get _todayKey {
    final now = DateTime.now();
    return '$_storageKeyPrefix${now.year}-${now.month}-${now.day}';
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_todayKey);
    if (jsonString != null) {
      final map = json.decode(jsonString) as Map<String, dynamic>;
      final loaded = DailyProgress.fromJson(map);
      state = state.copyWith(progress: loaded, initialized: true);
    } else {
      state = state.copyWith(progress: const DailyProgress(), initialized: true);
      await _save();
    }
  }

  void addPushUps(int count) => _update(
        state.progress.copyWith(
          pushUps: _clamp(state.progress.pushUps + count, 0, goals.pushUpsGoal),
        ),
      );
  void addSitUps(int count) => _update(
        state.progress.copyWith(
          sitUps: _clamp(state.progress.sitUps + count, 0, goals.sitUpsGoal),
        ),
      );
  void addSquats(int count) => _update(
        state.progress.copyWith(
          squats: _clamp(state.progress.squats + count, 0, goals.squatsGoal),
        ),
      );
  void addWater(int ml) => _update(
        state.progress.copyWith(
          waterMl: _clamp(state.progress.waterMl + ml, 0, goals.waterMlGoal),
        ),
      );

  void resetToday() => _update(const DailyProgress());

  int _clamp(int value, int min, int max) => value < min ? min : (value > max ? max : value);

  Future<void> _update(DailyProgress next) async {
    state = state.copyWith(progress: next);
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_todayKey, json.encode(state.progress.toJson()));
  }
}

final dailyNotifierProvider = StateNotifierProvider<DailyNotifier, TrackerState>((ref) {
  final goals = ref.watch(goalsProvider);
  final notifier = DailyNotifier(goals: goals);
  notifier.initialize();
  return notifier;
});




