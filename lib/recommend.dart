import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecommendPage extends StatefulWidget {
  const RecommendPage({Key? key}) : super(key: key);

  @override
  State<RecommendPage> createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> allProjects = [];
  List<Map<String, dynamic>> filteredProjects = [];
  String searchQuery = "";
  bool isLoading = true;
  String? error;

  final List<Map<String, dynamic>> sampleProjects = [
    {
      'title': 'AI Chatbot',
      'description': 'A Flutter-based chatbot using Dialogflow.',
      'author': 'Billu Dev',
      'stars': 89,
      'forks': 12,
      'tags': ['AI', 'Flutter', 'Dialogflow']
    },
    {
      'title': 'Expense Tracker',
      'description': 'Track your daily expenses with graphs.',
      'author': 'Priya K.',
      'stars': 150,
      'forks': 25,
      'tags': ['Finance', 'Track', ]
    },
    {
      'title': 'Online Code Editor',
      'description': 'A browser-based editor with C++, Python support.',
      'author': 'Ajay Kumar',
      'stars': 200,
      'forks': 47,
      'tags': ['Editor', 'C++', 'Python']
    },
     {
      'title': 'Network Model',
      'description': 'A Convolutional Neuarl Network Model for Image Classification',
      'author': 'Christopher',
      'stars': 197,
      'forks': 37,
      'tags': ['Editor', 'C++', 'Python','ML']
    },
      {
      'title': 'Network Model',
      'description': 'A Convolutional Neuarl Network Model for Image Classification',
      'author': 'Christopher',
      'stars': 197,
      'forks': 37,
      'tags': ['Editor', 'C++', 'Python','ML']
    },
  ];

  void _onTabTapped(int index) {
    setState(() {
    });

    final routes = ['/projects', '/explore', '/add', '/suggest', '/resume'];
    if (index < routes.length) {
      Navigator.pushNamed(context, routes[index]);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    try {
      final snapshot = await _firestore.collection('saved_projects').get();
      final data = snapshot.docs.map((doc) => doc.data()).toList();

      setState(() {
        allProjects = List<Map<String, dynamic>>.from(data);
        if (allProjects.isEmpty) {
          print("⚠️ Firestore empty, loading sample projects");
          allProjects = sampleProjects;
        }
        filteredProjects = allProjects;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching projects: $e");
      setState(() {
        error = "Error loading projects. Showing sample data.";
        allProjects = sampleProjects;
        filteredProjects = sampleProjects;
        isLoading = false;
      });
    }
  }

  void filterProjects(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredProjects = allProjects.where((project) {
        final title = project['title'].toString().toLowerCase();
        final description = project['description'].toString().toLowerCase();
        final tags = project['tags'].join(' ').toLowerCase();
        final author = project['author'].toString().toLowerCase();
        return title.contains(searchQuery) ||
               description.contains(searchQuery) ||
               tags.contains(searchQuery) ||
               author.contains(searchQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
         leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.greenAccent),
          onPressed: () => Navigator.pushNamed(context, '/dash'),
        ),
        backgroundColor: Colors.black,
        title: Text(
          '🌍 Community',
          style: TextStyle(
            color: Colors.greenAccent,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.greenAccent))
          : Column(
              children: [
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      error!,
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search Projects...',
                      hintStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 0, 0, 0),
                      prefixIcon: Icon(Icons.search, color: Colors.white),
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
           
                    ),
                    onChanged: filterProjects,
                  ),
                ),
               Expanded(
                  child: filteredProjects.isEmpty
                      ? Center(
                          child: Text(
                            'No projects found.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredProjects.length,
                          itemBuilder: (context, index) {
                            final project = filteredProjects[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Card(
                                color: Colors.grey[900],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _bodyText(project['title'] ?? '', isLink: true),
                                      SizedBox(height: 8),
                                      _body(project['description'] ?? ''),
                                      SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          _body1("👤 ${project['author'] ?? ''}"),
                                          Row(
                                            children: [
                                              _iconWithText(Icons.star, project['stars'].toString()),
                                              SizedBox(width: 16),
                                              _iconWithText(Icons.share, project['forks'].toString()),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: (project['tags'] ?? [])
                                            .map<Widget>((tag) => Chip(
                                                  label: Text(tag),
                                                  labelStyle: TextStyle(color: Colors.greenAccent),
                                                  backgroundColor: Colors.greenAccent.withOpacity(0.3),
                                                ))
                                            .toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                )
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
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

  Widget _bodyText(String text, {bool isLink = false}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isLink ? Colors.greenAccent : Colors.white,
        decoration: TextDecoration.none,
      ),
    );
  }
  
  Widget _body(String text, {bool isLink = false}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: isLink ? Colors.greenAccent : Colors.white,
        decoration: TextDecoration.none,
      ),
    );
  }
  
  Widget _body1(String text, {bool isLink = false}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: isLink ? Colors.greenAccent : Colors.white,
        decoration: TextDecoration.none,
      ),
    );
  }

  Widget _iconWithText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.white),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}