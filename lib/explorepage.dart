import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> with SingleTickerProviderStateMixin {
  final TextEditingController _promptController = TextEditingController();
  final List<Map<String, String>> _generatedProjects = [];
  bool _loading = false;
  int _currentIndex = 1;
  int _selectedTab = 0; // 0: Roadmap, 1: Search Project

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    final routes = ['/projects', '/explore', '/add', '/suggest', '/resume'];
    if (index != 1 && index < routes.length) {
      Navigator.pushNamed(context, routes[index]);
    }
  }

  Future<void> _generateProjects() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _loading = true;
      _generatedProjects.clear();
    });

    try {
      final result = await Gemini.instance.text(
        "Suggest 5 popular projects related to the topic: $prompt",
      );

      final content = result?.output ?? '';
      final lines = content
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();

      setState(() {
        _generatedProjects.addAll(lines.map((line) {
          final parts = line.contains(':') ? line.split(':') : [line, "No description provided"];
          return {
            'title': parts[0].trim(),
            'description': parts.sublist(1).join(':').trim(),
          };
        }).toList());
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate ideas: $e')),
      );
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _bookmarkProject(Map<String, String> project) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please log in to bookmark projects")),
        );
        return;
      }

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('saved_projects')
          .doc();

      await docRef.set({
        'title': project['title'],
        'description': project['description'],
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Project saved!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save project: $e")),
      );
    }
  }

  Widget _buildToggleButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => setState(() => _selectedTab = 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: _selectedTab == 0 ? Colors.greenAccent : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Roadmap Flow",
                style: TextStyle(
                  color: _selectedTab == 0 ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _selectedTab = 1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: _selectedTab == 1 ? Colors.greenAccent : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Search Project",
                style: TextStyle(
                  color: _selectedTab == 1 ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmapSection() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          "Roadmap Coming Soon...",
          style: TextStyle(color: Colors.white70, fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSearchProjectSection() {
    return Column(
      children: [
        TextField(
          controller: _promptController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Search a Topic......",
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Colors.greenAccent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Colors.greenAccent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Colors.greenAccent, width: 2),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.send, color: Color.fromARGB(255, 255, 255, 255)),
              onPressed: _generateProjects,
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (_loading)
          const CircularProgressIndicator(color: Colors.greenAccent)
        else
          Expanded(
            child: _generatedProjects.isEmpty
                ? const Text(
                    "No projects generated yet.",
                    style: TextStyle(color: Color.fromARGB(93, 255, 255, 255)),
                  )
                : ListView.builder(
                    itemCount: _generatedProjects.length,
                    itemBuilder: (context, index) {
                      final project = _generatedProjects[index];
                      final description = project['description'] ?? '';
                      final shortDescription = description.length > 100
                          ? '${description.substring(0, 100)}...'
                          : description;

                      final domains = <String>[];
                      final lowerDesc = description.toLowerCase();
                      if (lowerDesc.contains('ai') || lowerDesc.contains('artificial intelligence')) domains.add('AI');
                      if (lowerDesc.contains('ml') || lowerDesc.contains('machine learning')) domains.add('ML');
                      if (lowerDesc.contains('flutter')) domains.add('Flutter');
                      if (lowerDesc.contains('react')) domains.add('React');
                      if (lowerDesc.contains('blockchain')) domains.add('Blockchain');
                      if (lowerDesc.contains('iot')) domains.add('IoT');
                      if (lowerDesc.contains('web') || lowerDesc.contains('frontend')) domains.add('Web');

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black.withOpacity(0.2), Colors.black.withOpacity(0.3)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.greenAccent.withOpacity(0.4), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.greenAccent.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                              offset: const Offset(2, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    project['title'] ?? '',
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 254, 254, 254),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (domains.isNotEmpty)
                                    Wrap(
                                      spacing: 8,
                                      children: domains.map((domain) {
                                        return Chip(
                                          label: Text(domain),
                                          backgroundColor: Colors.greenAccent.withOpacity(0.15),
                                          labelStyle: const TextStyle(color: Colors.white),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            side: const BorderSide(color: Colors.greenAccent),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  const SizedBox(height: 10),
                                  Text(
                                    shortDescription,
                                    style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                                  ),
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: InkWell(
                                      onTap: () => _bookmarkProject(project),
                                      borderRadius: BorderRadius.circular(30),
                                      child: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Icon(Icons.bookmark_border, color: Colors.greenAccent),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.greenAccent),
          onPressed: () => Navigator.pushNamed(context, '/dash'),
        ),
        title: const Text('🕵🏻 Explore', style: TextStyle(color: Colors.greenAccent, fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
        gradient: LinearGradient(
         colors: [Colors.black, Color.fromARGB(255, 0, 0, 0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildToggleButtons(),
                const SizedBox(height: 20),
                Expanded(
                  child: _selectedTab == 0 ? _buildRoadmapSection() : _buildSearchProjectSection(),
                ),
              ],
            ),
          ),
        ),
      ),
     bottomNavigationBar: Container(
 

  child: ClipRRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        elevation: 0,
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.white.withOpacity(0.7),
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Projects'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.recommend), label: 'Suggest'),
          BottomNavigationBarItem(icon: Icon(Icons.document_scanner), label: 'Resume'),
        ],
      ),
    ),
  ),
),
    );
  }
}