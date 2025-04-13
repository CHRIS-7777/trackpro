import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
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

  // ⬇️ Replace this with your Gemini API key
  final String apiKey = 'YOUR_GEMINI_API_KEY';

  Future<void> _generateProjects() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _loading = true;
      _generatedProjects.clear();
    });

    final model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
    );

    final content = [Content.text("Give me 5 flutter app project ideas about: $prompt")];

    try {
      final response = await model.generateContent(content);
      final text = response.text ?? "";

      // Example Gemini response parser (basic bullet list)
      final ideas = text.split(RegExp(r'\d+\.\s+')).where((e) => e.trim().isNotEmpty).toList();

      setState(() {
        _generatedProjects.addAll(
          ideas.map((idea) {
            return {
              'title': idea.split(":").first.trim(),
              'description': idea.contains(":") ? idea.split(":").last.trim() : idea.trim(),
            };
          }),
        );
      });
    } catch (e) {
      print('Error: $e');
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
        title: const Text("Explore Projects"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Prompt Input
            TextField(
              controller: _promptController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search project ideas (e.g. AI, Health app)",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.greenAccent),
                  onPressed: _generateProjects,
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (_loading)
              const Center(child: CircularProgressIndicator(color: Colors.greenAccent)),

            // Project Cards
            Expanded(
              child: _generatedProjects.isEmpty && !_loading
                  ? const Center(
                      child: Text(
                        "Search for project ideas using the prompt above!",
                        style: TextStyle(color: Colors.white60),
                      ),
                    )
                  : ListView.builder(
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
                              icon: const Icon(Icons.star_border, color: Colors.greenAccent),
                              onPressed: () => _bookmarkProject(project),
                            ),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
