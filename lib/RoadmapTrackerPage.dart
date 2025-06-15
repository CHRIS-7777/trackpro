import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class RoadmapTrackerPage extends StatefulWidget {
  const RoadmapTrackerPage({super.key});

  @override
  State<RoadmapTrackerPage> createState() => _RoadmapTrackerPageState();
}

class _RoadmapTrackerPageState extends State<RoadmapTrackerPage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Tracked Roadmaps'),
          backgroundColor: Colors.black,
        ),
        body: const Center(
          child: Text(
            '⚠️ Please log in to view your tracked roadmaps.',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Track Roadmaps"),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('roadmap_tracker')
            .orderBy('savedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                '📭 No roadmaps tracked yet.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final projects = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final doc = projects[index];
              final data = doc.data() as Map<String, dynamic>;
              final tasks = List<Map<String, dynamic>>.from(data['tasks'] ?? []);
              final completedTasks = tasks.where((task) => task['completed'] == true).length;
              final completionRate = tasks.isEmpty ? 0 : (completedTasks / tasks.length * 100).round();

              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    data['title'] ?? 'Untitled',
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (data['description'] ?? 'No description').toString().length > 100
                            ? '${data['description'].toString().substring(0, 100)}...'
                            : data['description'] ?? 'No description',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: completionRate / 100,
                        backgroundColor: Colors.grey[800],
                        color: Colors.greenAccent,
                        minHeight: 6,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$completionRate% completed ($completedTasks/${tasks.length} tasks)',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.greenAccent,
                    size: 16,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoadmapDetailPage(
                          roadmapId: doc.id,
                          title: data['title'] ?? 'Untitled',
                          description: data['description'] ?? '',
                          tasks: tasks,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        onPressed: () => _showAddRoadmapDialog(context, user.uid),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Future<void> _showAddRoadmapDialog(BuildContext context, String userId) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Add New Roadmap', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.greenAccent),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.greenAccent),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Title is required'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(color: Colors.greenAccent),
                ),
              );

              final generatedTasks = await _generateRoadmapTasks(
                titleController.text, 
                descriptionController.text
              );
              
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('roadmap_tracker')
                  .add({
                'title': titleController.text,
                'description': descriptionController.text,
                'tasks': generatedTasks,
                'savedAt': FieldValue.serverTimestamp(),
              });
              
              if (!mounted) return;
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Generate Roadmap', style: TextStyle(color: Colors.greenAccent)),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _generateRoadmapTasks(String title, String description) async {
    try {
      final gemini = Gemini.instance;
      
      final prompt = """
      Generate a detailed 12-week Flutter project roadmap for "$title" with the following structure:
      
      - Divide into 4 main phases (Planning & Setup, Core Development, Feature Implementation, Testing & Refinement)
      - Each phase should have:
        * A milestone with date (spread across 12 weeks)
        * 5-7 tasks with:
          - Name
          - Description
          - Estimated duration
          - Required skills/technologies
          - Due date (spread throughout the phase)
      
      Return the response as a JSON-parsable list with these fields for each task:
      - name
      - description
      - phase
      - duration
      - skills
      - dueDate (format: "MMM d, yyyy")
      - isMilestone
      - completed (always false initially)
      
      Example response:
      [
        {
          "name": "Project Setup",
          "description": "Set up development environment",
          "phase": "Planning & Setup Phase",
          "duration": "2 days",
          "skills": "Flutter, Dart, IDE setup",
          "dueDate": "Jun 15, 2025",
          "isMilestone": false,
          "completed": false
        },
        {
          "name": "Milestone: Planning Complete",
          "description": "Complete all planning tasks",
          "phase": "Planning & Setup Phase",
          "duration": "1 week",
          "skills": "Project planning",
          "dueDate": "Jun 22, 2025",
          "isMilestone": true,
          "completed": false
        }
      ]
      """;

      final response = await gemini.text(prompt);
      final jsonString = response?.output ?? '[]';
      final List<dynamic> jsonList = json.decode(jsonString);
      
      return jsonList.map((item) {
        final task = Map<String, dynamic>.from(item);
        task['completed'] = false;
        return task;
      }).toList();
    } catch (e) {
      print('Error generating roadmap: $e');
      return _getDefaultTasks(title);
    }
  }

  List<Map<String, dynamic>> _getDefaultTasks(String title) {
    final now = DateTime.now();
    return [
      // Planning Phase
      {
        'name': 'Project Setup',
        'description': 'Set up Flutter environment and tools',
        'phase': 'Planning & Setup Phase',
        'duration': '2 days',
        'skills': 'Flutter, Dart, IDE setup',
        'dueDate': DateFormat('MMM d, yyyy').format(now.add(const Duration(days: 2))),
        'isMilestone': false,
        'completed': false,
      },
      {
        'name': 'Project Architecture',
        'description': 'Design app architecture and folder structure',
        'phase': 'Planning & Setup Phase',
        'duration': '3 days',
        'skills': 'Software architecture',
        'dueDate': DateFormat('MMM d, yyyy').format(now.add(const Duration(days: 5))),
        'isMilestone': false,
        'completed': false,
      },
      {
        'name': 'Milestone: Planning Complete',
        'description': 'Complete all planning tasks',
        'phase': 'Planning & Setup Phase',
        'duration': '1 week',
        'skills': 'Project planning',
        'dueDate': DateFormat('MMM d, yyyy').format(now.add(const Duration(days: 7))),
        'isMilestone': true,
        'completed': false,
      },
      
      // Core Development Phase
      {
        'name': 'UI Components',
        'description': 'Implement core UI components',
        'phase': 'Core Development Phase',
        'duration': '5 days',
        'skills': 'Flutter widgets, UI design',
        'dueDate': DateFormat('MMM d, yyyy').format(now.add(const Duration(days: 10))),
        'isMilestone': false,
        'completed': false,
      },
      {
        'name': 'State Management',
        'description': 'Implement state management solution',
        'phase': 'Core Development Phase',
        'duration': '4 days',
        'skills': 'Provider/Riverpod/Bloc',
        'dueDate': DateFormat('MMM d, yyyy').format(now.add(const Duration(days: 14))),
        'isMilestone': false,
        'completed': false,
      },
      {
        'name': 'API Integration',
        'description': 'Connect to backend services',
        'phase': 'Core Development Phase',
        'duration': '5 days',
        'skills': 'HTTP, REST API',
        'dueDate': DateFormat('MMM d, yyyy').format(now.add(const Duration(days: 19))),
        'isMilestone': false,
        'completed': false,
      },
      {
        'name': 'Milestone: Core Features Complete',
        'description': 'Complete all core functionality',
        'phase': 'Core Development Phase',
        'duration': '3 weeks',
        'skills': 'Flutter development',
        'dueDate': DateFormat('MMM d, yyyy').format(now.add(const Duration(days: 28))),
        'isMilestone': true,
        'completed': false,
      },
      
      // Feature Implementation Phase
      {
        'name': 'User Authentication',
        'description': 'Implement login/signup flows',
        'phase': 'Feature Implementation Phase',
        'duration': '5 days',
        'skills': 'Firebase Auth',
        'dueDate': DateFormat('MMM d, yyyy').format(now.add(const Duration(days: 33))),
        'isMilestone': false,
        'completed': false,
      },
      {
        'name': 'Advanced Features',
        'description': 'Implement premium features',
        'phase': 'Feature Implementation Phase',
        'duration': '7 days',
        'skills': 'Flutter, Payment integration',
        'dueDate': DateFormat('MMM d, yyyy').format(now.add(const Duration(days: 40))),
        'isMilestone': false,
        'completed': false,
      },
      {
        'name': 'Milestone: Features Complete',
        'description': 'All planned features implemented',
        'phase': 'Feature Implementation Phase',
        'duration': '2 weeks',
        'skills': 'Feature development',
        'dueDate': DateFormat('MMM d, yyyy').format(now.add(const Duration(days: 49))),
        'isMilestone': true,
        'completed': false,
      },
      
      // Testing Phase
      {
        'name': 'Unit Testing',
        'description': 'Write unit tests for critical components',
        'phase': 'Testing & Refinement Phase',
        'duration': '4 days',
        'skills': 'Testing, Mocking',
        'dueDate': DateFormat('MMM d, yyyy').format(now.add(const Duration(days: 53))),
        'isMilestone': false,
        'completed': false,
      },
      {
        'name': 'UI Testing',
        'description': 'Test all user flows',
        'phase': 'Testing & Refinement Phase',
        'duration': '3 days',
        'skills': 'Integration testing',
        'dueDate': DateFormat('MMM d, yyyy').format(now.add(const Duration(days: 56))),
        'isMilestone': false,
        'completed': false,
      },
      {
        'name': 'Performance Optimization',
        'description': 'Improve app performance',
        'phase': 'Testing & Refinement Phase',
        'duration': '4 days',
        'skills': 'Performance tuning',
        'dueDate': DateFormat('MMM d, yyyy').format(now.add(const Duration(days: 60))),
        'isMilestone': false,
        'completed': false,
      },
      {
        'name': 'Milestone: Testing Complete',
        'description': 'All tests passed and ready for launch',
        'phase': 'Testing & Refinement Phase',
        'duration': '2 weeks',
        'skills': 'Quality assurance',
        'dueDate': DateFormat('MMM d, yyyy').format(now.add(const Duration(days: 70))),
        'isMilestone': true,
        'completed': false,
      },
    ];
  }
}

class RoadmapDetailPage extends StatefulWidget {
  final String roadmapId;
  final String title;
  final String description;
  final List<Map<String, dynamic>> tasks;

  const RoadmapDetailPage({
    super.key,
    required this.roadmapId,
    required this.title,
    required this.description,
    required this.tasks,
  });

  @override
  State<RoadmapDetailPage> createState() => _RoadmapDetailPageState();
}

class _RoadmapDetailPageState extends State<RoadmapDetailPage> {
  late List<Map<String, dynamic>> tasks;

  @override
  void initState() {
    super.initState();
    tasks = widget.tasks;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Container();

    final completedTasks = tasks.where((task) => task['completed'] == true).length;
    final completionRate = tasks.isEmpty ? 0 : (completedTasks / tasks.length * 100).round();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.greenAccent),
            onPressed: () => _regenerateRoadmap(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Summary Card
          Card(
            color: Colors.grey[900],
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Progress Summary',
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildProgressStat('Tasks Completed', '$completedTasks/${tasks.length}'),
                      _buildProgressStat('Completion Rate', '$completionRate%'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: completionRate / 100,
                    backgroundColor: Colors.grey[800],
                    color: Colors.greenAccent,
                    minHeight: 10,
                  ),
                ],
              ),
            ),
          ),
          
          // Roadmap Timeline
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Project Roadmap',
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._buildRoadmapTimeline(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.greenAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRoadmapTimeline() {
    final phases = <String, List<Map<String, dynamic>>>{};
    for (var task in tasks) {
      final phase = task['phase'] ?? 'Uncategorized';
      if (!phases.containsKey(phase)) {
        phases[phase] = [];
      }
      phases[phase]!.add(task);
    }

    return phases.entries.map((entry) {
      final phaseName = entry.key;
      final phaseTasks = entry.value;
      final milestone = phaseTasks.firstWhere(
        (task) => task['isMilestone'] == true,
        orElse: () => {},
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phase Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.flag, color: Colors.greenAccent, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    phaseName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (milestone.isNotEmpty && milestone['dueDate'] != null)
                  Text(
                    milestone['dueDate'],
                    style: const TextStyle(color: Colors.white70),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Tasks List
          ...phaseTasks.where((task) => task['isMilestone'] != true).map((task) {
            return _buildTaskItem(task);
          }).toList(),
          
          const SizedBox(height: 16),
        ],
      );
    }).toList();
  }

  Widget _buildTaskItem(Map<String, dynamic> task) {
    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: task['completed'] == true,
                  onChanged: (value) => _toggleTaskCompletion(task),
                  activeColor: Colors.greenAccent,
                  checkColor: Colors.black,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task['name'] ?? 'Unnamed Task',
                    style: TextStyle(
                      color: task['completed'] == true 
                          ? Colors.greenAccent 
                          : Colors.white,
                      decoration: task['completed'] == true 
                          ? TextDecoration.lineThrough 
                          : null,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            
            // Task Details
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (task['description'] != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        task['description'],
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      if (task['dueDate'] != null)
                        _buildTaskDetail(Icons.calendar_today, task['dueDate']),
                      if (task['duration'] != null)
                        _buildTaskDetail(Icons.timer, task['duration']),
                      if (task['skills'] != null)
                        _buildTaskDetail(Icons.code, task['skills']),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskDetail(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }

  Future<void> _toggleTaskCompletion(Map<String, dynamic> task) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      task['completed'] = !(task['completed'] == true);
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('roadmap_tracker')
        .doc(widget.roadmapId)
        .update({
      'tasks': tasks,
    });
  }

  Future<void> _regenerateRoadmap(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.greenAccent),
      ),
    );

    try {
      final generatedTasks = await _generateRoadmapTasks(widget.title, widget.description);
      
      setState(() {
        tasks = generatedTasks;
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('roadmap_tracker')
          .doc(widget.roadmapId)
          .update({
        'tasks': tasks,
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to regenerate roadmap: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<List<Map<String, dynamic>>> _generateRoadmapTasks(String title, String description) async {
    try {
      final gemini = Gemini.instance;
      
      final prompt = """
      Generate a detailed Flutter project roadmap for "$title" with:
      - 4 phases (Planning, Development, Features, Testing)
      - 5-7 tasks per phase
      - Include milestones
      - Add realistic durations and skills
      - Format dates as "MMM d, yyyy"
      
      Return as JSON with these fields:
      - name, description, phase
      - duration, skills, dueDate
      - isMilestone, completed (false)
      """;

      final response = await gemini.text(prompt);
      final jsonString = response?.output ?? '[]';
      final List<dynamic> jsonList = json.decode(jsonString);
      
      return jsonList.map((item) {
        final task = Map<String, dynamic>.from(item);
        task['completed'] = false;
        return task;
      }).toList();
    } catch (e) {
      print('Error generating roadmap: $e');
      return _getDefaultTasks(title);
    }
  }

  List<Map<String, dynamic>> _getDefaultTasks(String title) {
    final now = DateTime.now();
    return [
      // Planning Phase
      {
        'name': 'Project Setup',
        'description': 'Set up development environment',
        'phase': 'Planning Phase',
        'duration': '2 days',
        'skills': 'Flutter, Dart, IDE',
        'dueDate': DateFormat('MMM d, yyyy').format(now.add(const Duration(days: 2))),
        'isMilestone': false,
        'completed': false,
      },
      {
        'name': 'UI Design',
        'description': 'Create app wireframes and design',
        'phase': 'Planning Phase',
        'duration': '3 days',
        'skills': 'Figma, UI/UX',
        'dueDate': DateFormat('MMM d, yyyy').format(now.add(const Duration(days: 5))),
        'isMilestone': false,
        'completed': false,
      },
      {
        'name': 'Milestone: Planning Complete',
        'description': 'All planning tasks finished',
        'phase': 'Planning Phase',
        'duration': '1 week',
        'skills': 'Planning',
        'dueDate': DateFormat('MMM d, yyyy').format(now.add(const Duration(days: 7))),
        'isMilestone': true,
        'completed': false,
      },
      
      // Development Phase
      {
        'name': 'Core UI Components',
        'description': 'Build main app screens',
        'phase': 'Development Phase',
        'duration': '5 days',
        'skills': 'Flutter widgets',
        'dueDate': DateFormat('MMM d, yyyy').format(now.add(const Duration(days: 12))),
        'isMilestone': false,
        'completed': false,
      },
      {
        'name': 'State Management',
        'description': 'Implement app state solution',
        'phase': 'Development Phase',
        'duration': '4 days',
        'skills': 'Provider/Riverpod',
        'dueDate': DateFormat('MMM d, yyyy').format(now.add(const Duration(days: 16))),
        'isMilestone': false,
        'completed': false,
      },
      {
        'name': 'API Integration',
        'description': 'Connect to backend services',
        'phase': 'Development Phase',
        'duration': '5 days',
        'skills': 'REST API, HTTP',
        'dueDate': DateFormat('MMM d, yyyy').format(now.add(const Duration(days: 21))),
        'isMilestone': false,
        'completed': false,
      },
      {
        'name': 'Milestone: Core Complete',
        'description': 'Main functionality implemented',
        'phase': 'Development Phase',
        'duration': '3 weeks',
        'skills': 'Development',
        'dueDate': DateFormat('MMM d, yyyy').format(now.add(const Duration(days: 28))),
        'isMilestone': true,
        'completed': false,
      },
      
      // Features Phase
      {
        'name': 'User Authentication',
        'description': 'Add login/signup flows',
        'phase': 'Features Phase',
        'duration': '5 days',
        'skills': 'Firebase Auth',
        'dueDate': DateFormat('MMM d, yyyy').format(now.add(const Duration(days: 33))),
        'isMilestone': false,
        'completed': false,
      },
      {
        'name': 'Advanced Features',
        'description': 'Implement premium features',
        'phase': 'Features Phase',
        'duration': '7 days',
        'skills': 'Flutter, Payments',
        'dueDate': DateFormat('MMM d, yyyy').format(now.add(const Duration(days: 40))),
        'isMilestone': false,
        'completed': false,
      },
      {
        'name': 'Milestone: Features Complete',
        'description': 'All features implemented',
        'phase': 'Features Phase',
        'duration': '2 weeks',
        'skills': 'Feature development',
        'dueDate': DateFormat('MMM d, yyyy').format(now.add(const Duration(days: 49))),
        'isMilestone': true,
        'completed': false,
      },
      
      // Testing Phase
      {
        'name': 'Unit Testing',
        'description': 'Test critical components',
        'phase': 'Testing Phase',
        'duration': '4 days',
        'skills': 'Testing',
        'dueDate': DateFormat('MMM d, yyyy').format(now.add(const Duration(days: 53))),
        'isMilestone': false,
        'completed': false,
      },
      {
        'name': 'UI Testing',
        'description': 'Test all user flows',
        'phase': 'Testing Phase',
        'duration': '3 days',
        'skills': 'Integration testing',
        'dueDate': DateFormat('MMM d, yyyy').format(now.add(const Duration(days: 56))),
        'isMilestone': false,
        'completed': false,
      },
      {
        'name': 'Performance Tuning',
        'description': 'Optimize app performance',
        'phase': 'Testing Phase',
        'duration': '4 days',
        'skills': 'Performance',
        'dueDate': DateFormat('MMM d, yyyy').format(now.add(const Duration(days: 60))),
        'isMilestone': false,
        'completed': false,
      },
      {
        'name': 'Milestone: Ready for Launch',
        'description': 'All tests passed',
        'phase': 'Testing Phase',
        'duration': '2 weeks',
        'skills': 'QA',
        'dueDate': DateFormat('MMM d, yyyy').format(now.add(const Duration(days: 70))),
        'isMilestone': true,
        'completed': false,
      },
    ];
  }
}