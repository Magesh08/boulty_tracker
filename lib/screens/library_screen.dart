import 'package:flutter/material.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_LibItem>[
      _LibItem('Running', Icons.directions_run),
      _LibItem('Interval Training', Icons.fast_forward),
      _LibItem('Sprints', Icons.flash_on),
      _LibItem('Cycling', Icons.directions_bike),
      _LibItem('Swimming', Icons.pool),
      _LibItem('Jump Rope', Icons.height),
      _LibItem('Weight Lifting', Icons.fitness_center),
      _LibItem('Bodyweight', Icons.self_improvement),
      _LibItem('CrossFit', Icons.bolt),
      _LibItem('Kettlebells', Icons.sports_handball),
      _LibItem('Resistance Bands', Icons.fitness_center),
      _LibItem('Yoga', Icons.self_improvement),
      _LibItem('Stretching', Icons.front_hand),
      _LibItem('Pilates', Icons.fitness_center),
      _LibItem('Foam Rolling', Icons.roller_skating),
      _LibItem('Active Recovery', Icons.spa),
      _LibItem('Basketball', Icons.sports_basketball),
      _LibItem('Soccer', Icons.sports_soccer),
      _LibItem('Tennis', Icons.sports_tennis),
      _LibItem('Badminton', Icons.sports_tennis),
      _LibItem('Golf', Icons.sports_golf),
      _LibItem('Hiking', Icons.hiking),
      _LibItem('Martial Arts', Icons.sports_kabaddi),
      _LibItem('Boxing', Icons.sports_mma),
      _LibItem('Meal Prep', Icons.restaurant),
      _LibItem('Calories', Icons.add_chart),
      _LibItem('Hydration', Icons.local_drink),
      _LibItem('Cooking', Icons.soup_kitchen),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Workout & Diet Library')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {},
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon, size: 36),
                    const SizedBox(height: 8),
                    Text(item.title, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          );
        },
        itemCount: items.length,
      ),
    );
  }
}

class _LibItem {
  final String title;
  final IconData icon;
  _LibItem(this.title, this.icon);
}


