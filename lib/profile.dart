import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.greenAccent),
        backgroundColor: const Color.fromARGB(255, 12, 14, 37),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/dash'),
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
               // Dark Blue
              Colors.black,
               Color(0xFF001F3F),
            ],
          ),
        ),
        child: LayoutBuilder(
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
                      const SizedBox(height: 16),
                      _glowText("Platforms", fontSize: 20),
                      const SizedBox(height: 10),
                      _buildPlatformRow(),
                      const SizedBox(height: 20),
                      _buildStatsRow(),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white,
          child: Icon(
            Icons.person,
            size: 70,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _glowText("CHRIS", fontSize: 25),
              const Text("chris@example.com", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 1,
                children: const [
                  Chip(label: Text("Student", style: TextStyle(color: Colors.white))),
                  Chip(label: Text("3rd Year", style: TextStyle(color: Colors.white))),
                  Chip(label: Text("Computer Science", style: TextStyle(color: Colors.white))),
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
  }

  Widget _buildPlatformRow() {
    final List<Map<String, String>> platforms = [
      {'icon': 'assets/leetcode.png', 'url': 'https://leetcode.com/'},
      {'icon': 'assets/hacker.png', 'url': 'https://www.hackerrank.com/'},
      {'icon': 'assets/gfg.png', 'url': 'https://www.geeksforgeeks.org/'},
      {'icon': 'assets/linkedin.png', 'url': 'https://www.linkedin.com/'},
      {'icon': 'assets/github.png', 'url': 'https://github.com/'},
    ];

    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 20,
      runSpacing: 16,
      children: platforms.map((platform) {
        return GestureDetector(
          onTap: () async {
            final url = Uri.parse(platform['url']!);
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
          child: Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(platform['icon']!, fit: BoxFit.contain),
          ),
        );
      }).toList(),
    );
  }

  Widget _platformIcon(String assetPath, String url) {
    return InkWell(
      onTap: () => launchUrl(Uri.parse(url)),
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 15,
        backgroundImage: AssetImage(assetPath),
      ),
    );
  }

  Widget _buildStatsRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double cardWidth = constraints.maxWidth > 500
            ? 150
            : (constraints.maxWidth - 48) / 2;

        return Wrap(
          spacing: 40,
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
