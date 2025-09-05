import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RunEntry {
  final DateTime date;
  final Duration duration;
  final double distanceMeters;

  const RunEntry({required this.date, required this.duration, required this.distanceMeters});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'duration': duration.inSeconds,
        'distanceMeters': distanceMeters,
      };

  static RunEntry fromJson(Map<String, dynamic> json) => RunEntry(
        date: DateTime.parse(json['date'] as String),
        duration: Duration(seconds: (json['duration'] as num).toInt()),
        distanceMeters: (json['distanceMeters'] as num).toDouble(),
      );
}

class RunHistoryNotifier extends StateNotifier<List<RunEntry>> {
  RunHistoryNotifier() : super(const []);

  static const _key = 'run_history_v1';

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final list = (json.decode(raw) as List).cast<Map<String, dynamic>>();
      state = list.map(RunEntry.fromJson).toList();
    }
  }

  Future<void> add(RunEntry entry) async {
    state = [...state, entry];
    await _save();
  }

  Future<void> clear() async {
    state = const [];
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(state.map((e) => e.toJson()).toList()));
  }
}

final runHistoryProvider = StateNotifierProvider<RunHistoryNotifier, List<RunEntry>>((ref) {
  final n = RunHistoryNotifier();
  n.initialize();
  return n;
});


