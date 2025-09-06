import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dynamic_activities.dart';
import '../state/dynamic_activities_state.dart';

class DynamicActivitiesScreen extends ConsumerStatefulWidget {
  final String category;
  
  const DynamicActivitiesScreen({
    super.key,
    required this.category,
  });

  @override
  ConsumerState<DynamicActivitiesScreen> createState() => _DynamicActivitiesScreenState();
}

class _DynamicActivitiesScreenState extends ConsumerState<DynamicActivitiesScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _iconController = TextEditingController();
  String _selectedColor = '#667EEA';

  final List<String> _colors = [
    '#667EEA', '#764BA2', '#FF6B6B', '#FF8E53', '#4ECDC4', '#44A08D',
    '#10B981', '#059669', '#8B5CF6', '#7C3AED', '#F59E0B', '#D97706',
    '#EF4444', '#DC2626', '#06B6D4', '#0891B2', '#EC4899', '#DB2777',
  ];

  final List<String> _icons = [
    '💻', '🎤', '💃', '📚', '🗣️', '🎨', '🎵', '🎮', '🏃‍♂️', '🏋️‍♂️',
    '🧘‍♀️', '🚴‍♂️', '🏊‍♂️', '⚽', '🏀', '🎯', '🎪', '🎭', '📝', '🔬',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activities = ref.watch(dynamicActivitiesProvider)
        .where((a) => a.category == widget.category && a.isActive)
        .toList();
    final activitiesNotifier = ref.read(dynamicActivitiesProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: Text(
          _getCategoryTitle(widget.category),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => _showAddActivityDialog(activitiesNotifier),
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      body: activities.isEmpty
          ? _buildEmptyState(activitiesNotifier)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                return _buildActivityCard(activity, activitiesNotifier);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddActivityDialog(activitiesNotifier),
        backgroundColor: const Color(0xFF667EEA),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(DynamicActivitiesNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF667EEA).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_circle_outline,
              size: 60,
              color: Color(0xFF667EEA),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No ${_getCategoryTitle(widget.category).toLowerCase()} activities yet',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first activity to start tracking your progress',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddActivityDialog(notifier),
            icon: const Icon(Icons.add),
            label: const Text('Add First Activity'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667EEA),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(DynamicActivity activity, DynamicActivitiesNotifier notifier) {
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
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _editActivity(activity, notifier),
                      icon: const Icon(Icons.edit, size: 16),
                      color: Colors.grey,
                    ),
                    IconButton(
                      onPressed: () => _deleteActivity(activity, notifier),
                      icon: const Icon(Icons.delete, size: 16),
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddActivityDialog(DynamicActivitiesNotifier notifier) {
    _nameController.clear();
    _descriptionController.clear();
    _iconController.clear();
    _selectedColor = '#667EEA';

    showDialog(
      context: context,
      builder: (context) => _buildActivityDialog(notifier, null),
    );
  }

  void _editActivity(DynamicActivity activity, DynamicActivitiesNotifier notifier) {
    _nameController.text = activity.name;
    _descriptionController.text = activity.description;
    _iconController.text = activity.icon;
    _selectedColor = activity.color;

    showDialog(
      context: context,
      builder: (context) => _buildActivityDialog(notifier, activity),
    );
  }

  Widget _buildActivityDialog(DynamicActivitiesNotifier notifier, DynamicActivity? activity) {
    final isEditing = activity != null;

    return StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEditing ? 'Edit Activity' : 'Add Activity',
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Activity Name',
                    labelStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF667EEA)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Description
                TextField(
                  controller: _descriptionController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF667EEA)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Icon Selection
                const Text(
                  'Select Icon:',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 120,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _icons.length,
                    itemBuilder: (context, index) {
                      final icon = _icons[index];
                      final isSelected = _iconController.text == icon;
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            _iconController.text = icon;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? const Color(0xFF667EEA).withOpacity(0.3)
                                : const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected 
                                  ? const Color(0xFF667EEA)
                                  : const Color(0xFF3A3A3A),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              icon,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Color Selection
                const Text(
                  'Select Color:',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _colors.map((color) {
                    final isSelected = _selectedColor == color;
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          _selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 20)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty && _iconController.text.isNotEmpty) {
                  final newActivity = DynamicActivity(
                    id: isEditing ? activity.id : DateTime.now().millisecondsSinceEpoch.toString(),
                    name: _nameController.text,
                    category: widget.category,
                    icon: _iconController.text,
                    color: _selectedColor,
                    description: _descriptionController.text,
                    createdAt: isEditing ? activity.createdAt : DateTime.now(),
                  );

                  if (isEditing) {
                    notifier.updateActivity(newActivity);
                  } else {
                    notifier.addActivity(newActivity);
                  }

                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all required fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                foregroundColor: Colors.white,
              ),
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  void _deleteActivity(DynamicActivity activity, DynamicActivitiesNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Activity', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this activity?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              notifier.removeActivity(activity.id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _startActivity(DynamicActivity activity) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting ${activity.name}...'),
        backgroundColor: const Color(0xFF667EEA),
      ),
    );
  }

  String _getCategoryTitle(String category) {
    switch (category) {
      case 'personal_growth':
        return 'Personal Growth';
      case 'fitness':
        return 'Fitness';
      case 'mind_wellness':
        return 'Mind & Wellness';
      default:
        return 'Activities';
    }
  }
}
