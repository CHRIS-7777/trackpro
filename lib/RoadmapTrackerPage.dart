import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    );
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

    // Group tasks by phase
    final phases = <String, List<Map<String, dynamic>>>{};
    for (var task in tasks) {
      final phase = task['phase'] ?? 'Uncategorized';
      if (!phases.containsKey(phase)) {
        phases[phase] = [];
      }
      phases[phase]!.add(task);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Summary
            Card(
              color: Colors.grey[900],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tasks Completed',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              '$completedTasks/${tasks.length}',
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Completion Rate',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              '$completionRate%',
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Overall Progress',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: completionRate / 100,
                      backgroundColor: Colors.grey[800],
                      color: Colors.greenAccent,
                      minHeight: 10,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Milestones',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...phases.keys.map((phase) {
                      final phaseTasks = phases[phase]!;
                      final phaseCompleted = phaseTasks.where((t) => t['completed'] == true).length;
                      final phaseRate = phaseTasks.isEmpty ? 0 : (phaseCompleted / phaseTasks.length * 100).round();
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                phase,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                            Text(
                              '$phaseRate%',
                              style: TextStyle(
                                color: phaseRate == 100 ? Colors.greenAccent : Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tasks & Milestones',
              style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Tasks by phase
            ...phases.entries.map((entry) {
              final phase = entry.key;
              final phaseTasks = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phase: $phase',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...phaseTasks.map((task) {
                    return Card(
                      color: Colors.grey[850],
                      margin: const EdgeInsets.only(bottom: 8),
                      child: CheckboxListTile(
                        title: Text(
                          task['name'] ?? 'Unnamed Task',
                          style: TextStyle(
                            color: task['completed'] == true 
                                ? Colors.greenAccent 
                                : Colors.white,
                            decoration: task['completed'] == true 
                                ? TextDecoration.lineThrough 
                                : null,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (task['description'] != null)
                              Text(
                                task['description'],
                                style: const TextStyle(color: Colors.white70),
                              ),
                            if (task['duration'] != null)
                              Text(
                                'Duration: ${task['duration']}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            if (task['skills'] != null)
                              Text(
                                'Skills: ${task['skills']}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                          ],
                        ),
                        value: task['completed'] == true,
                        onChanged: (value) async {
                          setState(() {
                            task['completed'] = value;
                          });
                          
                          // Update in Firebase
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .collection('roadmap_tracker')
                              .doc(widget.roadmapId)
                              .update({
                            'tasks': tasks,
                          });
                        },
                        activeColor: Colors.greenAccent,
                        checkColor: Colors.black,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}