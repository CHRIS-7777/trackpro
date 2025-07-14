import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trackpro/platform_connect_dialogs.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;//http server
import 'dart:convert';
//packages

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
//dash board function
class _DashboardPageState extends State<DashboardPage> {
  int githubProjectCount = 0;
  Map<String, dynamic> platformData = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPlatformData();
  }

  Future<void> _loadPlatformData() async {
    setState(() => isLoading = true);
    await fetchGitHubRepoCountFromFirestore();
    await _fetchAllPlatformData();
    setState(() => isLoading = false);
  }
//fetching github
  Future<void> fetchGitHubRepoCountFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('connected_platforms')
          .doc('github');

      final snapshot = await docRef.get();
      if (snapshot.exists) {
        final data = snapshot.data();
        setState(() {
          githubProjectCount = data?['public_repos'] ?? 0;
        });
      }
    }
  }

  Future<void> _fetchAllPlatformData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('connected_platforms')
          .get();

      setState(() {
        platformData = {
          for (var doc in snapshot.docs) doc.id: doc.data()
        };
      });
    }
  }

  Future<void> _refreshAllPlatforms() async {
    setState(() => isLoading = true);
    
    try {
      // Refresh GitHub data
      if (platformData['github'] != null) {
        await _refreshGitHubData(platformData['github']['username']);
      }
      
      // Refresh LeetCode data
      if (platformData['leetcode'] != null) {
        await _refreshLeetCodeData(platformData['leetcode']['username']);
      }
      
      // Refresh GFG data
      if (platformData['gfg'] != null) {
        await _refreshGFGData(platformData['gfg']['username']);
      }
      
      // Reload all data
      await _loadPlatformData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Platform data refreshed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error refreshing: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _refreshGitHubData(String username) async {
    try {
      final response = await http.get(
        Uri.parse("https://api.github.com/users/$username"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('connected_platforms')
              .doc('github')
              .update({
            'public_repos': data['public_repos'],
            'updated_at': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      throw Exception("Failed to refresh GitHub data");
    }
  }

  Future<void> _refreshLeetCodeData(String username) async {
    try {
      final response = await http.get(
        Uri.parse("https://leetcode-stats-api.herokuapp.com/$username"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('connected_platforms')
              .doc('leetcode')
              .update({
            'total_solved': data['totalSolved'],
            'easy_solved': data['easySolved'],
            'medium_solved': data['mediumSolved'],
            'hard_solved': data['hardSolved'],
            'acceptance_rate': data['acceptanceRate'],
            'ranking': data['ranking'],
            'streak': data['streak'],
            'updated_at': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      throw Exception("Failed to refresh LeetCode data");
    }
  }

  Future<void> _refreshGFGData(String username) async {
    try {
      final response = await http.get(
        Uri.parse("https://geeks-for-geeks-api.vercel.app/$username"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('connected_platforms')
              .doc('gfg')
              .update({
            'institute_rank': data['institute_rank'],
            'total_score': data['overall_coding_score'],
            'problems_solved': data['problems_solved'],
            'monthly_coding_score': data['monthly_coding_score'],
            'updated_at': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      throw Exception("Failed to refresh GFG data");
    }
  }

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
              leading: const Icon(Icons.article),
              title: const Text("Profile"),
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Tracker"),
              onTap: () => Navigator.pushNamed(context, '/track'),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text("Platform stats"),
              onTap: () => Navigator.pushNamed(context, '/stats'),
            ),
            ListTile(
              leading: const Icon(Icons.create),
              title: const Text("Create Resume"),
              onTap: () => Navigator.pushNamed(context, '/create-resume'),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () => Navigator.pushNamed(context, '/login'),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("DASHBOARD", 
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 30),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.greenAccent))
          : DashboardContent(
              githubRepoCount: githubProjectCount,
              platformData: platformData,
              onRefresh: _refreshAllPlatforms,
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.white60,
        onTap: (index) {
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
    );
  }
}

class DashboardContent extends StatelessWidget {
  final int githubRepoCount;
  final Map<String, dynamic> platformData;
  final VoidCallback onRefresh;

  const DashboardContent({
    super.key,
    required this.githubRepoCount,
    required this.platformData,
    required this.onRefresh,
  });

  String _getPlatformStatus(String platform) {
    return platformData.containsKey(platform) ? "Connected" : "Connect";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Color.fromARGB(255, 0, 0, 0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "TrackPro",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                  shadows: [Shadow(color: Colors.greenAccent, blurRadius: 15)],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Connected Platforms",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.greenAccent),
                  onPressed: onRefresh,
                  tooltip: 'Refresh platform data',
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
                  "GitHub", 
                  _getPlatformStatus('github'), 
                  "assets/github.png", 
                  platformData['github']?['username'] ?? '',
                  () {
                    showDialog(context: context, builder: (_) => const GitHubConnectDialog());
                  }
                ),
                _buildPlatformCard(
                  "LinkedIn", 
                  _getPlatformStatus('linkedin'), 
                  "assets/linkedin.png", 
                  platformData['linkedin']?['username'] ?? '',
                  () {
                    showDialog(context: context, builder: (_) => const LinkedInConnectDialog());
                  }
                ),
                _buildPlatformCard(
                  "GeeksforGeeks", 
                  _getPlatformStatus('gfg'), 
                  "assets/gfg.png", 
                  platformData['gfg']?['username'] ?? '',
                  () {
                    showDialog(context: context, builder: (_) => const GFGConnectDialog());
                  }
                ),
                _buildPlatformCard(
                  "LeetCode", 
                  _getPlatformStatus('leetcode'), 
                  "assets/leetcode.png", 
                  platformData['leetcode']?['username'] ?? '',
                  () {
                    showDialog(context: context, builder: (_) => const LeetCodeConnectDialog());
                  }
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildStatsCard("Total Resumes", "0", "Create your first resume"),
            const SizedBox(height: 10),
            _buildStatsCard("Projects", "$githubRepoCount", "Projects saved in your profile"),
            const SizedBox(height: 20),
            const Text(
              "Weekly Activity",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: LineChart(LineChartData(
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        return Text(days[value.toInt()], style: const TextStyle(color: Colors.white70, fontSize: 12));
                      },
                      interval: 1,
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
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
              )),
            ),
            const SizedBox(height: 24),
            const Text(
              "Explore More",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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

  Widget _buildPlatformCard(String title, String subtitle, String imagePath, String username, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: const Color.fromARGB(32, 255, 255, 255),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 50, width: 50),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
            Text(subtitle, style: TextStyle(
              color: subtitle == "Connected" ? Colors.greenAccent : Colors.white60,
              fontSize: 12,
            )),
            if (username.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  username,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
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


