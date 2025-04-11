import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// ✅ This function is now outside the class so it works properly in web
void _launchURL(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  } else {
    throw 'Could not launch $url';
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.black),
              child: const Text(
                "TrackPro",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text("Dashboard"),
              onTap: () => Navigator.pushNamed(context, '/dashboard'),
            ),
            ListTile(
              leading: Icon(Icons.article),
              title: Text("Resumes"),
              onTap: () => Navigator.pushNamed(context, '/resumes'),
            ),
            ListTile(
              leading: Icon(Icons.create),
              title: Text("Create Resume"),
              onTap: () => Navigator.pushNamed(context, '/create-resume'),
            ),
            ListTile(
              leading: Icon(Icons.folder),
              title: Text("Projects"),
              onTap: () => Navigator.pushNamed(context, '/projects'),
            ),
            ListTile(
              leading: Icon(Icons.explore),
              title: Text("Explore"),
              onTap: () => Navigator.pushNamed(context, '/explore'),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Colors.black,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF0D1B2A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Hey Chris🖐..",
                  style: TextStyle(fontSize: 20, color: Colors.white)),
              const SizedBox(height: 24),
              const Text("Connected Platforms",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildPlatformCard(
                      "GitHub",
                      "Connect your GitHub",
                      "assets/github.png",
                      () => _launchURL("https://github.com")),
                  _buildPlatformCard(
                      "LinkedIn",
                      "Connect your LinkedIn",
                      "assets/linkedin.png",
                      () => _launchURL("https://linkedin.com")),
                  _buildPlatformCard(
                      "Credly",
                      "Connect your Credly",
                      "assets/credly.png",
                      () => _launchURL("https://credly.com")),
                  _buildPlatformCard(
                      "LeetCode",
                      "Connect your LeetCode",
                      "assets/leetcode.png",
                      () => _launchURL("https://leetcode.com")),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                      child: _buildStatsCard(
                          "Total Resumes", "0", "Create your first resume")),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildStatsCard(
                          "Projects", "2", "Projects saved in your profile")),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildPlatformCard(
      String title, String desc, String imageAssetPath, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        color: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(desc, style: const TextStyle(color: Colors.white70)),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: Image.asset(
                  imageAssetPath,
                  height: 50,
                  width: 50,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildStatsCard(String title, String count, String subtitle) {
    return Card(
      color: const Color(0xFF0F172A),
      child: SizedBox(
        height: 180,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(count,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}
