import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void _launchURL(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  } else {
    throw 'Could not launch $url';
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    DashboardContent(),
    Placeholder(color: Colors.transparent),
    Placeholder(color: Colors.transparent),
    Placeholder(color: Colors.transparent),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.black),
              child: Text("TrackPro",
                  style: TextStyle(color: Colors.white, fontSize: 24)),
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
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF0D1B2A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
       child: BottomNavigationBar(
  currentIndex: _currentIndex,
  backgroundColor: Colors.transparent,
  elevation: 0,
  selectedItemColor: Colors.greenAccent,
  unselectedItemColor: Colors.white,
  showUnselectedLabels: false,
  type: BottomNavigationBarType.fixed,
  onTap: (index) {
    setState(() {
      _currentIndex = index;
    });
    final routes = ['/projects', '/suggest', '/add', '/explore', '/resume'];
    if (index < routes.length) {
      Navigator.pushNamed(context, routes[index]);
    }
  },
  items: const [
    BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Projects'),
    BottomNavigationBarItem(icon: Icon(Icons.recommend), label: 'Suggest'),
    BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
    BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
    BottomNavigationBarItem(icon: Icon(Icons.document_scanner), label: 'Resume'),
  ],
),

      ),
    );
  }
}

class DashboardContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Center(
                  child: Text(
                    "TRACKPRO",
                    style: TextStyle(
                      fontSize: 40,
                      color: Color.fromARGB(255, 30, 253, 18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    "Connected Platforms",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildPlatformCard(
                    "GitHub", "Connect", "assets/github.png", () => _launchURL("https://github.com")),
                _buildPlatformCard(
                    "LinkedIn", "Connect ", "assets/linkedin.png", () => _launchURL("https://linkedin.com")),
                _buildPlatformCard(
                    "Credly", "Connect ", "assets/credly.png", () => _launchURL("https://credly.com")),
                _buildPlatformCard(
                    "LeetCode", "Connect", "assets/leetcode.png", () => _launchURL("https://leetcode.com")),
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
    );
  }

  static Widget _buildPlatformCard(
      String title, String desc, String imageAssetPath, VoidCallback onTap) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Card(
            color: const Color(0xFF0F172A),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      desc,
                      style: const TextStyle(color: Colors.white70),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Image.asset(
                      imageAssetPath,
                      height: constraints.maxWidth * 0.25,
                      width: constraints.maxWidth * 0.25,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildStatsCard(
      String title, String count, String subtitle) {
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
