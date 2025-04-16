import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateProjectPage extends StatefulWidget {
  const CreateProjectPage({Key? key}) : super(key: key);

  @override
  State<CreateProjectPage> createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  void _saveProject() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty || user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    final project = {
      'title': title,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('my_projects')
        .add(project);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Project saved successfully")),
    );

    Navigator.pop(context); // Go back to ProjectsPage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Create New Project", style: TextStyle(color: Colors.greenAccent)),
        iconTheme: const IconThemeData(color: Colors.greenAccent),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Project Title",
                labelStyle: TextStyle(color: Colors.greenAccent),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: descriptionController,
                maxLines: null,
                expands: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Project Description",
                  labelStyle: TextStyle(color: Colors.greenAccent),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _saveProject,
              icon: const Icon(Icons.save),
              label: const Text("Save"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
