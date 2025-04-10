import 'package:flutter/material.dart';

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
              decoration: BoxDecoration(color: Colors.black),
              child: Text(
                "TrackPro",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(leading: Icon(Icons.dashboard), title: Text("Dashboard")),
            ListTile(leading: Icon(Icons.article), title: Text("Resumes")),
            ListTile(leading: Icon(Icons.create), title: Text("Create Resume")),
            ListTile(leading: Icon(Icons.folder), title: Text("Projects")),
            ListTile(leading: Icon(Icons.explore), title: Text("Explore")),
            ListTile(leading: Icon(Icons.settings), title: Text("Settings")),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text("Dashboard"),
        backgroundColor: Colors.black,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF0D1B2A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Welcome back, chris!",
                  style: TextStyle(fontSize: 20, color: Colors.white)),
              SizedBox(height: 24),
              Text("Connected Platforms",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              SizedBox(height: 12),
             GridView.count(
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(),
  crossAxisCount: 2,
  crossAxisSpacing: 16,
  mainAxisSpacing: 16,
  children: [
    _buildPlatformCard("GitHub", "Connect your GitHub", "assets/github.png"),
    _buildPlatformCard("LinkedIn", "Connect your LinkedIn", "assets/linkedin.png"),
    _buildPlatformCard("Credly", "Connect your Credly", "assets/credly.png"),
    _buildPlatformCard("LeetCode", "Connect your LeetCode", "assets/leetcode.png"),
  ],
),

              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildStatsCard("Total Resumes", "0", "Create your first resume")),
                  SizedBox(width: 16),
                  Expanded(child: _buildStatsCard("Projects", "2", "Projects saved in your profile")),
                ],
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildPlatformCard(String title, String desc, String imageAssetPath) {
  return Card(
    color: Color(0xFF0F172A),
    child: SizedBox(
      height: 180, // Fixed height for all cards
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(desc, style: TextStyle(color: Colors.white70)),
            Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Image.asset(
                imageAssetPath,
                height: 32,
                width: 32,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


  Widget _buildStatsCard(String title, String count, String subtitle) {
    return Card(
      color: Color(0xFF1E293B),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.white70, fontSize: 14)),
            SizedBox(height: 4),
            Text(count, style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(subtitle, style: TextStyle(color: Colors.white60, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
