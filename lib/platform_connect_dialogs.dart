import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// LinkedIn Connection Dialog
class LinkedInConnectDialog extends StatefulWidget {
  const LinkedInConnectDialog({Key? key}) : super(key: key);

  @override
  _LinkedInConnectDialogState createState() => _LinkedInConnectDialogState();
}

class _LinkedInConnectDialogState extends State<LinkedInConnectDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _profileUrlController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final profileUrl = _profileUrlController.text.trim();
    final email = _emailController.text.trim();

    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('connected_platforms')
            .doc('linkedin')
            .set({
          'profile_url': profileUrl,
          'email': email,
          'connected_at': FieldValue.serverTimestamp(),
        });

        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _error = "Connection failed: ${e.toString()}");
    } finally {
      setState(() => _loading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Connect LinkedIn', style: TextStyle(fontSize: 20)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _profileUrlController,
              decoration: const InputDecoration(
                labelText: 'Profile URL:',
                
              ),
              validator: (val) => val!.isEmpty ? 'Enter profile URL' : null,
            ),
            
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!, style: TextStyle(color: Colors.red)),
              )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(width: 8, height: 14, child: CircularProgressIndicator(strokeWidth: 16))
              : const Text('Connect'),
        ),
      ],
    );
  }
}

// LeetCode Connection Dialog
class LeetCodeConnectDialog extends StatefulWidget {
  const LeetCodeConnectDialog({Key? key}) : super(key: key);

  @override
  _LeetCodeConnectDialogState createState() => _LeetCodeConnectDialogState();
}

class _LeetCodeConnectDialogState extends State<LeetCodeConnectDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();

  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final username = _usernameController.text.trim();

    try {
      final response = await http.get(
        Uri.parse("https://leetcode-stats-api.herokuapp.com/$username"),
      );

      if (response.statusCode != 200) {
        throw Exception("LeetCode user not found");
      }

      final data = json.decode(response.body);
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        await FirebaseFirestore.instance
    .collection('users')
    .doc(currentUser.uid)
    .collection('connected_platforms')
    .doc('leetcode')
    .set({
  'username': username,
  'streak': data['streak'] ?? 0,
  'total_problems_solved': data['totalSolved'] ?? 0,
  'easy_solved': data['easySolved'] ?? 0,
  'medium_solved': data['mediumSolved'] ?? 0,
  'hard_solved': data['hardSolved'] ?? 0,
  'ranking': data['ranking'] ?? 'N/A',
  'connected_at': FieldValue.serverTimestamp(),
});

        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _error = "Failed to connect: ${e.toString()}");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Connect LeetCode', style: TextStyle(fontSize: 20)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'LeetCode Username:'),
              validator: (val) => val!.isEmpty ? 'Enter username' : null,
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!, style: TextStyle(color: Colors.red)),
              )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(width: 8, height: 14, child: CircularProgressIndicator(strokeWidth: 16))
              : const Text('Connect'),
        ),
      ],
    );
  }
}

// GFG Connection Dialog
class GFGConnectDialog extends StatefulWidget {
  const GFGConnectDialog({Key? key}) : super(key: key);

  @override
  _GFGConnectDialogState createState() => _GFGConnectDialogState();
}

class _GFGConnectDialogState extends State<GFGConnectDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();

    try {
      final response = await http.get(
        Uri.parse("https://geeks-for-geeks-api.vercel.app/$username"),
      );

      if (response.statusCode != 200) {
        throw Exception("GFG user not found");
      }

      final data = json.decode(response.body);
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('connected_platforms')
            .doc('gfg')
            .set({
          'username': username,
          'email': email,
          'institute_rank': data['institute_rank'] ?? 'N/A',
          'total_score': data['overall_coding_score'] ?? 0,
          'problems_solved': data['problems_solved'] ?? 0,
          'monthly_coding_score': data['monthly_coding_score'] ?? 0,
          'connected_at': FieldValue.serverTimestamp(),
        });

        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _error = "Failed to connect: ${e.toString()}");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Connect GFG', style: TextStyle(fontSize: 20)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'GFG Username:'),
              validator: (val) => val!.isEmpty ? 'Enter username' : null,
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email:'),
              validator: (val) => val!.isEmpty ? 'Enter email' : null,
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!, style: TextStyle(color: Colors.red)),
              )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(width: 8, height: 14, child: CircularProgressIndicator(strokeWidth: 16))
              : const Text('Connect'),
        ),
      ],
    );
  }
}