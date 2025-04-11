import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
    appBar: AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () => Navigator.pushNamed(context, '/dash')
  ),
  title: const Text(
    "Profile",
    style: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.greenAccent,
      shadows: [
        Shadow(color: Colors.greenAccent, blurRadius: 15),
      ],
    ),
  ),
),

      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxContentWidth = constraints.maxWidth > 800 ? 800 : constraints.maxWidth;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildStatsRow(),
                    const SizedBox(height: 20),
                    _buildSkills(),
                    const SizedBox(height: 20),
                    _buildCurrentlyLearning(),
                    const SizedBox(height: 20),
                    _buildRecentActivity(),
                    const SizedBox(height: 20),
                    _buildAchievements(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _glowText(String text, {double fontSize = 18, FontWeight weight = FontWeight.bold}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: weight,
        color: Colors.greenAccent,
        shadows: [Shadow(color: Colors.greenAccent, blurRadius: 20)],
      ),
    );
  }

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           const CircleAvatar(
  radius: 40,
  backgroundColor: Colors.white,
  child: Icon(
    Icons.person, // outlined person icon
    size: 70,
    color: Colors.black,
  ),
),

            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _glowText("Chris"),
                  const Text("chris@example.com", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 1,
                    children: const [
                      Chip(label: Text("Student")),
                      Chip(label: Text("3rd Year", style: TextStyle(color: Colors.white))),
                      Chip(label: Text("Computer Science")),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Passionate programmer focused on full-stack development and competitive programming.",
                    style: TextStyle(color: Colors.white70),
                  )
                ],
              ),
            )
          ],
        );
      },
    );
  }

 Widget _buildStatsRow() {
  return LayoutBuilder(
    builder: (context, constraints) {
      double cardWidth = constraints.maxWidth > 500
          ? 150
          : (constraints.maxWidth - 48) / 2; // spacing logic

      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _statBox("12", "Projects📘", cardWidth),
          _statBox("87", "Stars⭐", cardWidth),
          _statBox("23", "Forks🔀", cardWidth),
          _statBox("452", "Contribute🤝", cardWidth),
        ],
      );
    },
  );
}


  Widget _statBox(String count, String label, double width) {
  return Container(
    width: width,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFF1E293B),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _glowText(count, fontSize: 22),
        Text(label, style: const TextStyle(color: Color.fromARGB(207, 255, 255, 255))),
      ],
    ),
  );
}


  Widget _buildSkills() {
    return _sectionCard(
      title: "Skills",
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: const [
          Chip(label: Text("JavaScript")),
          Chip(label: Text("React")),
          Chip(label: Text("Python")),
          Chip(label: Text("Java")),
          Chip(label: Text("Data Structures")),
          Chip(label: Text("Algorithms")),
        ],
      ),
    );
  }

  Widget _buildCurrentlyLearning() {
    return _sectionCard(
      title: "Currently Learning",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _learningProgress("System Design", "Designing Data-Intensive Applications", 0.75),
          const SizedBox(height: 16),
          _learningProgress("Machine Learning", "Stanford CS229", 0.40),
        ],
      ),
    );
  }

  Widget _learningProgress(String title, String subtitle, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white10,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return _sectionCard(
      title: "Recent Activity",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _activityItem("⭐", "Starred AI Project Generator", "2024-03-15"),
          _activityItem("🔀", "Forked Data Structures Visualizer", "2024-03-14"),
          _activityItem("📘", "Created Portfolio Website", "2024-03-10"),
        ],
      ),
    );
  }

  Widget _activityItem(String emoji, String title, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: const TextStyle(color: Colors.white))),
          Text(date, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    return _sectionCard(
      title: "Achievements",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _achievement("emoji_events", "5⭐ on CodeChef (2024)", Colors.amber),
          _achievement("military_tech", "Specialist on Codeforces (2023)", Colors.white),
          _achievement("bolt", "200+ Problems on LeetCode", Colors.purpleAccent),
        ],
      ),
    );
  }

  Widget _achievement(String icon, String text, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(_getIconData(icon), color: iconColor),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'emoji_events':
        return Icons.emoji_events;
      case 'military_tech':
        return Icons.military_tech;
      case 'bolt':
        return Icons.bolt;
      default:
        return Icons.star;
    }
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _glowText(title, fontSize: 20),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
