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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/dash'),
        ),
        title: const Text("Projects", style: TextStyle(color: Colors.greenAccent)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("🔖 Bookmarked Projects",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildBookmarkedProjects(),

          const SizedBox(height: 30),
          const Text("🛠️ Own Projects",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildOwnProjects(),
        ],
      ),
    );
  }

  Widget _buildBookmarkedProjects() {
  if (user == null) {
    return const Text("Please log in to view bookmarked projects.",
        style: TextStyle(color: Colors.white54));
  }

  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('saved_projects')
        .orderBy('createdAt', descending: true)
        .snapshots(),
    builder: (context, snapshot) {
      // Add some debugging
      if (snapshot.hasError) {
        print("Firestore error: ${snapshot.error}");
        return Text("Error: ${snapshot.error}",
            style: TextStyle(color: Colors.red));
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
      }

      final docs = snapshot.data?.docs ?? [];
      if (docs.isEmpty) {
        return const Text("No bookmarked projects yet.",
            style: TextStyle(color: Colors.white54));
      }

      // Add debugging to check the data
      print("Found ${docs.length} bookmarked projects");
      
      return Column(
        children: docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          print("Project data: $data"); // Debug what data is coming through
          
          return Card(
            color: const Color(0xFF1E293B),
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(data['title'] ?? 'Untitled Project',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(data['description'] ?? 'No description available',
                  style: const TextStyle(color: Colors.white70)),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () {
                  // Add delete functionality
                  doc.reference.delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Project removed")),
                  );
                },
              ),
            ),
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
          return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Text("No own projects yet.",
              style: TextStyle(color: Colors.white54));
        }

        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(data['title'] ?? '',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text(data['description'] ?? '',
                    style: const TextStyle(color: Colors.white70)),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
