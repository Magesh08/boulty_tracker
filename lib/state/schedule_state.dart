import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Weekday { mon, tue, wed, thu, fri, sat, sun }

class DayRoutine {
  final String title;
  final String details;
  final bool completed;
  const DayRoutine({required this.title, required this.details, required this.completed});

  DayRoutine copyWith({String? title, String? details, bool? completed}) =>
      DayRoutine(title: title ?? this.title, details: details ?? this.details, completed: completed ?? this.completed);

  Map<String, dynamic> toJson() => {'title': title, 'details': details, 'completed': completed};
  static DayRoutine fromJson(Map<String, dynamic> json) =>
      DayRoutine(
        title: (json['title'] as String?) ?? '',
        details: (json['details'] as String?) ?? '',
        completed: (json['completed'] as bool?) ?? false,
      );
}

class ScheduleState {
  final Map<Weekday, DayRoutine> routines;
  const ScheduleState({required this.routines});

  ScheduleState copyWith({Map<Weekday, DayRoutine>? routines}) =>
      ScheduleState(routines: routines ?? this.routines);
}

class ScheduleNotifier extends StateNotifier<ScheduleState> {
  ScheduleNotifier()
      : super(ScheduleState(routines: {
          Weekday.mon: const DayRoutine(
            title: 'Push (Chest, Shoulders, Triceps)',
            details:
                'Bench Press, Incline Dumbbell Press, Dumbbell Shoulder Press, Dips, Cable Lateral Raises, EZ Bar Skull Crushers. 3–4 sets, 6–15 reps.',
            completed: false,
          ),
          Weekday.tue: const DayRoutine(
            title: 'Pull (Back, Biceps)',
            details:
                'Bent-Over Barbell Rows, Pull-Ups/Lat Pulldowns, Seated Cable Rows, Barbell Curls, Hammer Curls, Face Pulls. 3–4 sets, 8–15 reps.',
            completed: false,
          ),
          Weekday.wed: const DayRoutine(
            title: 'Legs & Core',
            details:
                'Barbell Squats, Romanian Deadlifts, Leg Press, Walking Lunges, Standing Calf Raises (3–5 sets, 8–15 reps). Core: pick 3 (Plank, Russian Twists, Leg Raises) for 3 sets.',
            completed: false,
          ),
          Weekday.thu: const DayRoutine(
            title: 'Push (Chest, Shoulders, Triceps)',
            details:
                'Standing Barbell Shoulder Press, Flat DB Bench, Arnold Press, Close-Grip Bench, Pec Deck/Cable Crossover, Overhead Triceps Extensions. 3–4 sets, 8–15 reps.',
            completed: false,
          ),
          Weekday.fri: const DayRoutine(
            title: 'Pull (Back, Biceps)',
            details:
                'Deadlifts, T‑Bar Rows, Seated DB Rows, DB Shrugs, Preacher Curls, Concentration Curls. 3–4 sets, 6–12 reps.',
            completed: false,
          ),
          Weekday.sat: const DayRoutine(
            title: 'Legs & Core',
            details:
                'Romanian Deadlifts, Bulgarian Split Squats, Leg Extensions, Hamstring Curls, Seated Calf Raises (3–5 sets, 8–15 reps). Core: Reverse Crunches, Ab Wheel, Cable Crunches (3 sets).',
            completed: false,
          ),
          Weekday.sun: const DayRoutine(
            title: 'Rest or Active Recovery',
            details: 'Light walk, stretching, yoga, or full rest.',
            completed: false,
          ),
        }));

  static const _key = 'weekly_schedule_v1';

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final map = (json.decode(raw) as Map<String, dynamic>);
      final next = <Weekday, DayRoutine>{};
      for (final e in map.entries) {
        final day = Weekday.values.firstWhere((w) => w.name == e.key);
        next[day] = DayRoutine.fromJson(e.value as Map<String, dynamic>);
      }
      state = state.copyWith(routines: next);
    }
  }

  Future<void> setTitle(Weekday day, String title) async {
    final updated = Map<Weekday, DayRoutine>.from(state.routines);
    updated[day] = (updated[day] ?? const DayRoutine(title: '', details: '', completed: false)).copyWith(title: title);
    state = state.copyWith(routines: updated);
    await _save();
  }

  Future<void> setDetails(Weekday day, String details) async {
    final updated = Map<Weekday, DayRoutine>.from(state.routines);
    updated[day] = (updated[day] ?? const DayRoutine(title: '', details: '', completed: false)).copyWith(details: details);
    state = state.copyWith(routines: updated);
    await _save();
  }

  Future<void> toggleCompleted(Weekday day) async {
    final updated = Map<Weekday, DayRoutine>.from(state.routines);
    final cur = updated[day] ?? const DayRoutine(title: '', details: '', completed: false);
    updated[day] = cur.copyWith(completed: !cur.completed);
    state = state.copyWith(routines: updated);
    await _save();
  }

  Future<void> resetWeek() async {
    state = ScheduleState(routines: {
      for (final d in Weekday.values) d: state.routines[d]!.copyWith(completed: false)
    });
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final map = {
      for (final e in state.routines.entries) e.key.name: e.value.toJson(),
    };
    await prefs.setString(_key, json.encode(map));
  }
}

final scheduleProvider = StateNotifierProvider<ScheduleNotifier, ScheduleState>((ref) {
  final n = ScheduleNotifier();
  n.initialize();
  return n;
});


