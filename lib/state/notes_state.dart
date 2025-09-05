import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteItem {
  final String id;
  final String text;
  final DateTime createdAt;

  const NoteItem({required this.id, required this.text, required this.createdAt});

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };

  static NoteItem fromJson(Map<String, dynamic> json) => NoteItem(
        id: json['id'] as String,
        text: json['text'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class NotesNotifier extends StateNotifier<List<NoteItem>> {
  NotesNotifier() : super(const []);

  static const _storageKey = 'notes_items_v1';

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final list = (json.decode(raw) as List).cast<Map<String, dynamic>>();
      state = list.map(NoteItem.fromJson).toList();
    }
  }

  Future<void> add(String text) async {
    final item = NoteItem(id: DateTime.now().millisecondsSinceEpoch.toString(), text: text, createdAt: DateTime.now());
    state = [...state, item];
    await _save();
  }

  Future<void> remove(String id) async {
    state = state.where((e) => e.id != id).toList();
    await _save();
  }

  Future<void> update(String id, String text) async {
    state = state
        .map((e) => e.id == id ? NoteItem(id: e.id, text: text, createdAt: e.createdAt) : e)
        .toList();
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, json.encode(state.map((e) => e.toJson()).toList()));
  }
}

final notesProvider = StateNotifierProvider<NotesNotifier, List<NoteItem>>((ref) {
  final notifier = NotesNotifier();
  notifier.initialize();
  return notifier;
});


