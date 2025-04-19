import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fl_chart/fl_chart.dart';

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
  int _currentIndex = -1;

  final List<Widget> _pages = [
    DashboardContent(),
    Placeholder(color: Colors.transparent),
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
              child: Text("Menu",
                  style: TextStyle(color: Colors.greenAccent, fontSize: 24)),
            ),
            ListTile(
              leading: Icon(Icons.article),
              title: Text("Profile"),
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text("Dashboard"),
              onTap: () => Navigator.pushNamed(context, '/dash'),
            ),
            ListTile(
              leading: Icon(Icons.create),
              title: Text("Create Resume"),
              onTap: () => Navigator.pushNamed(context, '/create-resume'),
            ),
            ListTile(
              leading: Icon(Icons.article),
              title: Text("Settings"),
              onTap: () => Navigator.pushNamed(context, '/resumes'),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: () => Navigator.pushNamed(context, '/login'),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("DASHBOARD",style:TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.greenAccent)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle,size:30),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          )
        ],
      ),
      body: _pages[_currentIndex == -1 ? 0 : _currentIndex],
      bottomNavigationBar: Container(
 
  child: BottomNavigationBar(
    currentIndex: _currentIndex == -1 ? 0 : _currentIndex,
    backgroundColor: const Color.fromARGB(255, 0, 0, 0),
    elevation: 0,
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.white,
    selectedIconTheme: const IconThemeData(color: Colors.white),
    unselectedIconTheme: const IconThemeData(color: Colors.white),
    selectedLabelStyle: const TextStyle(color: Colors.white),
    unselectedLabelStyle: const TextStyle(color: Colors.white),
    showUnselectedLabels: false,
    type: BottomNavigationBarType.fixed,
    onTap: (index) {
      setState(() {
        _currentIndex = index;
      });
      final routes = ['/projects', '/explore', '/add', '/suggest', '/resume'];
      if (index < routes.length) {
        Navigator.pushNamed(context, routes[index]);
      }
    },
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Projects'),
      BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
      BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
      BottomNavigationBarItem(icon: Icon(Icons.recommend), label: 'Suggest'),
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
                    "TrackPro",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
                      shadows: [
                        Shadow(color: Colors.greenAccent, blurRadius: 15),
                      ],
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
                _buildPlatformCard("GitHub", "Connect", "assets/github.png", () => _launchURL("https://github.com")),
                _buildPlatformCard("LinkedIn", "Connect ", "assets/linkedin.png", () => _launchURL("https://linkedin.com")),
                _buildPlatformCard("Credly", "Connect ", "assets/credly.png", () => _launchURL("https://credly.com")),
                _buildPlatformCard("LeetCode", "Connect", "assets/leetcode.png", () => _launchURL("https://leetcode.com")),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildStatsCard("Total Resumes", "0", "Create your first resume")),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildStatsCard("Projects", "2", "Projects saved in your profile")),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Weekly Activity",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              width: 540,
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          return Text(
                            days[value.toInt()],
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          );
                        },
                        interval: 1,
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      color: Colors.greenAccent,
                      barWidth: 3,
                      belowBarData: BarAreaData(show: true, color: Colors.greenAccent.withOpacity(0.2)),
                      spots: const [
                        FlSpot(0, 2),
                        FlSpot(1, 4),
                        FlSpot(2, 1),
                        FlSpot(3, 5),
                        FlSpot(4, 3),
                        FlSpot(5, 4.5),
                        FlSpot(6, 2),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Explore More",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildFeatureCard("Blogs", "Read latest tech blogs", Icons.article, () => _launchURL("https://medium.com")),
                _buildFeatureCard("Tutorials", "Learn step-by-step", Icons.school, () => _launchURL("https://youtube.com")),
                _buildFeatureCard("Certifications", "Boost your profile", Icons.card_membership, () => _launchURL("https://coursera.org")),
                _buildFeatureCard("Events", "Join tech events", Icons.event, () => _launchURL("https://eventbrite.com")),
                _buildFeatureCard("Tools", "Explore dev tools", Icons.build, () => _launchURL("https://dev.to/tools")),
                _buildFeatureCard("Explore", "Explore the Ideas", Icons.explore, () => _launchURL("https://github.com")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformCard(String title, String subtitle, String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: const Color.fromARGB(32, 255, 255, 255),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 50, width: 50),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
            Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(String title, String value, String description) {
    return Card(
      color: const Color.fromARGB(32, 255, 255, 255),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(color: Colors.greenAccent, fontSize: 32)),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(color: Colors.white60, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
       color: const Color.fromARGB(32, 255, 255, 255),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.greenAccent, size: 50),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
            Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
