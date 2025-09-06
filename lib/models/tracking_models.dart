
// Base tracking entry model
abstract class TrackingEntry {
  final String id;
  final DateTime date;
  final String category;
  final String? notes;

  const TrackingEntry({
    required this.id,
    required this.date,
    required this.category,
    this.notes,
  });

  Map<String, dynamic> toJson();
}

// Personal Growth & Learning
class ReadingEntry extends TrackingEntry {
  final int minutesRead;
  final String? bookTitle;
  final int? pagesRead;

  const ReadingEntry({
    required super.id,
    required super.date,
    required this.minutesRead,
    this.bookTitle,
    this.pagesRead,
    super.notes,
  }) : super(category: 'reading');

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'category': category,
    'minutesRead': minutesRead,
    'bookTitle': bookTitle,
    'pagesRead': pagesRead,
    'notes': notes,
  };

  static ReadingEntry fromJson(Map<String, dynamic> json) => ReadingEntry(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    minutesRead: json['minutesRead'] as int,
    bookTitle: json['bookTitle'] as String?,
    pagesRead: json['pagesRead'] as int?,
    notes: json['notes'] as String?,
  );
}

class LanguageLearningEntry extends TrackingEntry {
  final int minutesSpent;
  final String language;
  final int? lessonsCompleted;
  final int? streakDays;

  const LanguageLearningEntry({
    required super.id,
    required super.date,
    required this.minutesSpent,
    required this.language,
    this.lessonsCompleted,
    this.streakDays,
    super.notes,
  }) : super(category: 'language_learning');

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'category': category,
    'minutesSpent': minutesSpent,
    'language': language,
    'lessonsCompleted': lessonsCompleted,
    'streakDays': streakDays,
    'notes': notes,
  };

  static LanguageLearningEntry fromJson(Map<String, dynamic> json) => LanguageLearningEntry(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    minutesSpent: json['minutesSpent'] as int,
    language: json['language'] as String,
    lessonsCompleted: json['lessonsCompleted'] as int?,
    streakDays: json['streakDays'] as int?,
    notes: json['notes'] as String?,
  );
}

class CodingPracticeEntry extends TrackingEntry {
  final int minutesSpent;
  final String platform; // LeetCode, Flutter, etc.
  final int? problemsSolved;
  final String? difficulty;

  const CodingPracticeEntry({
    required super.id,
    required super.date,
    required this.minutesSpent,
    required this.platform,
    this.problemsSolved,
    this.difficulty,
    super.notes,
  }) : super(category: 'coding_practice');

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'category': category,
    'minutesSpent': minutesSpent,
    'platform': platform,
    'problemsSolved': problemsSolved,
    'difficulty': difficulty,
    'notes': notes,
  };

  static CodingPracticeEntry fromJson(Map<String, dynamic> json) => CodingPracticeEntry(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    minutesSpent: json['minutesSpent'] as int,
    platform: json['platform'] as String,
    problemsSolved: json['problemsSolved'] as int?,
    difficulty: json['difficulty'] as String?,
    notes: json['notes'] as String?,
  );
}

class JournalEntry extends TrackingEntry {
  final List<String> thingsLearned;
  final String? mood;
  final int? rating; // 1-10

  const JournalEntry({
    required super.id,
    required super.date,
    required this.thingsLearned,
    this.mood,
    this.rating,
    super.notes,
  }) : super(category: 'journaling');

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'category': category,
    'thingsLearned': thingsLearned,
    'mood': mood,
    'rating': rating,
    'notes': notes,
  };

  static JournalEntry fromJson(Map<String, dynamic> json) => JournalEntry(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    thingsLearned: List<String>.from(json['thingsLearned'] as List),
    mood: json['mood'] as String?,
    rating: json['rating'] as int?,
    notes: json['notes'] as String?,
  );
}

// Health & Fitness
class MorningStretchEntry extends TrackingEntry {
  final int minutesSpent;
  final String? type; // yoga, stretching, etc.
  final int? rating; // 1-10

  const MorningStretchEntry({
    required super.id,
    required super.date,
    required this.minutesSpent,
    this.type,
    this.rating,
    super.notes,
  }) : super(category: 'morning_stretch');

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'category': category,
    'minutesSpent': minutesSpent,
    'type': type,
    'rating': rating,
    'notes': notes,
  };

  static MorningStretchEntry fromJson(Map<String, dynamic> json) => MorningStretchEntry(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    minutesSpent: json['minutesSpent'] as int,
    type: json['type'] as String?,
    rating: json['rating'] as int?,
    notes: json['notes'] as String?,
  );
}

class WalkEntry extends TrackingEntry {
  final int steps;
  final int minutesSpent;
  final double? distanceKm;
  final int? caloriesBurned;

  const WalkEntry({
    required super.id,
    required super.date,
    required this.steps,
    required this.minutesSpent,
    this.distanceKm,
    this.caloriesBurned,
    super.notes,
  }) : super(category: 'walk');

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'category': category,
    'steps': steps,
    'minutesSpent': minutesSpent,
    'distanceKm': distanceKm,
    'caloriesBurned': caloriesBurned,
    'notes': notes,
  };

  static WalkEntry fromJson(Map<String, dynamic> json) => WalkEntry(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    steps: json['steps'] as int,
    minutesSpent: json['minutesSpent'] as int,
    distanceKm: json['distanceKm'] as double?,
    caloriesBurned: json['caloriesBurned'] as int?,
    notes: json['notes'] as String?,
  );
}

class WorkoutEntry extends TrackingEntry {
  final int minutesSpent;
  final String type; // strength, cardio, etc.
  final int? caloriesBurned;
  final String? exercises;

  const WorkoutEntry({
    required super.id,
    required super.date,
    required this.minutesSpent,
    required this.type,
    this.caloriesBurned,
    this.exercises,
    super.notes,
  }) : super(category: 'workout');

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'category': category,
    'minutesSpent': minutesSpent,
    'type': type,
    'caloriesBurned': caloriesBurned,
    'exercises': exercises,
    'notes': notes,
  };

  static WorkoutEntry fromJson(Map<String, dynamic> json) => WorkoutEntry(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    minutesSpent: json['minutesSpent'] as int,
    type: json['type'] as String,
    caloriesBurned: json['caloriesBurned'] as int?,
    exercises: json['exercises'] as String?,
    notes: json['notes'] as String?,
  );
}

class WaterIntakeEntry extends TrackingEntry {
  final int milliliters;
  final int glasses; // 1 glass = 250ml

  const WaterIntakeEntry({
    required super.id,
    required super.date,
    required this.milliliters,
    required this.glasses,
    super.notes,
  }) : super(category: 'water_intake');

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'category': category,
    'milliliters': milliliters,
    'glasses': glasses,
    'notes': notes,
  };

  static WaterIntakeEntry fromJson(Map<String, dynamic> json) => WaterIntakeEntry(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    milliliters: json['milliliters'] as int,
    glasses: json['glasses'] as int,
    notes: json['notes'] as String?,
  );
}

class NutritionEntry extends TrackingEntry {
  final List<String> fruitsVegetables;
  final bool avoidedJunkFood;
  final int? mealsCookedAtHome;
  final int? rating; // 1-10

  const NutritionEntry({
    required super.id,
    required super.date,
    required this.fruitsVegetables,
    required this.avoidedJunkFood,
    this.mealsCookedAtHome,
    this.rating,
    super.notes,
  }) : super(category: 'nutrition');

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'category': category,
    'fruitsVegetables': fruitsVegetables,
    'avoidedJunkFood': avoidedJunkFood,
    'mealsCookedAtHome': mealsCookedAtHome,
    'rating': rating,
    'notes': notes,
  };

  static NutritionEntry fromJson(Map<String, dynamic> json) => NutritionEntry(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    fruitsVegetables: List<String>.from(json['fruitsVegetables'] as List),
    avoidedJunkFood: json['avoidedJunkFood'] as bool,
    mealsCookedAtHome: json['mealsCookedAtHome'] as int?,
    rating: json['rating'] as int?,
    notes: json['notes'] as String?,
  );
}

// Mind & Mental Health
class MeditationEntry extends TrackingEntry {
  final int minutesSpent;
  final String? type; // mindfulness, breathing, etc.
  final int? rating; // 1-10

  const MeditationEntry({
    required super.id,
    required super.date,
    required this.minutesSpent,
    this.type,
    this.rating,
    super.notes,
  }) : super(category: 'meditation');

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'category': category,
    'minutesSpent': minutesSpent,
    'type': type,
    'rating': rating,
    'notes': notes,
  };

  static MeditationEntry fromJson(Map<String, dynamic> json) => MeditationEntry(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    minutesSpent: json['minutesSpent'] as int,
    type: json['type'] as String?,
    rating: json['rating'] as int?,
    notes: json['notes'] as String?,
  );
}

class GratitudeEntry extends TrackingEntry {
  final List<String> gratefulFor;
  final int? rating; // 1-10

  const GratitudeEntry({
    required super.id,
    required super.date,
    required this.gratefulFor,
    this.rating,
    super.notes,
  }) : super(category: 'gratitude');

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'category': category,
    'gratefulFor': gratefulFor,
    'rating': rating,
    'notes': notes,
  };

  static GratitudeEntry fromJson(Map<String, dynamic> json) => GratitudeEntry(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    gratefulFor: List<String>.from(json['gratefulFor'] as List),
    rating: json['rating'] as int?,
    notes: json['notes'] as String?,
  );
}

class ScreenFreeTimeEntry extends TrackingEntry {
  final int minutesBeforeBed;
  final bool noPhoneBeforeBed;
  final int? sleepHours;

  const ScreenFreeTimeEntry({
    required super.id,
    required super.date,
    required this.minutesBeforeBed,
    required this.noPhoneBeforeBed,
    this.sleepHours,
    super.notes,
  }) : super(category: 'screen_free_time');

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'category': category,
    'minutesBeforeBed': minutesBeforeBed,
    'noPhoneBeforeBed': noPhoneBeforeBed,
    'sleepHours': sleepHours,
    'notes': notes,
  };

  static ScreenFreeTimeEntry fromJson(Map<String, dynamic> json) => ScreenFreeTimeEntry(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    minutesBeforeBed: json['minutesBeforeBed'] as int,
    noPhoneBeforeBed: json['noPhoneBeforeBed'] as bool,
    sleepHours: json['sleepHours'] as int?,
    notes: json['notes'] as String?,
  );
}

// Productivity & Career
class DailyPlanningEntry extends TrackingEntry {
  final List<String> topTasks;
  final int tasksCompleted;
  final int? rating; // 1-10

  const DailyPlanningEntry({
    required super.id,
    required super.date,
    required this.topTasks,
    required this.tasksCompleted,
    this.rating,
    super.notes,
  }) : super(category: 'daily_planning');

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'category': category,
    'topTasks': topTasks,
    'tasksCompleted': tasksCompleted,
    'rating': rating,
    'notes': notes,
  };

  static DailyPlanningEntry fromJson(Map<String, dynamic> json) => DailyPlanningEntry(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    topTasks: List<String>.from(json['topTasks'] as List),
    tasksCompleted: json['tasksCompleted'] as int,
    rating: json['rating'] as int?,
    notes: json['notes'] as String?,
  );
}

class UpskillingEntry extends TrackingEntry {
  final int minutesSpent;
  final String skill; // Flutter, Node.js, IoT, etc.
  final String? platform;
  final int? lessonsCompleted;

  const UpskillingEntry({
    required super.id,
    required super.date,
    required this.minutesSpent,
    required this.skill,
    this.platform,
    this.lessonsCompleted,
    super.notes,
  }) : super(category: 'upskilling');

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'category': category,
    'minutesSpent': minutesSpent,
    'skill': skill,
    'platform': platform,
    'lessonsCompleted': lessonsCompleted,
    'notes': notes,
  };

  static UpskillingEntry fromJson(Map<String, dynamic> json) => UpskillingEntry(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    minutesSpent: json['minutesSpent'] as int,
    skill: json['skill'] as String,
    platform: json['platform'] as String?,
    lessonsCompleted: json['lessonsCompleted'] as int?,
    notes: json['notes'] as String?,
  );
}

class CodeCommitEntry extends TrackingEntry {
  final int commitsPushed;
  final String? repository;
  final String? description;

  const CodeCommitEntry({
    required super.id,
    required super.date,
    required this.commitsPushed,
    this.repository,
    this.description,
    super.notes,
  }) : super(category: 'code_commits');

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'category': category,
    'commitsPushed': commitsPushed,
    'repository': repository,
    'description': description,
    'notes': notes,
  };

  static CodeCommitEntry fromJson(Map<String, dynamic> json) => CodeCommitEntry(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    commitsPushed: json['commitsPushed'] as int,
    repository: json['repository'] as String?,
    description: json['description'] as String?,
    notes: json['notes'] as String?,
  );
}

class NetworkingEntry extends TrackingEntry {
  final int connectionsMade;
  final String platform; // LinkedIn, GitHub, etc.
  final String? activity; // posts, comments, contributions

  const NetworkingEntry({
    required super.id,
    required super.date,
    required this.connectionsMade,
    required this.platform,
    this.activity,
    super.notes,
  }) : super(category: 'networking');

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'category': category,
    'connectionsMade': connectionsMade,
    'platform': platform,
    'activity': activity,
    'notes': notes,
  };

  static NetworkingEntry fromJson(Map<String, dynamic> json) => NetworkingEntry(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    connectionsMade: json['connectionsMade'] as int,
    platform: json['platform'] as String,
    activity: json['activity'] as String?,
    notes: json['notes'] as String?,
  );
}

// Finance
class ExpenseEntry extends TrackingEntry {
  final double amount;
  final String category; // food, transport, entertainment, etc.
  final String type; // income, expense
  final String? description;

  const ExpenseEntry({
    required super.id,
    required super.date,
    required this.amount,
    required this.category,
    required this.type,
    this.description,
    super.notes,
  }) : super(category: 'expense');

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'category': category,
    'amount': amount,
    'expenseCategory': category,
    'type': type,
    'description': description,
    'notes': notes,
  };

  static ExpenseEntry fromJson(Map<String, dynamic> json) => ExpenseEntry(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    amount: json['amount'] as double,
    category: json['expenseCategory'] as String,
    type: json['type'] as String,
    description: json['description'] as String?,
    notes: json['notes'] as String?,
  );
}

class SavingsEntry extends TrackingEntry {
  final double amount;
  final String type; // savings, investment
  final String? platform; // bank, stock, crypto, etc.

  const SavingsEntry({
    required super.id,
    required super.date,
    required this.amount,
    required this.type,
    this.platform,
    super.notes,
  }) : super(category: 'savings');

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'category': category,
    'amount': amount,
    'type': type,
    'platform': platform,
    'notes': notes,
  };

  static SavingsEntry fromJson(Map<String, dynamic> json) => SavingsEntry(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    amount: json['amount'] as double,
    type: json['type'] as String,
    platform: json['platform'] as String?,
    notes: json['notes'] as String?,
  );
}

// Lifestyle & Relationships
class CleaningEntry extends TrackingEntry {
  final int minutesSpent;
  final String area; // room, kitchen, bathroom, etc.
  final int? rating; // 1-10

  const CleaningEntry({
    required super.id,
    required super.date,
    required this.minutesSpent,
    required this.area,
    this.rating,
    super.notes,
  }) : super(category: 'cleaning');

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'category': category,
    'minutesSpent': minutesSpent,
    'area': area,
    'rating': rating,
    'notes': notes,
  };

  static CleaningEntry fromJson(Map<String, dynamic> json) => CleaningEntry(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    minutesSpent: json['minutesSpent'] as int,
    area: json['area'] as String,
    rating: json['rating'] as int?,
    notes: json['notes'] as String?,
  );
}

class SocialConnectionEntry extends TrackingEntry {
  final String person; // family, friend, colleague
  final int minutesSpent;
  final String? type; // call, text, in-person, etc.
  final int? rating; // 1-10

  const SocialConnectionEntry({
    required super.id,
    required super.date,
    required this.person,
    required this.minutesSpent,
    this.type,
    this.rating,
    super.notes,
  }) : super(category: 'social_connection');

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'category': category,
    'person': person,
    'minutesSpent': minutesSpent,
    'type': type,
    'rating': rating,
    'notes': notes,
  };

  static SocialConnectionEntry fromJson(Map<String, dynamic> json) => SocialConnectionEntry(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    person: json['person'] as String,
    minutesSpent: json['minutesSpent'] as int,
    type: json['type'] as String?,
    rating: json['rating'] as int?,
    notes: json['notes'] as String?,
  );
}

class CookingEntry extends TrackingEntry {
  final int mealsCooked;
  final List<String> dishes;
  final int? rating; // 1-10

  const CookingEntry({
    required super.id,
    required super.date,
    required this.mealsCooked,
    required this.dishes,
    this.rating,
    super.notes,
  }) : super(category: 'cooking');

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'category': category,
    'mealsCooked': mealsCooked,
    'dishes': dishes,
    'rating': rating,
    'notes': notes,
  };

  static CookingEntry fromJson(Map<String, dynamic> json) => CookingEntry(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    mealsCooked: json['mealsCooked'] as int,
    dishes: List<String>.from(json['dishes'] as List),
    rating: json['rating'] as int?,
    notes: json['notes'] as String?,
  );
}

class ShoppingControlEntry extends TrackingEntry {
  final bool avoidedUnnecessaryShopping;
  final double? amountSpent;
  final String? itemsBought;

  const ShoppingControlEntry({
    required super.id,
    required super.date,
    required this.avoidedUnnecessaryShopping,
    this.amountSpent,
    this.itemsBought,
    super.notes,
  }) : super(category: 'shopping_control');

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'category': category,
    'avoidedUnnecessaryShopping': avoidedUnnecessaryShopping,
    'amountSpent': amountSpent,
    'itemsBought': itemsBought,
    'notes': notes,
  };

  static ShoppingControlEntry fromJson(Map<String, dynamic> json) => ShoppingControlEntry(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    avoidedUnnecessaryShopping: json['avoidedUnnecessaryShopping'] as bool,
    amountSpent: json['amountSpent'] as double?,
    itemsBought: json['itemsBought'] as String?,
    notes: json['notes'] as String?,
  );
}

// Category definitions for UI
class TrackingCategory {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String color;
  final List<String> subcategories;

  const TrackingCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.subcategories,
  });
}

class TrackingCategories {
  static const List<TrackingCategory> all = [
    TrackingCategory(
      id: 'personal_growth',
      name: '🧠 Personal Growth & Learning',
      description: 'Track your learning and development journey',
      icon: '🧠',
      color: '#667EEA',
      subcategories: ['reading', 'language_learning', 'coding_practice', 'journaling'],
    ),
    TrackingCategory(
      id: 'health_fitness',
      name: '💪 Health & Fitness',
      description: 'Monitor your physical health and wellness',
      icon: '💪',
      color: '#10B981',
      subcategories: ['morning_stretch', 'walk', 'workout', 'water_intake', 'nutrition'],
    ),
    TrackingCategory(
      id: 'mind_mental_health',
      name: '🧘 Mind & Mental Health',
      description: 'Take care of your mental wellbeing',
      icon: '🧘',
      color: '#8B5CF6',
      subcategories: ['meditation', 'gratitude', 'screen_free_time'],
    ),
    TrackingCategory(
      id: 'productivity_career',
      name: '💼 Productivity & Career',
      description: 'Boost your professional development',
      icon: '💼',
      color: '#F59E0B',
      subcategories: ['daily_planning', 'upskilling', 'code_commits', 'networking'],
    ),
    TrackingCategory(
      id: 'finance',
      name: '💵 Finance',
      description: 'Manage your money and investments',
      icon: '💵',
      color: '#EF4444',
      subcategories: ['expense', 'savings'],
    ),
    TrackingCategory(
      id: 'lifestyle_relationships',
      name: '🏡 Lifestyle & Relationships',
      description: 'Balance your personal life and connections',
      icon: '🏡',
      color: '#06B6D4',
      subcategories: ['cleaning', 'social_connection', 'cooking', 'shopping_control'],
    ),
  ];
}
