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

  final Map<String, Map<String, dynamic>> _platforms = {
  'github': {
    'asset': 'assets/github.png',
    'color': Colors.white,
  },
  'leetcode': {
    'asset': 'assets/leetcode.png',
    'color': Colors.amber,
  },
  'gfg': {
    'asset': 'assets/gfg.png',
    'color': Colors.green,
  },
  'linkedin': {
    'asset': 'assets/linkedin.png',
    'color': Colors.blue,
  },
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
        // Default to first available platform
        if (_platformData.isNotEmpty) {
          _selectedPlatform = _platformData.keys.first;
        }
      });
    }
  }

  Widget _buildPlatformStats() {
    if (!_platformData.containsKey(_selectedPlatform)) {
      return Center(
        child: Text(
          'No data available for ${_selectedPlatform.capitalize()}',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    final data = _platformData[_selectedPlatform];
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 400;
        
        return Column(
          children: [
            _buildUserHeader(data['username'] ?? 'N/A'),
            const SizedBox(height: 20),
            
            // Responsive stats grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isSmallScreen ? 2 : 3,
              childAspectRatio: isSmallScreen ? 1.2 : 1.5,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: _buildStatCards(data),
            ),
            
            const SizedBox(height: 20),
            if (_selectedPlatform == 'leetcode') 
              _buildLeetCodeProgress(data),
          ],
        );
      },
    );
  }

  List<Widget> _buildStatCards(Map<String, dynamic> data) {
    switch (_selectedPlatform) {
      case 'leetcode':
        return [
          _buildResponsiveStatCard('Problems Solved', '${data['total_problems_solved'] ?? 0}'),
          _buildResponsiveStatCard('Acceptance Rate', '${data['acceptance_rate'] ?? '0'}%'),
          _buildResponsiveStatCard('Global Rank', '#${data['ranking'] ?? 'N/A'}'),
          _buildResponsiveStatCard('Followers', '${data['followers'] ?? 0}'),
        ];
      case 'github':
        return [
          _buildResponsiveStatCard('Public Repos', '${data['public_repos'] ?? 0}'),
          _buildResponsiveStatCard('Followers', '${data['followers'] ?? 0}'),
          _buildResponsiveStatCard('Following', '${data['following'] ?? 0}'),
          _buildResponsiveStatCard('Followers', '${data['followers'] ?? 0}'),
        ];
      case 'gfg':
        return [
          _buildResponsiveStatCard('Problems Solved', '${data['problems_solved'] ?? 0}'),
          _buildResponsiveStatCard('Total Score', '${data['total_score'] ?? 0}'),
          _buildResponsiveStatCard('Institute Rank', '#${data['institute_rank'] ?? 'N/A'}'),
          _buildResponsiveStatCard('Followers', '${data['followers'] ?? 0}'),
        ];
      case 'linkedin':
        return [
          _buildResponsiveStatCard('Connections', '${data['connections'] ?? 'N/A'}'),
          _buildResponsiveStatCard('Profile Views', '${data['profile_views'] ?? 'N/A'}'),
          _buildActionButton('View Profile', () => _launchURL(data['profile_url'])),
          _buildResponsiveStatCard('Followers', '${data['followers'] ?? 0}'),
        ];
      default:
        return [];
    }
  }

  Widget _buildResponsiveStatCard(String title, String value) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return Card(
       color: Colors.grey[900],
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeetCodeProgress(Map<String, dynamic> data) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
            const SizedBox(height: 16),
            _buildProgressRow('Easy', data['easy_solved'] ?? 0, 873, Colors.green),
            _buildProgressRow('Medium', data['medium_solved'] ?? 0, 1835, Colors.orange),
            _buildProgressRow('Hard', data['hard_solved'] ?? 0, 827, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRow(String label, int solved, int total, Color color) {
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
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: solved / total,
            backgroundColor: Colors.grey[800],
            color: color,
            minHeight: 6,
          ),
        ],
      ),
    );
  }

Widget _buildUserHeader(String username) {
  final data = _platformData[_selectedPlatform] ?? {};
  final avatarUrl = data['avatar_url'];

  return Column(
    children: [
      CircleAvatar(
        radius: 40,
        backgroundColor: Colors.grey[800],
        backgroundImage: _selectedPlatform == 'github' && avatarUrl != null
            ? NetworkImage(avatarUrl)
            : AssetImage('assets/$_selectedPlatform.png') as ImageProvider,
      ),
      const SizedBox(height: 12),
      Text(
        '@${username.trim()}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 4),
      Text(
        _selectedPlatform.capitalize(),
        style: TextStyle(
          color: _platforms[_selectedPlatform]?['color'] ?? Colors.greenAccent,
          fontSize: 16,
        ),
      ),
    ],
  );
}

  Widget _buildPlatformSelector() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _platforms.length,
        itemBuilder: (context, index) {
          final platform = _platforms.keys.elementAt(index);
          final isSelected = _selectedPlatform == platform;
          final isConnected = _platformData.containsKey(platform);
          final platformInfo = _platforms[platform]!;

          return GestureDetector(
            onTap: isConnected
                ? () => setState(() => _selectedPlatform = platform)
                : null,
            child: Opacity(
              opacity: isConnected ? 1.0 : 0.5,
              child: Container(
                width: 70,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                 color: platformInfo['color'].withOpacity(isSelected ? 0.3 : 0.15),

                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: platformInfo['color'].withOpacity(isSelected ? 0.3 : 0.15),

                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
  padding: const EdgeInsets.only(top: 12),
  child: Image.asset(
    platformInfo['asset'],
    width: 32,
    height: 32,
    
  ),
),

                    const SizedBox(height: 5),
                    Text(
                      platform.capitalize(),
                      style: TextStyle(
                        color: isSelected 
                            ? platformInfo['color'] 
                            : Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _launchURL(String url) async {
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _buildPlatformSelector(),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: _buildPlatformStats(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}