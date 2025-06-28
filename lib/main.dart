import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const SeventyFiveHardApp());
}

class SeventyFiveHardApp extends StatelessWidget {
  const SeventyFiveHardApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '75 Hard Challenge',
      theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true),
      home: const ChallengeTracker(),
    );
  }
}

class ChallengeItem {
  final String title;
  final String description;
  final IconData icon;
  bool isCompleted;

  ChallengeItem({
    required this.title,
    required this.description,
    required this.icon,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
    };
  }

  factory ChallengeItem.fromJson(Map<String, dynamic> json, IconData icon) {
    return ChallengeItem(
      title: json['title'],
      description: json['description'],
      icon: icon,
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

class DayProgress {
  final DateTime date;
  final int dayNumber;
  final List<bool> taskCompletions;
  final int completedTasks;

  DayProgress({
    required this.date,
    required this.dayNumber,
    required this.taskCompletions,
    required this.completedTasks,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'dayNumber': dayNumber,
      'taskCompletions': taskCompletions,
      'completedTasks': completedTasks,
    };
  }

  factory DayProgress.fromJson(Map<String, dynamic> json) {
    return DayProgress(
      date: DateTime.parse(json['date']),
      dayNumber: json['dayNumber'],
      taskCompletions: List<bool>.from(json['taskCompletions']),
      completedTasks: json['completedTasks'],
    );
  }
}

class ChallengeTracker extends StatefulWidget {
  const ChallengeTracker({Key? key}) : super(key: key);

  @override
  State<ChallengeTracker> createState() => _ChallengeTrackerState();
}

class _ChallengeTrackerState extends State<ChallengeTracker> {
  List<ChallengeItem> challengeItems = [];
  DateTime? startDate;
  int currentDay = 1;
  int completedToday = 0;

  final List<IconData> icons = [
    Icons.restaurant, // Follow a Diet
    Icons.fitness_center, // Two Workouts
    Icons.water_drop, // Drink Water
    Icons.menu_book, // Read 10 Pages
    Icons.camera_alt, // Progress Photo
    Icons.bedtime, // Sleep
    Icons.no_drinks, // No Junk/Alcohol
    Icons.school, // No Sugar
  ];

  @override
  void initState() {
    super.initState();
    _initializeChallengeItems();
    _loadProgress();
  }

  void _initializeChallengeItems() {
    final List<Map<String, String>> items = [
      {
        'title': 'Follow a Diet',
        'description': 'Stick to a structured diet with no cheat meals.',
      },
      {
        'title': 'Two 45-Minute Workouts',
        'description': 'Complete two workouts daily, one must be outdoors.',
      },
      {
        'title': 'Drink 1 Gallon (3.7L) of Water',
        'description': 'Stay hydrated with no substitutions.',
      },
      {
        'title': 'Read 10 Pages',
        'description': 'Read 10 pages of a non-fiction/self-improvement book.',
      },
      {
        'title': 'Take a Progress Photo',
        'description': 'Capture a daily photo to track physical changes.',
      },
      {
        'title': 'Get 7-8 Hours of Sleep',
        'description': 'Ensure proper rest to aid recovery and focus.',
      },
      {
        'title': 'Avoid Sugar & Junk',
        'description': 'Cut out all added sugars and junk food.',
      },
      {
        'title': 'Practice a Skill',
        'description':
            'Spend time developing a personal or professional skill.',
      },
    ];

    challengeItems = items.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, String> item = entry.value;
      return ChallengeItem(
        title: item['title']!,
        description: item['description']!,
        icon: icons[index],
      );
    }).toList();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();

    // Load or set start date
    final String? startDateString = prefs.getString('startDate');
    if (startDateString != null) {
      startDate = DateTime.parse(startDateString);
    } else {
      // Set start date to beginning of today (midnight)
      final now = DateTime.now();
      startDate = DateTime(now.year, now.month, now.day);
      await prefs.setString('startDate', startDate!.toIso8601String());
    }

    // Calculate current day based on actual dates (day changes at midnight)
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final int daysDifference = today.difference(startDate!).inDays + 1;
    currentDay = daysDifference > 75 ? 75 : daysDifference;

    // Load today's progress
    final String todayKey = _getDateKey(today);
    final String? todayProgress = prefs.getString('progress_$todayKey');
    if (todayProgress != null) {
      final List<dynamic> progressData = json.decode(todayProgress);
      for (
        int i = 0;
        i < challengeItems.length && i < progressData.length;
        i++
      ) {
        challengeItems[i].isCompleted = progressData[i]['isCompleted'] ?? false;
      }
    }

    _updateCompletedCount();
    setState(() {});
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final String todayKey = _getDateKey(today);

    // Save today's progress
    final List<Map<String, dynamic>> progressData = challengeItems
        .map((item) => item.toJson())
        .toList();
    await prefs.setString('progress_$todayKey', json.encode(progressData));

    // Save day progress for statistics
    final DayProgress dayProgress = DayProgress(
      date: today,
      dayNumber: currentDay,
      taskCompletions: challengeItems.map((item) => item.isCompleted).toList(),
      completedTasks: completedToday,
    );
    await prefs.setString(
      'day_progress_$todayKey',
      json.encode(dayProgress.toJson()),
    );
  }

  void _updateCompletedCount() {
    setState(() {
      completedToday = challengeItems.where((item) => item.isCompleted).length;
    });
  }

  void _toggleItem(int index) {
    setState(() {
      challengeItems[index].isCompleted = !challengeItems[index].isCompleted;
      _updateCompletedCount();
    });
    _saveProgress();
  }

  void _resetDay() {
    setState(() {
      for (var item in challengeItems) {
        item.isCompleted = false;
      }
      completedToday = 0;
    });
    _saveProgress();
  }

  void _showRules() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.rule, color: Colors.deepPurple),
              // SizedBox(width: 2),
              Text(' Challenge Rules'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: challengeItems.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final item = challengeItems[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(item.icon, color: Colors.deepPurple),
                  title: Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(item.description),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<List<DayProgress>> _loadAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final List<DayProgress> allProgress = [];

    if (startDate == null) return allProgress;

    for (int i = 0; i < currentDay; i++) {
      final DateTime date = startDate!.add(Duration(days: i));
      final String dateKey = _getDateKey(date);
      final String? progressString = prefs.getString('day_progress_$dateKey');

      if (progressString != null) {
        try {
          final Map<String, dynamic> progressJson = json.decode(progressString);
          allProgress.add(DayProgress.fromJson(progressJson));
        } catch (e) {
          // If there's an error, create a default progress
          allProgress.add(
            DayProgress(
              date: date,
              dayNumber: i + 1,
              taskCompletions: List.filled(10, false),
              completedTasks: 0,
            ),
          );
        }
      } else {
        // Create default progress for days without data
        allProgress.add(
          DayProgress(
            date: date,
            dayNumber: i + 1,
            taskCompletions: List.filled(10, false),
            completedTasks: 0,
          ),
        );
      }
    }

    return allProgress;
  }

  void _showStatisticsPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StatisticsPage(
          loadAllProgress: _loadAllProgress,
          challengeItems: challengeItems,
          startDate: startDate!,
          currentDay: currentDay,
        ),
      ),
    );
  }

  DateTime get challengeEndDate {
    return startDate!.add(const Duration(days: 74));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('75 Hard Challenge'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _showRules,
            icon: const Icon(Icons.rule),
            tooltip: 'Challenge Rules',
          ),
          IconButton(
            onPressed: _showStatisticsPage,
            icon: const Icon(Icons.analytics),
            tooltip: 'Statistics',
          ),
          IconButton(
            onPressed: _resetDay,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Day',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Card
          Container(
            width: double.infinity, // Make it stretch to full width
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.shade400,
                  Colors.deepPurple.shade600,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                // const SizedBox(height: 16),
                Text(
                  'Day $currentDay of 75',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                if (startDate != null) ...[
                  Text(
                    'Started: ${_getDateKey(startDate!)}',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  Text(
                    'End Date: ${_getDateKey(challengeEndDate)}',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),

          // Challenge Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: challengeItems.length,
              itemBuilder: (context, index) {
                final item = challengeItems[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: item.isCompleted
                            ? Colors.green.shade100
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        item.icon,
                        color: item.isCompleted
                            ? Colors.green.shade600
                            : Colors.grey.shade600,
                      ),
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: item.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    // subtitle: Text(item.description),
                    trailing: Checkbox(
                      value: item.isCompleted,
                      onChanged: (bool? value) {
                        _toggleItem(index);
                      },
                      activeColor: Colors.green,
                    ),
                    onTap: () => _toggleItem(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // Floating Action Button for perfect days
      floatingActionButton: completedToday == 10
          ? FloatingActionButton.extended(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      currentDay < 75
                          ? 'Perfect day! Keep going!'
                          : 'Challenge Complete! You did it!',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.check_circle),
              label: Text(currentDay < 75 ? 'Perfect Day!' : 'Complete!'),
              backgroundColor: Colors.green,
            )
          : null,
    );
  }
}

class StatisticsPage extends StatefulWidget {
  final Future<List<DayProgress>> Function() loadAllProgress;
  final List<ChallengeItem> challengeItems;
  final DateTime startDate;
  final int currentDay;

  const StatisticsPage({
    Key? key,
    required this.loadAllProgress,
    required this.challengeItems,
    required this.startDate,
    required this.currentDay,
  }) : super(key: key);

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  List<DayProgress> allProgress = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    allProgress = await widget.loadAllProgress();
    setState(() {
      isLoading = false;
    });
  }

  double get overallCompletionRate {
    if (allProgress.isEmpty) return 0.0;
    final totalTasks = allProgress.length * 10;
    final completedTasks = allProgress.fold(
      0,
      (sum, day) => sum + day.completedTasks,
    );
    return completedTasks / totalTasks;
  }

  int get perfectDays {
    return allProgress.where((day) => day.completedTasks == 10).length;
  }

  List<int> get taskCompletionCounts {
    final counts = List.filled(10, 0);
    for (final day in allProgress) {
      for (int i = 0; i < day.taskCompletions.length && i < 10; i++) {
        if (day.taskCompletions[i]) {
          counts[i]++;
        }
      }
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Statistics'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Overall Progress',
                    '${(overallCompletionRate * 100).toStringAsFixed(1)}%',
                    Icons.trending_up,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Perfect Days',
                    '$perfectDays/${widget.currentDay}',
                    Icons.star,
                    Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Current Day',
                    '${widget.currentDay}/75',
                    Icons.calendar_today,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Days Left',
                    '${75 - widget.currentDay}',
                    Icons.schedule,
                    Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Task Completion Analysis
            const Text(
              'Task Completion Analysis',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            ...widget.challengeItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final completionCount = index < taskCompletionCounts.length
                  ? taskCompletionCounts[index]
                  : 0;
              final completionRate = widget.currentDay > 0
                  ? completionCount / widget.currentDay
                  : 0.0;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(item.icon, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            '$completionCount/${widget.currentDay}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: completionRate,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getColorForRate(completionRate),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(completionRate * 100).toStringAsFixed(1)}% completion rate',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 24),

            // Daily Progress Calendar
            const Text(
              'Daily Progress Calendar',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLegendItem('Perfect (10/10)', Colors.green),
                      _buildLegendItem('Good (7-9/10)', Colors.orange),
                      _buildLegendItem('Poor (0-6/10)', Colors.red),
                      _buildLegendItem('Future', Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Calendar Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          childAspectRatio: 1,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                    itemCount: 75,
                    itemBuilder: (context, index) {
                      final dayNumber = index + 1;
                      final date = widget.startDate.add(Duration(days: index));

                      Color dayColor;
                      String tooltip;

                      if (dayNumber > widget.currentDay) {
                        dayColor = Colors.grey;
                        tooltip = 'Future day';
                      } else if (index < allProgress.length) {
                        final dayProgress = allProgress[index];
                        final completed = dayProgress.completedTasks;

                        if (completed == 10) {
                          dayColor = Colors.green;
                          tooltip = 'Perfect day: $completed/10';
                        } else if (completed >= 7) {
                          dayColor = Colors.orange;
                          tooltip = 'Good day: $completed/10';
                        } else {
                          dayColor = Colors.red;
                          tooltip = 'Needs improvement: $completed/10';
                        }
                      } else {
                        dayColor = Colors.red;
                        tooltip = 'No data: 0/10';
                      }

                      return Tooltip(
                        message:
                            'Day $dayNumber\n${date.day}/${date.month}\n$tooltip',
                        child: Container(
                          decoration: BoxDecoration(
                            color: dayColor,
                            borderRadius: BorderRadius.circular(8),
                            border: dayNumber == widget.currentDay
                                ? Border.all(color: Colors.black, width: 2)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '$dayNumber',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  Color _getColorForRate(double rate) {
    if (rate >= 0.9) return Colors.green;
    if (rate >= 0.7) return Colors.orange;
    if (rate >= 0.5) return Colors.yellow[700]!;
    return Colors.red;
  }
}
