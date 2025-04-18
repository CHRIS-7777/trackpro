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

  int _currentIndex = 2;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    final routes = ['/projects', '/explore', '/add', '/suggest', '/resume'];
    if (index < routes.length) {
      Navigator.pushNamed(context, routes[index]);
    }
  }

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
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        elevation: 0,
        title: const Text(
          "🚀 Create New Project",
          style: TextStyle(
            color: Colors.greenAccent,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.greenAccent),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushNamed(context, '/dash'),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black,
              Color(0xFF001F3F), // Dark Blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField("Project Title", titleController),
            const SizedBox(height: 16),
            Expanded(
              child: _buildTextField("Project Description", descriptionController, isBig: true),
            ),
            const SizedBox(height: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: ElevatedButton.icon(
                onPressed: _saveProject,
                icon: const Icon(Icons.save),
                label: const Text("Save"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color.fromARGB(255, 10, 15, 25),
        elevation: 0,
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.white70,
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

  Widget _buildTextField(String label, TextEditingController controller, {bool isBig = false}) {
    return TextField(
      controller: controller,
      maxLines: isBig ? null : 1,
      expands: isBig,
      textAlignVertical: isBig ? TextAlignVertical.top : TextAlignVertical.center,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color.fromARGB(255, 149, 154, 152)),
        filled: true,
        fillColor: const Color.fromARGB(255, 0, 0, 0),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color.fromARGB(255, 249, 249, 249),width:1),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color.fromARGB(255, 255, 255, 255), width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
