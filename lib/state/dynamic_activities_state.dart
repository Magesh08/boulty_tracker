import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dynamic_activities.dart';

class DynamicActivitiesNotifier extends StateNotifier<List<DynamicActivity>> {
  DynamicActivitiesNotifier() : super([]);

  static const String _storageKey = 'dynamic_activities_v1';

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final list = (json.decode(raw) as List).cast<Map<String, dynamic>>();
      state = list.map(DynamicActivity.fromJson).toList();
    } else {
      // Initialize with default activities
      _initializeDefaultActivities();
    }
  }

  void _initializeDefaultActivities() {
    final defaultActivities = <DynamicActivity>[];
    for (final categoryActivities in ActivityCategories.defaultActivities.values) {
      defaultActivities.addAll(categoryActivities);
    }
    state = defaultActivities;
    _save();
  }

  Future<void> addActivity(DynamicActivity activity) async {
    state = [...state, activity];
    await _save();
  }

  Future<void> updateActivity(DynamicActivity activity) async {
    state = state.map((a) => a.id == activity.id ? activity : a).toList();
    await _save();
  }

  Future<void> removeActivity(String id) async {
    state = state.where((a) => a.id != id).toList();
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, json.encode(state.map((a) => a.toJson()).toList()));
  }

  List<DynamicActivity> getActivitiesByCategory(String category) {
    return state.where((activity) => activity.category == category && activity.isActive).toList();
  }
}

class ActivityEntriesNotifier extends StateNotifier<List<ActivityEntry>> {
  ActivityEntriesNotifier() : super([]);

  static const String _storageKey = 'activity_entries_v1';

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final list = (json.decode(raw) as List).cast<Map<String, dynamic>>();
      state = list.map(ActivityEntry.fromJson).toList();
    }
  }

  Future<void> addEntry(ActivityEntry entry) async {
    state = [...state, entry];
    await _save();
  }

  Future<void> updateEntry(ActivityEntry entry) async {
    state = state.map((e) => e.id == entry.id ? entry : e).toList();
    await _save();
  }

  Future<void> removeEntry(String id) async {
    state = state.where((e) => e.id != id).toList();
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, json.encode(state.map((e) => e.toJson()).toList()));
  }

  List<ActivityEntry> getEntriesForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return state.where((entry) {
      return entry.date.isAfter(startOfDay) && entry.date.isBefore(endOfDay);
    }).toList();
  }

  List<ActivityEntry> getEntriesForActivity(String activityId) {
    return state.where((entry) => entry.activityId == activityId).toList();
  }

  List<ActivityEntry> getEntriesForDateRange(DateTime start, DateTime end) {
    return state.where((entry) {
      return entry.date.isAfter(start) && entry.date.isBefore(end);
    }).toList();
  }
}

class WeeklyScheduleNotifier extends StateNotifier<List<WeeklySchedule>> {
  WeeklyScheduleNotifier() : super([]);

  static const String _storageKey = 'weekly_schedules_v1';

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final list = (json.decode(raw) as List).cast<Map<String, dynamic>>();
      state = list.map(WeeklySchedule.fromJson).toList();
    } else {
      // Initialize with default schedule
      _initializeDefaultSchedule();
    }
  }

  void _initializeDefaultSchedule() {
    final defaultSchedule = WeeklySchedule(
      id: 'default',
      name: 'Default Weekly Schedule',
      schedule: {
        'Monday': ['yoga', 'gym'],
        'Tuesday': ['running', 'meditation'],
        'Wednesday': ['cycling', 'yoga'],
        'Thursday': ['gym', 'music_listening'],
        'Friday': ['running', 'meditation'],
        'Saturday': ['yoga', 'cycling'],
        'Sunday': ['meditation', 'music_listening'],
      },
      createdAt: DateTime.now(),
    );
    state = [defaultSchedule];
    _save();
  }

  Future<void> addSchedule(WeeklySchedule schedule) async {
    state = [...state, schedule];
    await _save();
  }

  Future<void> updateSchedule(WeeklySchedule schedule) async {
    state = state.map((s) => s.id == schedule.id ? schedule : s).toList();
    await _save();
  }

  Future<void> removeSchedule(String id) async {
    state = state.where((s) => s.id != id).toList();
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, json.encode(state.map((s) => s.toJson()).toList()));
  }

  WeeklySchedule? getActiveSchedule() {
    return state.where((s) => s.isActive).firstOrNull;
  }
}

class MusicSessionsNotifier extends StateNotifier<List<MusicSession>> {
  MusicSessionsNotifier() : super([]);

  static const String _storageKey = 'music_sessions_v1';

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final list = (json.decode(raw) as List).cast<Map<String, dynamic>>();
      state = list.map(MusicSession.fromJson).toList();
    }
  }

  Future<void> addSession(MusicSession session) async {
    state = [...state, session];
    await _save();
  }

  Future<void> updateSession(MusicSession session) async {
    state = state.map((s) => s.id == session.id ? session : s).toList();
    await _save();
  }

  Future<void> removeSession(String id) async {
    state = state.where((s) => s.id != id).toList();
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, json.encode(state.map((s) => s.toJson()).toList()));
  }

  List<MusicSession> getSessionsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return state.where((session) {
      return session.date.isAfter(startOfDay) && session.date.isBefore(endOfDay);
    }).toList();
  }

  List<MusicSession> getSessionsForDateRange(DateTime start, DateTime end) {
    return state.where((session) {
      return session.date.isAfter(start) && session.date.isBefore(end);
    }).toList();
  }
}

// Providers
final dynamicActivitiesProvider = StateNotifierProvider<DynamicActivitiesNotifier, List<DynamicActivity>>((ref) {
  final notifier = DynamicActivitiesNotifier();
  notifier.initialize();
  return notifier;
});

final activityEntriesProvider = StateNotifierProvider<ActivityEntriesNotifier, List<ActivityEntry>>((ref) {
  final notifier = ActivityEntriesNotifier();
  notifier.initialize();
  return notifier;
});

final weeklyScheduleProvider = StateNotifierProvider<WeeklyScheduleNotifier, List<WeeklySchedule>>((ref) {
  final notifier = WeeklyScheduleNotifier();
  notifier.initialize();
  return notifier;
});

final musicSessionsProvider = StateNotifierProvider<MusicSessionsNotifier, List<MusicSession>>((ref) {
  final notifier = MusicSessionsNotifier();
  notifier.initialize();
  return notifier;
});

// Computed providers
final personalGrowthActivitiesProvider = Provider<List<DynamicActivity>>((ref) {
  final activities = ref.watch(dynamicActivitiesProvider);
  return activities.where((a) => a.category == 'personal_growth' && a.isActive).toList();
});

final fitnessActivitiesProvider = Provider<List<DynamicActivity>>((ref) {
  final activities = ref.watch(dynamicActivitiesProvider);
  return activities.where((a) => a.category == 'fitness' && a.isActive).toList();
});

final mindWellnessActivitiesProvider = Provider<List<DynamicActivity>>((ref) {
  final activities = ref.watch(dynamicActivitiesProvider);
  return activities.where((a) => a.category == 'mind_wellness' && a.isActive).toList();
});

final activeScheduleProvider = Provider<WeeklySchedule?>((ref) {
  final schedules = ref.watch(weeklyScheduleProvider);
  return schedules.where((s) => s.isActive).firstOrNull;
});
