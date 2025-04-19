import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  final user = FirebaseAuth.instance.currentUser;
  int selectedIndex = 0;
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    final routes = ['/projects', '/explore', '/add', '/suggest', '/resume'];
    if (index < routes.length) {
      Navigator.pushNamed(context, routes[index]);
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
       title: Text(
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
          colors: [Colors.black, Color(0xFF0D1B2A)],
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
      return const Text(
        "Please log in to view bookmarked projects.",
        style: TextStyle(color: Colors.white54),
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
          return Text(
            "Error: ${snapshot.error}",
            style: const TextStyle(color: Colors.red),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.greenAccent),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Text(
            "No bookmarked projects yet.",
            style: TextStyle(color: Colors.white54),
          );
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _buildProjectCard(
              title: data['title'],
              description: data['description'],
              onDelete: () async {
                final confirmed = await _confirmDelete();
                if (confirmed) {
                  await doc.reference.delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Project removed")),
                  );
                }
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildOwnProjects() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('my_projects')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.greenAccent),
          );
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Text(
            "No own projects yet.",
            style: TextStyle(color: Colors.white54),
          );
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _buildProjectCard(
              title: data['title'],
              description: data['description'],
              onDelete: () async {
                final confirmed = await _confirmDelete();
                if (confirmed) {
                  await doc.reference.delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Own project deleted")),
                  );
                }
              },
            );
          }).toList(),
        );
      },
    );
  }

  Future<bool> _confirmDelete() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Confirm Deletion"),
            content:
                const Text("Are you sure you want to delete this project?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Delete"),
              ),
            ],
          ),
        ) ??
        false;
  }

 Widget _buildProjectCard({
  required String? title,
  required String? description,
  required VoidCallback onDelete,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF0F172A),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title ?? 'Untitled Project',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF22C55E), // Green accent
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description ?? 'No description provided',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 12),
        
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: const [
            Chip(
              label: Text("AI"),
              labelStyle: TextStyle(color: Colors.greenAccent),
              backgroundColor: Color.fromARGB(90, 105, 240, 175),
            ),
            Chip(
              label: Text("Flutter"),
           labelStyle: TextStyle(color: Colors.greenAccent),
              backgroundColor: Color.fromARGB(90, 105, 240, 175),
            ),
            Chip(
              label: Text("Dialogflow"),
              labelStyle: TextStyle(color: Colors.greenAccent),
              backgroundColor: Color.fromARGB(90, 105, 240, 175),
            ),
          ],
        ),
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: onDelete,
          ),
        )
      ],
    ),
  );
}

}
