import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/dynamic_activities.dart';
import '../state/dynamic_activities_state.dart';

class ComprehensiveFitnessScreen extends ConsumerStatefulWidget {
  const ComprehensiveFitnessScreen({super.key});

  @override
  ConsumerState<ComprehensiveFitnessScreen> createState() => _ComprehensiveFitnessScreenState();
}

class _ComprehensiveFitnessScreenState extends ConsumerState<ComprehensiveFitnessScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('💪 Fitness & Wellness', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF667EEA),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Schedule', icon: Icon(Icons.calendar_today)),
            Tab(text: 'Activities', icon: Icon(Icons.fitness_center)),
            Tab(text: 'Yoga', icon: Icon(Icons.self_improvement)),
            Tab(text: 'Music', icon: Icon(Icons.music_note)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWeeklyScheduleTab(),
          _buildActivitiesTab(),
          _buildYogaTab(),
          _buildMusicTab(),
        ],
      ),
    );
  }

  Widget _buildWeeklyScheduleTab() {
    final activeSchedule = ref.watch(activeScheduleProvider);
    final activities = ref.watch(dynamicActivitiesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Selector
          _buildDateSelector(),
          const SizedBox(height: 20),
          // Weekly Schedule
          if (activeSchedule != null) ...[
            Text(
              'Weekly Schedule',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ...activeSchedule.schedule.entries.map((entry) {
              return _buildDaySchedule(entry.key, entry.value, activities);
            }).toList(),
          ] else
            _buildEmptySchedule(),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3A3A3A)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selected Date',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: _selectDate,
            icon: const Icon(Icons.calendar_month, color: Color(0xFF667EEA)),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySchedule(String day, List<String> activityIds, List<DynamicActivity> activities) {
    final dayActivities = activityIds
        .map((id) => activities.firstWhere((a) => a.id == id, orElse: () => DynamicActivity(
              id: id,
              name: 'Unknown Activity',
              category: 'fitness',
              icon: '❓',
              color: '#666666',
              description: 'Activity not found',
              createdAt: DateTime.now(),
            )))
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3A3A3A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          if (dayActivities.isEmpty)
            const Text(
              'Rest Day',
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            )
          else
            ...dayActivities.map((activity) => _buildScheduleActivity(activity)).toList(),
        ],
      ),
    );
  }

  Widget _buildScheduleActivity(DynamicActivity activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(int.parse(activity.color.replaceFirst('#', '0xFF'))).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(int.parse(activity.color.replaceFirst('#', '0xFF'))).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Text(activity.icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  activity.description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _startActivity(activity),
            icon: const Icon(Icons.play_arrow, color: Color(0xFF667EEA)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySchedule() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No Schedule Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create a weekly schedule to organize your fitness routine',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createSchedule,
            icon: const Icon(Icons.add),
            label: const Text('Create Schedule'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667EEA),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesTab() {
    final activities = ref.watch(fitnessActivitiesProvider);
    final activityEntries = ref.watch(activityEntriesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Fitness Activities',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: _addCustomActivity,
                icon: const Icon(Icons.add, color: Color(0xFF667EEA)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...activities.map((activity) {
            final todayEntries = activityEntries
                .where((e) => e.activityId == activity.id &&
                    e.date.year == _selectedDate.year &&
                    e.date.month == _selectedDate.month &&
                    e.date.day == _selectedDate.day)
                .toList();
            final totalMinutes = todayEntries.fold(0, (sum, e) => sum + e.minutesSpent);
            
            return _buildActivityCard(activity, totalMinutes);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildActivityCard(DynamicActivity activity, int totalMinutes) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _startActivity(activity),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF3A3A3A)),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(int.parse(activity.color.replaceFirst('#', '0xFF'))).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(activity.icon, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        activity.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      if (totalMinutes > 0)
                        Text(
                          'Today: ${totalMinutes} minutes',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF667EEA),
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildYogaTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Yoga Poses',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...YogaPose.allPoses.map((pose) => _buildYogaPoseCard(pose)).toList(),
        ],
      ),
    );
  }

  Widget _buildYogaPoseCard(YogaPose pose) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showYogaPoseDetails(pose),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF3A3A3A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(pose.icon, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pose.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            pose.sanskritName,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(pose.difficulty).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getDifficultyColor(pose.difficulty).withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        pose.difficulty,
                        style: TextStyle(
                          color: _getDifficultyColor(pose.difficulty),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  pose.description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.timer, color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${pose.durationMinutes} min',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.category, color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      pose.category,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: pose.benefits.take(3).map((benefit) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF667EEA).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        benefit,
                        style: const TextStyle(
                          color: Color(0xFF667EEA),
                          fontSize: 10,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMusicTab() {
    final musicSessions = ref.watch(musicSessionsProvider);
    final todaySessions = musicSessions
        .where((s) => s.date.year == _selectedDate.year &&
            s.date.month == _selectedDate.month &&
            s.date.day == _selectedDate.day)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Music Sessions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: _addMusicSession,
                icon: const Icon(Icons.add, color: Color(0xFF667EEA)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (todaySessions.isEmpty)
            _buildEmptyMusicState()
          else
            ...todaySessions.map((session) => _buildMusicSessionCard(session)).toList(),
        ],
      ),
    );
  }

  Widget _buildEmptyMusicState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.music_note, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No Music Sessions Today',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start tracking your music listening for better mood and relaxation',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addMusicSession,
            icon: const Icon(Icons.add),
            label: const Text('Add Music Session'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667EEA),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMusicSessionCard(MusicSession session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3A3A3A)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFEC4899).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.music_note, color: Color(0xFFEC4899), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.genre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (session.artist != null)
                  Text(
                    session.artist!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                Text(
                  '${session.minutesListened} minutes • ${DateFormat('HH:mm').format(session.date)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (session.rating != null)
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < session.rating! ? Icons.star : Icons.star_border,
                  color: const Color(0xFFF59E0B),
                  size: 16,
                );
              }),
            ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF667EEA),
              onPrimary: Colors.white,
              surface: Color(0xFF2A2A2A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _startActivity(DynamicActivity activity) {
    // Navigate to activity tracking screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting ${activity.name}...'),
        backgroundColor: const Color(0xFF667EEA),
      ),
    );
  }

  void _addCustomActivity() {
    // Show dialog to add custom activity
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add custom activity feature coming soon!'),
        backgroundColor: Color(0xFF667EEA),
      ),
    );
  }

  void _createSchedule() {
    // Show dialog to create schedule
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Create schedule feature coming soon!'),
        backgroundColor: Color(0xFF667EEA),
      ),
    );
  }

  void _showYogaPoseDetails(YogaPose pose) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(pose.icon, style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Text(
                    pose.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    pose.sanskritName,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    pose.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Benefits:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: pose.benefits.map((benefit) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF667EEA).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          benefit,
                          style: const TextStyle(
                            color: Color(0xFF667EEA),
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Instructions:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    pose.instructions,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _startYogaPose(pose);
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Pose'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667EEA),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startYogaPose(YogaPose pose) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting ${pose.name} for ${pose.durationMinutes} minutes...'),
        backgroundColor: const Color(0xFF667EEA),
      ),
    );
  }

  void _addMusicSession() {
    // Show dialog to add music session
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add music session feature coming soon!'),
        backgroundColor: Color(0xFF667EEA),
      ),
    );
  }
}
