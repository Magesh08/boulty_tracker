
class DynamicActivity {
  final String id;
  final String name;
  final String category;
  final String icon;
  final String color;
  final String description;
  final DateTime createdAt;
  final bool isActive;

  const DynamicActivity({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.color,
    required this.description,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'icon': icon,
    'color': color,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'isActive': isActive,
  };

  static DynamicActivity fromJson(Map<String, dynamic> json) => DynamicActivity(
    id: json['id'] as String,
    name: json['name'] as String,
    category: json['category'] as String,
    icon: json['icon'] as String,
    color: json['color'] as String,
    description: json['description'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    isActive: json['isActive'] as bool? ?? true,
  );

  DynamicActivity copyWith({
    String? id,
    String? name,
    String? category,
    String? icon,
    String? color,
    String? description,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return DynamicActivity(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

class ActivityEntry {
  final String id;
  final String activityId;
  final DateTime date;
  final int minutesSpent;
  final String? notes;
  final int? rating; // 1-10
  final Map<String, dynamic>? customData;

  const ActivityEntry({
    required this.id,
    required this.activityId,
    required this.date,
    required this.minutesSpent,
    this.notes,
    this.rating,
    this.customData,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'activityId': activityId,
    'date': date.toIso8601String(),
    'minutesSpent': minutesSpent,
    'notes': notes,
    'rating': rating,
    'customData': customData,
  };

  static ActivityEntry fromJson(Map<String, dynamic> json) => ActivityEntry(
    id: json['id'] as String,
    activityId: json['activityId'] as String,
    date: DateTime.parse(json['date'] as String),
    minutesSpent: json['minutesSpent'] as int,
    notes: json['notes'] as String?,
    rating: json['rating'] as int?,
    customData: json['customData'] as Map<String, dynamic>?,
  );
}

class YogaPose {
  final String id;
  final String name;
  final String sanskritName;
  final String description;
  final List<String> benefits;
  final int durationMinutes;
  final String difficulty; // Beginner, Intermediate, Advanced
  final String category; // Stress Relief, Flexibility, Strength, etc.
  final String instructions;
  final String icon;

  const YogaPose({
    required this.id,
    required this.name,
    required this.sanskritName,
    required this.description,
    required this.benefits,
    required this.durationMinutes,
    required this.difficulty,
    required this.category,
    required this.instructions,
    required this.icon,
  });

  static const List<YogaPose> allPoses = [
    YogaPose(
      id: 'child_pose',
      name: 'Child\'s Pose',
      sanskritName: 'Balasana',
      description: 'A gentle resting pose that calms the mind and relieves stress',
      benefits: ['Stress Relief', 'Back Pain Relief', 'Hip Flexibility', 'Mental Calmness'],
      durationMinutes: 5,
      difficulty: 'Beginner',
      category: 'Stress Relief',
      instructions: 'Kneel on the floor, sit back on your heels, and fold forward with arms extended',
      icon: '🧘‍♀️',
    ),
    YogaPose(
      id: 'downward_dog',
      name: 'Downward Dog',
      sanskritName: 'Adho Mukha Svanasana',
      description: 'An energizing pose that strengthens the entire body',
      benefits: ['Full Body Strength', 'Improved Circulation', 'Spine Flexibility', 'Energy Boost'],
      durationMinutes: 3,
      difficulty: 'Beginner',
      category: 'Strength',
      instructions: 'Start on hands and knees, tuck toes, lift hips up and back',
      icon: '🐕',
    ),
    YogaPose(
      id: 'warrior_1',
      name: 'Warrior I',
      sanskritName: 'Virabhadrasana I',
      description: 'A powerful standing pose that builds strength and focus',
      benefits: ['Leg Strength', 'Balance', 'Focus', 'Confidence'],
      durationMinutes: 2,
      difficulty: 'Beginner',
      category: 'Strength',
      instructions: 'Step one foot forward, bend knee, raise arms overhead',
      icon: '⚔️',
    ),
    YogaPose(
      id: 'tree_pose',
      name: 'Tree Pose',
      sanskritName: 'Vrksasana',
      description: 'A balancing pose that improves focus and stability',
      benefits: ['Balance', 'Focus', 'Leg Strength', 'Mental Clarity'],
      durationMinutes: 2,
      difficulty: 'Beginner',
      category: 'Balance',
      instructions: 'Stand on one leg, place other foot on inner thigh, hands in prayer',
      icon: '🌳',
    ),
    YogaPose(
      id: 'cat_cow',
      name: 'Cat-Cow Stretch',
      sanskritName: 'Marjaryasana-Bitilasana',
      description: 'A gentle flow that improves spine mobility',
      benefits: ['Spine Flexibility', 'Back Pain Relief', 'Stress Relief', 'Warm-up'],
      durationMinutes: 3,
      difficulty: 'Beginner',
      category: 'Flexibility',
      instructions: 'Start on hands and knees, alternate between arching and rounding the back',
      icon: '🐱',
    ),
    YogaPose(
      id: 'corpse_pose',
      name: 'Corpse Pose',
      sanskritName: 'Savasana',
      description: 'The ultimate relaxation pose for deep rest',
      benefits: ['Deep Relaxation', 'Stress Relief', 'Better Sleep', 'Mental Peace'],
      durationMinutes: 10,
      difficulty: 'Beginner',
      category: 'Stress Relief',
      instructions: 'Lie flat on back, arms at sides, close eyes, focus on breathing',
      icon: '😴',
    ),
  ];
}

class WeeklySchedule {
  final String id;
  final String name;
  final Map<String, List<String>> schedule; // day -> list of activity IDs
  final DateTime createdAt;
  final bool isActive;

  const WeeklySchedule({
    required this.id,
    required this.name,
    required this.schedule,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'schedule': schedule,
    'createdAt': createdAt.toIso8601String(),
    'isActive': isActive,
  };

  static WeeklySchedule fromJson(Map<String, dynamic> json) => WeeklySchedule(
    id: json['id'] as String,
    name: json['name'] as String,
    schedule: Map<String, List<String>>.from(
      (json['schedule'] as Map).map(
        (key, value) => MapEntry(key as String, List<String>.from(value as List)),
      ),
    ),
    createdAt: DateTime.parse(json['createdAt'] as String),
    isActive: json['isActive'] as bool? ?? true,
  );
}

class MusicSession {
  final String id;
  final DateTime date;
  final int minutesListened;
  final String genre;
  final String? artist;
  final String? album;
  final String? mood;
  final int? rating; // 1-10
  final String? notes;

  const MusicSession({
    required this.id,
    required this.date,
    required this.minutesListened,
    required this.genre,
    this.artist,
    this.album,
    this.mood,
    this.rating,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'minutesListened': minutesListened,
    'genre': genre,
    'artist': artist,
    'album': album,
    'mood': mood,
    'rating': rating,
    'notes': notes,
  };

  static MusicSession fromJson(Map<String, dynamic> json) => MusicSession(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    minutesListened: json['minutesListened'] as int,
    genre: json['genre'] as String,
    artist: json['artist'] as String?,
    album: json['album'] as String?,
    mood: json['mood'] as String?,
    rating: json['rating'] as int?,
    notes: json['notes'] as String?,
  );
}

// Predefined activity categories with default activities
class ActivityCategories {
  static final Map<String, List<DynamicActivity>> defaultActivities = {
    'personal_growth': [
      DynamicActivity(
        id: 'coding',
        name: 'Coding Practice',
        category: 'personal_growth',
        icon: '💻',
        color: '#667EEA',
        description: 'Practice programming and coding skills',
        createdAt: DateTime.now(),
      ),
      DynamicActivity(
        id: 'singing',
        name: 'Singing',
        category: 'personal_growth',
        icon: '🎤',
        color: '#FF6B6B',
        description: 'Practice singing and vocal skills',
        createdAt: DateTime.now(),
      ),
      DynamicActivity(
        id: 'dancing',
        name: 'Dancing',
        category: 'personal_growth',
        icon: '💃',
        color: '#4ECDC4',
        description: 'Learn and practice dance moves',
        createdAt: DateTime.now(),
      ),
      DynamicActivity(
        id: 'reading',
        name: 'Reading',
        category: 'personal_growth',
        icon: '📚',
        color: '#45B7D1',
        description: 'Read books and articles for knowledge',
        createdAt: DateTime.now(),
      ),
      DynamicActivity(
        id: 'language_learning',
        name: 'Language Learning',
        category: 'personal_growth',
        icon: '🗣️',
        color: '#96CEB4',
        description: 'Learn new languages',
        createdAt: DateTime.now(),
      ),
    ],
    'fitness': [
      DynamicActivity(
        id: 'yoga',
        name: 'Yoga',
        category: 'fitness',
        icon: '🧘‍♀️',
        color: '#8B5CF6',
        description: 'Practice yoga poses and meditation',
        createdAt: DateTime.now(),
      ),
      DynamicActivity(
        id: 'gym',
        name: 'Gym Workout',
        category: 'fitness',
        icon: '🏋️‍♂️',
        color: '#F59E0B',
        description: 'Strength training and cardio',
        createdAt: DateTime.now(),
      ),
      DynamicActivity(
        id: 'running',
        name: 'Running',
        category: 'fitness',
        icon: '🏃‍♂️',
        color: '#10B981',
        description: 'Cardio running and jogging',
        createdAt: DateTime.now(),
      ),
      DynamicActivity(
        id: 'cycling',
        name: 'Cycling',
        category: 'fitness',
        icon: '🚴‍♂️',
        color: '#06B6D4',
        description: 'Bicycle riding for fitness',
        createdAt: DateTime.now(),
      ),
    ],
    'mind_wellness': [
      DynamicActivity(
        id: 'meditation',
        name: 'Meditation',
        category: 'mind_wellness',
        icon: '🧘',
        color: '#8B5CF6',
        description: 'Mindfulness and meditation practice',
        createdAt: DateTime.now(),
      ),
      DynamicActivity(
        id: 'music_listening',
        name: 'Music Listening',
        category: 'mind_wellness',
        icon: '🎵',
        color: '#EC4899',
        description: 'Listen to music for relaxation',
        createdAt: DateTime.now(),
      ),
      DynamicActivity(
        id: 'journaling',
        name: 'Journaling',
        category: 'mind_wellness',
        icon: '📝',
        color: '#F59E0B',
        description: 'Write thoughts and reflections',
        createdAt: DateTime.now(),
      ),
    ],
  };
}
