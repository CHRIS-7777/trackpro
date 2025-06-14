import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trackpro/RoadmapTrackerPage.dart';
import 'package:url_launcher/url_launcher.dart';

class RoadmapPage extends StatelessWidget {
  final String title;
  final String content;

  RoadmapPage({
    super.key,
    required this.title,
    required this.content,
  });

  final Map<int, String> weekPdfLinks = {
    1: 'https://example.com/react-week1.pdf',
    2: 'https://example.com/react-week2.pdf',
    3: 'https://example.com/react-week3.pdf',
    4: 'https://example.com/react-week4.pdf',
    5: 'https://example.com/react-week5.pdf',
    6: 'https://example.com/react-week6.pdf',
    7: 'https://example.com/react-week7.pdf',
    8: 'https://example.com/react-week8.pdf',
    9: 'https://example.com/react-week9.pdf',
    10: 'https://example.com/react-week10.pdf',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.greenAccent),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '🚀 ${title.replaceAll('**', '')} Roadmap',
          style: const TextStyle(
            color: Colors.greenAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.greenAccent),
            tooltip: 'Add to Tracker',
            onPressed: () => _addToTracker(context),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(constraints.maxWidth * 0.04),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(constraints),
                  const SizedBox(height: 24),
                  _buildPrerequisitesSection(),
                  const SizedBox(height: 24),
                  _buildWeeklyPlanSection(),
                  const SizedBox(height: 24),
                  _buildAdvancedTopicsSection(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _addToTracker(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Please log in first')),
      );
      return;
    }

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tracked_projects');

    try {
      await docRef.add({
        'title': title,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Added to Tracker')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RoadmapTrackerPage(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to add: ${e.toString()}')),
      );
    }
  }

  Widget _buildHeaderSection(BoxConstraints constraints) {
    return Container(
      width: constraints.maxWidth,
      padding: EdgeInsets.all(constraints.maxWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "This roadmap outlines a 10-week plan to achieve an intermediate understanding of ${title.replaceAll('**', '')}. "
        "It emphasizes hands-on practice and focuses on building a solid foundation before exploring advanced concepts.",
        style: TextStyle(
          color: Colors.white70,
          fontSize: constraints.maxWidth * 0.04,
        ),
      ),
    );
  }

  Widget _buildPrerequisitesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prerequisites',
          style: TextStyle(
            color: Colors.greenAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBulletPoint('Basic HTML, CSS, and JavaScript knowledge'),
              _buildBulletPoint('Familiarity with ES6+ features'),
              _buildBulletPoint('Node.js and npm/yarn installed'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyPlanSection() {
    final weekTitles = [
      'Getting started with React fundamentals',
      'Understanding components and props',
      'State management and lifecycle methods',
      'Working with lists and conditional rendering',
      'Forms and handling user input',
      'Introduction to React Router',
      'Introduction to state management (Context API or Redux)',
      'Advanced React Hooks and Testing',
      'Consolidation and Project Refinement',
      'Final Project and Advanced Concepts',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Plan',
          style: TextStyle(
            color: Colors.greenAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        for (int week = 1; week <= 10; week++)
          _buildWeekContainer(week, weekTitles[week - 1]),
      ],
    );
  }

  Widget _buildWeekContainer(int weekNumber, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Week $weekNumber: $title',
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (weekPdfLinks.containsKey(weekNumber))
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _launchUrl(weekPdfLinks[weekNumber]!),
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Download Study Materials'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent.withOpacity(0.2),
                  foregroundColor: Colors.greenAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAdvancedTopicsSection() {
    final advancedTopics = [
      'Advanced Redux techniques',
      'Server-Side Rendering (SSR)',
      'Static Site Generation (SSG)',
      'Testing libraries (Jest, React Testing Library)',
      'Performance Optimization',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Advanced Topics',
          style: TextStyle(
            color: Colors.greenAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...advancedTopics.map(_buildBulletPoint),
              const SizedBox(height: 12),
              const Text(
                'After completing the 10-week roadmap, explore these advanced topics to deepen your expertise.',
                style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '• ${text.replaceAll('**', '')}',
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
