import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _promptController = TextEditingController();
  final List<Map<String, String>> _generatedProjects = [];
  bool _loading = false;

  // Method to generate projects based on the user prompt
Future<void> _generateProjects() async {
  final prompt = _promptController.text.trim();
  if (prompt.isEmpty) return;

  setState(() {
    _loading = true;
    _generatedProjects.clear();
  });

  try {
    final result = await Gemini.instance.text(
      "Suggest 5 project popular projects related to the topic: $prompt",
    );

    print("Gemini Response: $result");

   final content = result?.output ?? '';  // safer than assuming .text
    final lines = content
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();

    setState(() {
      _generatedProjects.addAll(lines.map((line) {
        final parts = line.contains(':') ? line.split(':') : [line, ""];
        return {
          'title': parts[0].trim(),
          'description': parts.length > 1
              ? parts.sublist(1).join(':').trim()
              : 'No description provided',
        };
      }).toList());
    });
  } catch (e, stack) {
    print("Error: $e\nStack: $stack");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to generate ideas: $e')),
    );
  }

  setState(() {
    _loading = false;
  });
}


  Future<void> _bookmarkProject(Map<String, String> project) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('saved_projects')
        .add({
      'title': project['title'],
      'description': project['description'],
      'createdAt': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Project saved!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          "Explore Projects",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _promptController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search ideas…",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.greenAccent),
                  onPressed: _generateProjects,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_loading)
              const Center(child: CircularProgressIndicator(color: Colors.greenAccent))
            else if (_generatedProjects.isEmpty)
              const Center(
                child: Text("No projects yet. Start by entering a prompt!",
                    style: TextStyle(color: Colors.white70)),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _generatedProjects.length,
                  itemBuilder: (context, index) {
                    final project = _generatedProjects[index];
                    return Card(
                      color: const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(project['title'] ?? '',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(project['description'] ?? '',
                            style: const TextStyle(color: Colors.white70)),
                        trailing: IconButton(
                          icon: const Icon(Icons.bookmark_border, color: Colors.greenAccent),
                          onPressed: () => _bookmarkProject(project),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
