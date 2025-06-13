import 'package:flutter/material.dart';
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
          '🚀 ${title.replaceAll('**', '')} Roadmap', // Remove double asterisks
          style: const TextStyle(
            color: Colors.greenAccent,
            fontSize: 20, // Slightly smaller for better fit
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(constraints.maxWidth * 0.04), // Responsive padding
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
          fontSize: constraints.maxWidth * 0.04, // Responsive font size
        ),
      ),
    );
  }

  Widget _buildPrerequisitesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Plan',
          style: TextStyle(
            color: Colors.greenAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        for (int weekNumber = 1; weekNumber <= 10; weekNumber++)
          _buildWeekContainer(weekNumber),
      ],
    );
  }

  Widget _buildWeekContainer(int weekNumber) {
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
      'Final Project and Advanced Concepts'
    ];

    final weekResources = [
      [
        {'name': 'React - The Complete Guide', 'url': 'https://example.com/react-complete-guide', 'type': 'course'},
        {'name': 'React Official Documentation', 'url': 'https://reactjs.org/docs', 'type': 'documentation'},
      ],
      [
        {'name': 'Modern React with Redux', 'url': 'https://example.com/modern-react', 'type': 'course'},
        {'name': 'React Component API', 'url': 'https://reactjs.org/docs/react-component.html', 'type': 'documentation'},
      ],
      [
        {'name': 'React for Beginners', 'url': 'https://example.com/react-beginners', 'type': 'course'},
        {'name': 'React State and Lifecycle', 'url': 'https://reactjs.org/docs/state-and-lifecycle.html', 'type': 'documentation'},
      ],
    ];

    final weekProjects = [
      'Simple Counter App: Build a counter app with increment and decrement buttons.',
      'Simple To-Do List: Create a to-do list app with add, delete, and toggle functionalities.',
      'Simple Calculator: Build a basic calculator app with button inputs and display.',
      'Product List with Filtering: Create a product list with a search filter.',
      'Simple User Registration Form: Build a form to collect user data.',
      'Multi-Page Application: Create a simple multi-page app using React Router.',
      'E-commerce Product Cart: Build a shopping cart with global state.',
      'Refactor previous project with testing: Implement unit tests.',
      'Portfolio Website: Build a portfolio showcasing your skills.',
      'Personal Project: Choose a project of personal interest.',
    ];

    final weekMilestones = [
      [
        'Understand JSX syntax',
        'Create a basic React component',
        'Render data to the DOM',
      ],
      [
        'Create reusable components',
        'Pass data between components using props',
        'Handle events in components',
      ],
      [
        'Manage component state effectively',
        'Understand component lifecycle methods',
        'Use useState and useEffect hooks',
      ],
    ];

    final safeWeekIndex = weekNumber - 1;
    final hasResources = weekResources.length > safeWeekIndex;
    final hasMilestones = weekMilestones.length > safeWeekIndex;

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
            'Week $weekNumber: ${weekTitles[safeWeekIndex]}',
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Resources Section
          const Text(
            'Resources',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (hasResources)
            ...weekResources[safeWeekIndex].map((resource) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Text('• ', style: TextStyle(color: Colors.white70)),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _launchUrl(resource['url']!),
                      child: Text(
                        '${resource['name']} (${resource['type']})',
                        style: const TextStyle(
                          color: Colors.lightBlue,
                          decoration: TextDecoration.underline,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          const SizedBox(height: 8),
          
          // PDF Download Button
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
          const SizedBox(height: 12),
          
          // Projects Section
          const Text(
            'Projects',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            weekProjects[safeWeekIndex].replaceAll('**', ''), // Remove double asterisks
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          
          // Milestones Section
          const Text(
            'Milestones',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (hasMilestones)
            ...weekMilestones[safeWeekIndex].map((milestone) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• ${milestone.replaceAll('**', '')}', // Remove double asterisks
                style: const TextStyle(color: Colors.white70),
              ),
            )),
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
              ...advancedTopics.map((topic) => _buildBulletPoint(topic)),
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
        '• ${text.replaceAll('**', '')}', // Remove double asterisks
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}