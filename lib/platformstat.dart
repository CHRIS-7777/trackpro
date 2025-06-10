import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class PlatformStatsPage extends StatefulWidget {
  const PlatformStatsPage({Key? key}) : super(key: key);

  @override
  _PlatformStatsPageState createState() => _PlatformStatsPageState();
}

class _PlatformStatsPageState extends State<PlatformStatsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedPlatform = 'github';
  Map<String, dynamic> _platformData = {};

  final Map<String, String> _platformIcons = {
    'github': 'assets/github.png',
    'leetcode': 'assets/leetcode.png',
    'gfg': 'assets/gfg.png',
    'linkedin': 'assets/linkedin.png',
  };

  @override
  void initState() {
    super.initState();
    _loadPlatformData();
  }

  Future<void> _loadPlatformData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('connected_platforms')
          .get();

      setState(() {
        _platformData = {
          for (var doc in snapshot.docs) doc.id: doc.data()
        };
      });
    }
  }

  Widget _buildPlatformStats() {
    if (!_platformData.containsKey(_selectedPlatform)) {
      return Center(
        child: Text(
          'No data available for ${_selectedPlatform.capitalize()}',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    final data = _platformData[_selectedPlatform];
    
    switch (_selectedPlatform) {
      case 'leetcode':
        return _buildLeetCodeStats(data);
      case 'github':
        return _buildGitHubStats(data);
      case 'gfg':
        return _buildGFGStats(data);
      case 'linkedin':
        return _buildLinkedInStats(data);
      default:
        return Container();
    }
  }

  Widget _buildLeetCodeStats(Map<String, dynamic> data) {
    return Column(
      children: [
        _buildUserHeader(data['username'] ?? 'N/A'),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatCard('Problems Solved', '${data['total_problems_solved'] ?? 0}'),
            _buildStatCard('Acceptance Rate', '${data['acceptance_rate'] ?? '0'}%'),
            _buildStatCard('Global Ranking', '#${data['ranking'] ?? 'N/A'}'),
          ],
        ),
        const SizedBox(height: 30),
        _buildProgressSection(
          easy: data['easy_solved'] ?? 0,
          medium: data['medium_solved'] ?? 0,
          hard: data['hard_solved'] ?? 0,
        ),
      ],
    );
  }

  Widget _buildGitHubStats(Map<String, dynamic> data) {
    return Column(
      children: [
        _buildUserHeader(data['username'] ?? 'N/A'),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatCard('Public Repos', '${data['public_repos'] ?? 0}'),
            _buildStatCard('Followers', '${data['followers'] ?? 0}'),
            _buildStatCard('Following', '${data['following'] ?? 0}'),
          ],
        ),
        const SizedBox(height: 30),
        // Add GitHub specific visualizations here
      ],
    );
  }

  Widget _buildGFGStats(Map<String, dynamic> data) {
    return Column(
      children: [
        _buildUserHeader(data['username'] ?? 'N/A'),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatCard('Problems Solved', '${data['problems_solved'] ?? 0}'),
            _buildStatCard('Total Score', '${data['total_score'] ?? 0}'),
            _buildStatCard('Institute Rank', '#${data['institute_rank'] ?? 'N/A'}'),
          ],
        ),
        const SizedBox(height: 30),
        // Add GFG specific visualizations here
      ],
    );
  }

  Widget _buildLinkedInStats(Map<String, dynamic> data) {
    return Column(
      children: [
        _buildUserHeader(data['username'] ?? 'N/A'),
        const SizedBox(height: 20),
        // Add LinkedIn specific stats here
        ElevatedButton(
          onPressed: () => _launchURL(data['profile_url']),
          child: const Text('View Profile'),
        ),
      ],
    );
  }

  Widget _buildUserHeader(String username) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: _platformData[_selectedPlatform]?['avatar_url'] != null
              ? NetworkImage(_platformData[_selectedPlatform]!['avatar_url'])
              : null,
          child: _platformData[_selectedPlatform]?['avatar_url'] == null
              ? Icon(Icons.person, size: 40)
              : null,
        ),
        const SizedBox(height: 10),
        Text(
          '@$username',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          _selectedPlatform.capitalize(),
          style: TextStyle(
            color: Colors.greenAccent,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.greenAccent,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection({required int easy, required int medium, required int hard}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Problem Solving Progress',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        _buildProgressItem('Easy', easy, 873, Colors.green),
        _buildProgressItem('Medium', medium, 1835, Colors.orange),
        _buildProgressItem('Hard', hard, 827, Colors.red),
      ],
    );
  }

  Widget _buildProgressItem(String label, int solved, int total, Color color) {
    final percentage = (solved / total * 100).toStringAsFixed(1);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$solved/$total ($percentage%)',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 5),
          LinearProgressIndicator(
            value: solved / total,
            backgroundColor: Colors.grey[800],
            color: color,
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformSelector() {
    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _platformIcons.entries.map((entry) {
          final platform = entry.key;
          final icon = entry.value;
          final isSelected = _selectedPlatform == platform;

          return GestureDetector(
            onTap: () {
              if (_platformData.containsKey(platform)) {
                setState(() => _selectedPlatform = platform);
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.greenAccent.withOpacity(0.2) : Colors.grey[800],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? Colors.greenAccent : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    icon,
                    width: 30,
                    height: 30,
                    color: isSelected ? Colors.greenAccent : Colors.white70,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    platform.capitalize(),
                    style: TextStyle(
                      color: isSelected ? Colors.greenAccent : Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Platform Statistics'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPlatformSelector(),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: _buildPlatformStats(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}