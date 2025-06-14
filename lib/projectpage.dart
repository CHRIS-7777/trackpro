import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'roadmap_page.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  final user = FirebaseAuth.instance.currentUser;
  int selectedIndex = 0;
  int _currentIndex = 0;
  final Map<String, bool> _loadingStates = {};

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    final routes = ['/projects', '/explore', '/add', '/suggest', '/resume'];
    if (index < routes.length) {
      Navigator.pushNamed(context, routes[index]);
    }
  }

  Future<void> showRoadmapDialog(String title, String docId) async {
    if (!mounted) return;
    
    setState(() => _loadingStates[docId] = true);
    
    try {
      final result = await Gemini.instance.text(
        "Generate a detailed roadmap for learning about: $title\n"
        "Include:\n"
        "1. Key milestones\n"
        "2. Recommended resources\n"
        "3. Estimated time for each step\n"
        "4. Prerequisites\n\n"
        "Format as a numbered list with clear headings."
      );

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RoadmapPage(
            title: title,
            content: result?.output ?? "No content generated",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate roadmap: ${e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loadingStates.remove(docId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.greenAccent),
          onPressed: () => Navigator.pushNamed(context, '/dash'),
        ),
        title: const Text(
          '🎯 Projects',
          style: TextStyle(
            color: Colors.greenAccent,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
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
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildToggleButton("Bookmarked", 0),
                    _buildToggleButton("My Projects", 1),
                  ],
                ),
              ),
              Expanded(
                child: selectedIndex == 0
                    ? _buildBookmarkedProjects()
                    : _buildOwnProjects(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        elevation: 0,
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.white,
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
    );
  }

  Widget _buildToggleButton(String title, int index) {
    bool isSelected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.greenAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookmarkedProjects() {
    if (user == null) {
      return const Center(
        child: Text(
          "Please log in to view bookmarked projects",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('saved_projects')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${snapshot.error}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.greenAccent),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Text(
              "No bookmarked projects yet",
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            return _buildProjectCard(
              title: data['title'] ?? 'Untitled Project',
              description: data['description'] ?? 'No description',
              onDelete: () => _confirmDelete(doc.reference),
              onLearnMore: () => showRoadmapDialog(data['title'] ?? 'Project', doc.id),
              isLoading: _loadingStates.containsKey(doc.id),
            );
          },
        );
      },
    );
  }

  Widget _buildOwnProjects() {
    if (user == null) {
      return const Center(
        child: Text(
          "Please log in to view your projects",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('my_projects')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${snapshot.error}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.greenAccent),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Text(
              "No projects created yet",
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            return _buildProjectCard(
              title: data['title'] ?? 'Untitled Project',
              description: data['description'] ?? 'No description',
              onDelete: () => _confirmDelete(doc.reference),
              onLearnMore: () => showRoadmapDialog(data['title'] ?? 'Project', doc.id),
              isLoading: _loadingStates.containsKey(doc.id),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(DocumentReference docRef) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this project?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await docRef.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Project deleted"),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete: ${e.toString()}"),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

Widget _buildProjectCard({
  required String title,
  required String description,
  required VoidCallback onDelete,
  required VoidCallback onLearnMore,
  required bool isLoading,
}) {
  // Sample technology tags – you can replace this with dynamic data later
  final List<String> techList = [
    'Flutter',
    'Dart',
    'Firebase (for backend simulation)',
    'Provider/Riverpod (state management)',
    'HTTP requests',
  ];

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.5),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.greenAccent.withOpacity(0.4)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Title with stacked lines
        Text(
          title.replaceAll(' ', ' '),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.greenAccent,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 10),

        // 🔹 Short project summary
        Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 14),

        // 🔹 Technologies section
        const Text(
          'Technologies',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: techList.map((tech) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                tech,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // 🔹 Roadmap Section
        const Text(
          'Roadmap',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '## Flutter-Powered Smart Home Dashboard: Project Roadmap',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 2),
        GestureDetector(
          onTap: onLearnMore,
          child: const Text(
            'View Roadmap Tracker',
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 13,
              decoration: TextDecoration.underline,
            ),
          ),
        ),

        const SizedBox(height: 14),

        // 🔹 Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: isLoading ? null : onLearnMore,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.greenAccent,
                side: const BorderSide(color: Colors.greenAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.greenAccent,
                        strokeWidth: 3,
                      ),
                    )
                  : const Text("Generate Roadmap"),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: isLoading ? null : onDelete,
            ),
          ],
        ),
      ],
    ),
  );
}


}