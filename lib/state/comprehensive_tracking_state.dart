import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tracking_models.dart';

// Generic tracking state manager
class TrackingStateManager<T extends TrackingEntry> extends StateNotifier<List<T>> {
  final String storageKey;
  final T Function(Map<String, dynamic>) fromJson;

  TrackingStateManager({
    required this.storageKey,
    required this.fromJson,
  }) : super([]);

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw != null) {
      final list = (json.decode(raw) as List).cast<Map<String, dynamic>>();
      state = list.map(fromJson).toList();
    }
  }

  Future<void> add(T entry) async {
    state = [...state, entry];
    await _save();
  }

  Future<void> update(T entry) async {
    state = state.map((e) => e.id == entry.id ? entry : e).toList();
    await _save();
  }

  Future<void> remove(String id) async {
    state = state.where((e) => e.id != id).toList();
    await _save();
  }

  Future<void> clear() async {
    state = [];
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, json.encode(state.map((e) => e.toJson()).toList()));
  }

  // Get entries for a specific date
  List<T> getEntriesForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return state.where((entry) {
      return entry.date.isAfter(startOfDay) && entry.date.isBefore(endOfDay);
    }).toList();
  }

  // Get entries for a date range
  List<T> getEntriesForDateRange(DateTime start, DateTime end) {
    return state.where((entry) {
      return entry.date.isAfter(start) && entry.date.isBefore(end);
    }).toList();
  }

  // Get monthly entries
  List<T> getMonthlyEntries(int year, int month) {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 1);
    
    return getEntriesForDateRange(startOfMonth, endOfMonth);
  }
}

// Individual state managers for each tracking type
class ReadingStateManager extends TrackingStateManager<ReadingEntry> {
  ReadingStateManager() : super(
    storageKey: 'reading_entries_v1',
    fromJson: ReadingEntry.fromJson,
  );
}

class LanguageLearningStateManager extends TrackingStateManager<LanguageLearningEntry> {
  LanguageLearningStateManager() : super(
    storageKey: 'language_learning_entries_v1',
    fromJson: LanguageLearningEntry.fromJson,
  );
}

class CodingPracticeStateManager extends TrackingStateManager<CodingPracticeEntry> {
  CodingPracticeStateManager() : super(
    storageKey: 'coding_practice_entries_v1',
    fromJson: CodingPracticeEntry.fromJson,
  );
}

class JournalStateManager extends TrackingStateManager<JournalEntry> {
  JournalStateManager() : super(
    storageKey: 'journal_entries_v1',
    fromJson: JournalEntry.fromJson,
  );
}

class MorningStretchStateManager extends TrackingStateManager<MorningStretchEntry> {
  MorningStretchStateManager() : super(
    storageKey: 'morning_stretch_entries_v1',
    fromJson: MorningStretchEntry.fromJson,
  );
}

class WalkStateManager extends TrackingStateManager<WalkEntry> {
  WalkStateManager() : super(
    storageKey: 'walk_entries_v1',
    fromJson: WalkEntry.fromJson,
  );
}

class WorkoutStateManager extends TrackingStateManager<WorkoutEntry> {
  WorkoutStateManager() : super(
    storageKey: 'workout_entries_v1',
    fromJson: WorkoutEntry.fromJson,
  );
}

class WaterIntakeStateManager extends TrackingStateManager<WaterIntakeEntry> {
  WaterIntakeStateManager() : super(
    storageKey: 'water_intake_entries_v1',
    fromJson: WaterIntakeEntry.fromJson,
  );
}

class NutritionStateManager extends TrackingStateManager<NutritionEntry> {
  NutritionStateManager() : super(
    storageKey: 'nutrition_entries_v1',
    fromJson: NutritionEntry.fromJson,
  );
}

class MeditationStateManager extends TrackingStateManager<MeditationEntry> {
  MeditationStateManager() : super(
    storageKey: 'meditation_entries_v1',
    fromJson: MeditationEntry.fromJson,
  );
}

class GratitudeStateManager extends TrackingStateManager<GratitudeEntry> {
  GratitudeStateManager() : super(
    storageKey: 'gratitude_entries_v1',
    fromJson: GratitudeEntry.fromJson,
  );
}

class ScreenFreeTimeStateManager extends TrackingStateManager<ScreenFreeTimeEntry> {
  ScreenFreeTimeStateManager() : super(
    storageKey: 'screen_free_time_entries_v1',
    fromJson: ScreenFreeTimeEntry.fromJson,
  );
}

class DailyPlanningStateManager extends TrackingStateManager<DailyPlanningEntry> {
  DailyPlanningStateManager() : super(
    storageKey: 'daily_planning_entries_v1',
    fromJson: DailyPlanningEntry.fromJson,
  );
}

class UpskillingStateManager extends TrackingStateManager<UpskillingEntry> {
  UpskillingStateManager() : super(
    storageKey: 'upskilling_entries_v1',
    fromJson: UpskillingEntry.fromJson,
  );
}

class CodeCommitStateManager extends TrackingStateManager<CodeCommitEntry> {
  CodeCommitStateManager() : super(
    storageKey: 'code_commit_entries_v1',
    fromJson: CodeCommitEntry.fromJson,
  );
}

class NetworkingStateManager extends TrackingStateManager<NetworkingEntry> {
  NetworkingStateManager() : super(
    storageKey: 'networking_entries_v1',
    fromJson: NetworkingEntry.fromJson,
  );
}

class ExpenseStateManager extends TrackingStateManager<ExpenseEntry> {
  ExpenseStateManager() : super(
    storageKey: 'expense_entries_v1',
    fromJson: ExpenseEntry.fromJson,
  );
}

class SavingsStateManager extends TrackingStateManager<SavingsEntry> {
  SavingsStateManager() : super(
    storageKey: 'savings_entries_v1',
    fromJson: SavingsEntry.fromJson,
  );
}

class CleaningStateManager extends TrackingStateManager<CleaningEntry> {
  CleaningStateManager() : super(
    storageKey: 'cleaning_entries_v1',
    fromJson: CleaningEntry.fromJson,
  );
}

class SocialConnectionStateManager extends TrackingStateManager<SocialConnectionEntry> {
  SocialConnectionStateManager() : super(
    storageKey: 'social_connection_entries_v1',
    fromJson: SocialConnectionEntry.fromJson,
  );
}

class CookingStateManager extends TrackingStateManager<CookingEntry> {
  CookingStateManager() : super(
    storageKey: 'cooking_entries_v1',
    fromJson: CookingEntry.fromJson,
  );
}

class ShoppingControlStateManager extends TrackingStateManager<ShoppingControlEntry> {
  ShoppingControlStateManager() : super(
    storageKey: 'shopping_control_entries_v1',
    fromJson: ShoppingControlEntry.fromJson,
  );
}

// Providers for all state managers
final readingProvider = StateNotifierProvider<ReadingStateManager, List<ReadingEntry>>((ref) {
  final manager = ReadingStateManager();
  manager.initialize();
  return manager;
});

final languageLearningProvider = StateNotifierProvider<LanguageLearningStateManager, List<LanguageLearningEntry>>((ref) {
  final manager = LanguageLearningStateManager();
  manager.initialize();
  return manager;
});

final codingPracticeProvider = StateNotifierProvider<CodingPracticeStateManager, List<CodingPracticeEntry>>((ref) {
  final manager = CodingPracticeStateManager();
  manager.initialize();
  return manager;
});

final journalProvider = StateNotifierProvider<JournalStateManager, List<JournalEntry>>((ref) {
  final manager = JournalStateManager();
  manager.initialize();
  return manager;
});

final morningStretchProvider = StateNotifierProvider<MorningStretchStateManager, List<MorningStretchEntry>>((ref) {
  final manager = MorningStretchStateManager();
  manager.initialize();
  return manager;
});

final walkProvider = StateNotifierProvider<WalkStateManager, List<WalkEntry>>((ref) {
  final manager = WalkStateManager();
  manager.initialize();
  return manager;
});

final workoutProvider = StateNotifierProvider<WorkoutStateManager, List<WorkoutEntry>>((ref) {
  final manager = WorkoutStateManager();
  manager.initialize();
  return manager;
});

final waterIntakeProvider = StateNotifierProvider<WaterIntakeStateManager, List<WaterIntakeEntry>>((ref) {
  final manager = WaterIntakeStateManager();
  manager.initialize();
  return manager;
});

final nutritionProvider = StateNotifierProvider<NutritionStateManager, List<NutritionEntry>>((ref) {
  final manager = NutritionStateManager();
  manager.initialize();
  return manager;
});

final meditationProvider = StateNotifierProvider<MeditationStateManager, List<MeditationEntry>>((ref) {
  final manager = MeditationStateManager();
  manager.initialize();
  return manager;
});

final gratitudeProvider = StateNotifierProvider<GratitudeStateManager, List<GratitudeEntry>>((ref) {
  final manager = GratitudeStateManager();
  manager.initialize();
  return manager;
});

final screenFreeTimeProvider = StateNotifierProvider<ScreenFreeTimeStateManager, List<ScreenFreeTimeEntry>>((ref) {
  final manager = ScreenFreeTimeStateManager();
  manager.initialize();
  return manager;
});

final dailyPlanningProvider = StateNotifierProvider<DailyPlanningStateManager, List<DailyPlanningEntry>>((ref) {
  final manager = DailyPlanningStateManager();
  manager.initialize();
  return manager;
});

final upskillingProvider = StateNotifierProvider<UpskillingStateManager, List<UpskillingEntry>>((ref) {
  final manager = UpskillingStateManager();
  manager.initialize();
  return manager;
});

final codeCommitProvider = StateNotifierProvider<CodeCommitStateManager, List<CodeCommitEntry>>((ref) {
  final manager = CodeCommitStateManager();
  manager.initialize();
  return manager;
});

final networkingProvider = StateNotifierProvider<NetworkingStateManager, List<NetworkingEntry>>((ref) {
  final manager = NetworkingStateManager();
  manager.initialize();
  return manager;
});

final expenseProvider = StateNotifierProvider<ExpenseStateManager, List<ExpenseEntry>>((ref) {
  final manager = ExpenseStateManager();
  manager.initialize();
  return manager;
});

final savingsProvider = StateNotifierProvider<SavingsStateManager, List<SavingsEntry>>((ref) {
  final manager = SavingsStateManager();
  manager.initialize();
  return manager;
});

final cleaningProvider = StateNotifierProvider<CleaningStateManager, List<CleaningEntry>>((ref) {
  final manager = CleaningStateManager();
  manager.initialize();
  return manager;
});

final socialConnectionProvider = StateNotifierProvider<SocialConnectionStateManager, List<SocialConnectionEntry>>((ref) {
  final manager = SocialConnectionStateManager();
  manager.initialize();
  return manager;
});

final cookingProvider = StateNotifierProvider<CookingStateManager, List<CookingEntry>>((ref) {
  final manager = CookingStateManager();
  manager.initialize();
  return manager;
});

final shoppingControlProvider = StateNotifierProvider<ShoppingControlStateManager, List<ShoppingControlEntry>>((ref) {
  final manager = ShoppingControlStateManager();
  manager.initialize();
  return manager;
});

// Combined daily progress state
class DailyProgressState {
  final Map<String, bool> completedTasks;
  final Map<String, double> progressRatios;
  final DateTime date;

  const DailyProgressState({
    required this.completedTasks,
    required this.progressRatios,
    required this.date,
  });

  DailyProgressState copyWith({
    Map<String, bool>? completedTasks,
    Map<String, double>? progressRatios,
    DateTime? date,
  }) {
    return DailyProgressState(
      completedTasks: completedTasks ?? this.completedTasks,
      progressRatios: progressRatios ?? this.progressRatios,
      date: date ?? this.date,
    );
  }
}

class DailyProgressNotifier extends StateNotifier<DailyProgressState> {
  DailyProgressNotifier() : super(DailyProgressState(
    completedTasks: {},
    progressRatios: {},
    date: DateTime.now(),
  ));

  void updateProgress(String category, bool completed, double ratio) {
    final newCompletedTasks = Map<String, bool>.from(state.completedTasks);
    final newProgressRatios = Map<String, double>.from(state.progressRatios);
    
    newCompletedTasks[category] = completed;
    newProgressRatios[category] = ratio;
    
    state = state.copyWith(
      completedTasks: newCompletedTasks,
      progressRatios: newProgressRatios,
    );
  }

  double get overallProgress {
    if (state.progressRatios.isEmpty) return 0.0;
    final total = state.progressRatios.values.reduce((a, b) => a + b);
    return total / state.progressRatios.length;
  }

  int get completedTasksCount {
    return state.completedTasks.values.where((completed) => completed).length;
  }

  int get totalTasksCount {
    return state.completedTasks.length;
  }
}

final dailyProgressProvider = StateNotifierProvider<DailyProgressNotifier, DailyProgressState>((ref) {
  return DailyProgressNotifier();
});

// Monthly analytics state
class MonthlyAnalytics {
  final int year;
  final int month;
  final Map<String, int> categoryCounts;
  final Map<String, double> categoryTotals;
  final Map<String, List<DateTime>> activityDays;

  const MonthlyAnalytics({
    required this.year,
    required this.month,
    required this.categoryCounts,
    required this.categoryTotals,
    required this.activityDays,
  });
}

class MonthlyAnalyticsNotifier extends StateNotifier<MonthlyAnalytics?> {
  MonthlyAnalyticsNotifier() : super(null);

  void calculateAnalytics(int year, int month, WidgetRef ref) {
    final categories = TrackingCategories.all;
    final categoryCounts = <String, int>{};
    final categoryTotals = <String, double>{};
    final activityDays = <String, List<DateTime>>{};

    for (final category in categories) {
      categoryCounts[category.id] = 0;
      categoryTotals[category.id] = 0.0;
      activityDays[category.id] = [];
    }

    // Calculate analytics for each category
    // This would be implemented based on the specific tracking data
    // For now, we'll create a placeholder structure

    state = MonthlyAnalytics(
      year: year,
      month: month,
      categoryCounts: categoryCounts,
      categoryTotals: categoryTotals,
      activityDays: activityDays,
    );
  }
}

final monthlyAnalyticsProvider = StateNotifierProvider<MonthlyAnalyticsNotifier, MonthlyAnalytics?>((ref) {
  return MonthlyAnalyticsNotifier();
});
