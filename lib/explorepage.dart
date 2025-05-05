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
  final TextEditingController _roadmapTechController = TextEditingController();
  final List<Map<String, String>> _generatedProjects = [];
  bool _loading = false;
  bool _roadmapLoading = false;
  int _currentIndex = 1;
  int _selectedTab = 0;
  String? _generatedRoadmap;
  List<String> _roadmapSteps = [];

  // Dropdown options
  String _selectedGoalLevel = 'Beginner';
  final List<String> _goalLevels = ['Beginner', 'Intermediate', 'Advanced'];
  
  String _selectedTimeframe = '3 months';
  final List<String> _timeframes = ['1 month', '3 months', '6 months', '1 year'];

  @override
  void initState() {
    super.initState();
    _roadmapTechController.text = 'React';
  }

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

  Future<void> _generateRoadmap() async {
    final tech = _roadmapTechController.text.trim();
    if (tech.isEmpty) return;

    setState(() {
      _roadmapLoading = true;
      _generatedRoadmap = null;
      _roadmapSteps = [];
    });

    try {
      final prompt = """
      Create a detailed learning roadmap for $tech at $_selectedGoalLevel level 
      to be completed in $_selectedTimeframe. 
      Provide the roadmap as a numbered list of steps with clear milestones.
      Each step should be concise but informative.
      Format each step as: "1. [Step description]"
      """;

      final result = await Gemini.instance.text(prompt);
      final content = result?.output ?? 'No roadmap generated';

      // Parse the response into individual steps
      final steps = content.split('\n')
          .where((line) => line.trim().isNotEmpty && line.trim()[0].contains(RegExp(r'[0-9]')))
          .map((line) => line.trim())
          .toList();

      setState(() {
        _generatedRoadmap = content;
        _roadmapSteps = steps;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate roadmap: $e')),
      );
    }

    setState(() {
      _roadmapLoading = false;
    });
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
                "Roadmap ",
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
                "  Project  ",
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Generate Learning Roadmap',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter a technology or skill to generate a personalized learning roadmap',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          
          // Technology Input
          Text(
            'Technology',
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _roadmapTechController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter technology (e.g. React, Flutter)",
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.black.withOpacity(0.4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.greenAccent),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.greenAccent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.greenAccent, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Goal Level Dropdown
          Text(
            'Goal Level',
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.greenAccent),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<String>(
              value: _selectedGoalLevel,
              isExpanded: true,
              dropdownColor: Colors.black.withOpacity(0.9),
              underline: const SizedBox(),
              style: const TextStyle(color: Colors.white),
              items: _goalLevels.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGoalLevel = newValue!;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          
          // Timeframe Dropdown
          Text(
            'Timeframe',
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.greenAccent),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<String>(
              value: _selectedTimeframe,
              isExpanded: true,
              dropdownColor: Colors.black.withOpacity(0.9),
              underline: const SizedBox(),
              style: const TextStyle(color: Colors.white),
              items: _timeframes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTimeframe = newValue!;
                });
              },
            ),
          ),
          const SizedBox(height: 32),
          
          // Generate Roadmap Button
          Center(
            child: ElevatedButton(
              onPressed: _generateRoadmap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _roadmapLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 3,
                      ),
                    )
                  : const Text(
                      'Generate Roadmap',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Roadmap Display
          if (_roadmapLoading)
            const Center(child: CircularProgressIndicator(color: Colors.greenAccent))
          else if (_roadmapSteps.isNotEmpty)
            _buildRoadmapVisualization()
          else if (_generatedRoadmap != null)
            Text(
              _generatedRoadmap!,
              style: const TextStyle(color: Colors.white70),
            ),
        ],
      ),
    );
  }

  Widget _buildRoadmapVisualization() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.greenAccent),
            boxShadow: [
              BoxShadow(
                color: Colors.greenAccent.withOpacity(0.1),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Text(
            'Your Learning Path Flow',
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: _roadmapSteps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.greenAccent.withOpacity(0.7), width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.greenAccent),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          step,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (index != _roadmapSteps.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        Container(
                          height: 20,
                          width: 2,
                          color: Colors.greenAccent.withOpacity(0.5),
                        ),
                        Icon(
                          Icons.arrow_downward,
                          color: Colors.greenAccent.withOpacity(0.8),
                          size: 25,
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }).toList(),
        ),
      ],
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