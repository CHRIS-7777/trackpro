import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class RoadmapTrackerPage extends StatefulWidget {
  const RoadmapTrackerPage({Key? key}) : super(key: key);

  @override
  State<RoadmapTrackerPage> createState() => _RoadmapTrackerPageState();
}

class _RoadmapTrackerPageState extends State<RoadmapTrackerPage> {
  final user = FirebaseAuth.instance.currentUser;
  late Future<List<DocumentSnapshot>> _roadmapsFuture;

  @override
  void initState() {
    super.initState();
    _roadmapsFuture = _fetchTrackedProjects();
  }

  Future<List<DocumentSnapshot>> _fetchTrackedProjects() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('tracked_projects')
        .doc(user!.uid)
        .collection('projects')
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs;
  }

  Future<void> _toggleTaskStatus(String projectId, int taskIndex, bool status) async {
    final projectRef = FirebaseFirestore.instance
        .collection('tracked_projects')
        .doc(user!.uid)
        .collection('projects')
        .doc(projectId);

    final projectSnapshot = await projectRef.get();
    if (!projectSnapshot.exists) return;

    List<dynamic> tasks = List.from(projectSnapshot.data()!['tasks']);
    tasks[taskIndex]['completed'] = status;

    await projectRef.update({'tasks': tasks});
  }

  double _calculateProgress(List tasks) {
    if (tasks.isEmpty) return 0.0;
    final completedCount = tasks.where((task) => task['completed'] == true).length;
    return completedCount / tasks.length;
  }

  Widget _buildTaskList(String projectId, List tasks) {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => Divider(),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return CheckboxListTile(
          title: Text(task['title']),
          subtitle: task['pdfLink'] != null && task['pdfLink'].toString().isNotEmpty
              ? GestureDetector(
                  onTap: () => launchUrl(Uri.parse(task['pdfLink'])),
                  child: Text("View PDF", style: TextStyle(color: Colors.blue)),
                )
              : null,
          value: task['completed'] ?? false,
          onChanged: (value) async {
            await _toggleTaskStatus(projectId, index, value!);
            setState(() {}); // Refresh UI
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tracked Projects"),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _roadmapsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No tracked projects found."));
          }

          final projects = snapshot.data!;
          return ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final doc = projects[index];
              final title = doc['title'];
              final tasks = List.from(doc['tasks']);
              final progress = _calculateProgress(tasks);

              return Card(
                margin: EdgeInsets.all(12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.grey[900],
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: progress,
                        color: Colors.green,
                        backgroundColor: Colors.grey,
                        minHeight: 8,
                      ),
                      SizedBox(height: 10),
                      Text("${(progress * 100).toStringAsFixed(1)}% Completed",
                          style: TextStyle(color: Colors.white70)),
                      _buildTaskList(doc.id, tasks),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
