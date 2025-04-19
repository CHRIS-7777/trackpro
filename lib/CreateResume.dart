import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ResumeGeneratorPage extends StatefulWidget {
  const ResumeGeneratorPage({super.key});

  @override
  State<ResumeGeneratorPage> createState() => _ResumeGeneratorPageState();
}

class _ResumeGeneratorPageState extends State<ResumeGeneratorPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();

  List<Map<String, dynamic>> _projects = [];
  bool _isLoading = false;
  bool _isGenerating = false;
  final user = FirebaseAuth.instance.currentUser;

  int _currentIndex = 4;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    if (user == null) return;

    setState(() => _isLoading = true);

    final projectsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('saved_projects')
        .get();

    setState(() {
      _projects = projectsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'title': data['title'] ?? 'Untitled Project',
          'description': data['description'] ?? 'No description',
        };
      }).toList();
      _isLoading = false;
    });
  }

  Future<void> _generateResume() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isGenerating = true);

    try {
      final response = await Gemini.instance.text(
        "Generate a professional resume summary for ${_nameController.text} "
        "with skills: ${_skillsController.text}. Keep it concise and impactful (max 8 sentences).",
      );

      final summary = response?.output ?? _summaryController.text;

      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(level: 0, text: _nameController.text),
                pw.Text(_emailController.text),
                pw.Text(_phoneController.text),
                pw.SizedBox(height: 20),
                pw.Header(level: 1, text: 'Professional Summary'),
                pw.Text(summary),
                pw.SizedBox(height: 20),
                pw.Header(level: 1, text: 'Skills'),
                pw.Text(_skillsController.text.replaceAll(',', ', ')),
                pw.SizedBox(height: 20),
                pw.Header(level: 1, text: 'Experience'),
                pw.Text(_experienceController.text),
                pw.SizedBox(height: 20),
                pw.Header(level: 1, text: 'Education'),
                pw.Text(_educationController.text),
                pw.SizedBox(height: 20),
                pw.Header(level: 1, text: 'Projects (${_projects.length})'),
                ..._projects.map((project) => pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(project['title'], style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(project['description']),
                        pw.SizedBox(height: 10),
                      ],
                    )),
              ],
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/resume.pdf');
      await file.writeAsBytes(await pdf.save());

      await Printing.layoutPdf(onLayout: (format) => pdf.save());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating resume: $e')),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);

    final routes = ['/projects', '/explore', '/add', '/suggest', '/resume'];
    if (index != 4 && index < routes.length) {
      Navigator.pushNamed(context, routes[index]);
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.greenAccent,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label, IconData icon,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        validator: (value) => value!.isEmpty ? 'Required field' : null,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color.fromARGB(255, 255, 255, 255)),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.black.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.greenAccent),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.greenAccent),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.greenAccent),
          onPressed: () => Navigator.pushNamed(context, '/dash'),
        ),
        title: const Text('Resume Builder', style: TextStyle(color: Colors.greenAccent)),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _generateResume,
            tooltip: 'Generate PDF',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildSectionHeader('Personal Information'),
              _buildTextFormField(_nameController, 'Full Name', Icons.person),
              _buildTextFormField(_emailController, 'Email', Icons.email),
              _buildTextFormField(_phoneController, 'Phone', Icons.phone),
              _buildSectionHeader('Professional Summary'),
              _buildTextFormField(_summaryController, 'Brief about yourself', Icons.description, maxLines: 3),
              _buildSectionHeader('Skills (comma separated)'),
              _buildTextFormField(_skillsController, 'Flutter, Firebase, UI/UX', Icons.code),
              _buildSectionHeader('Work Experience'),
              _buildTextFormField(_experienceController, 'Company, Position, Duration', Icons.work, maxLines: 4),
              _buildSectionHeader('Education'),
              _buildTextFormField(_educationController, 'Degree, Institution, Year', Icons.school),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                ),
                icon: _isGenerating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                      )
                    : const Icon(Icons.picture_as_pdf),
                label: const Text('Generate Resume PDF'),
                onPressed: _isGenerating ? null : _generateResume,
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
}
