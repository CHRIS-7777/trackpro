import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ==================== COMMON DIALOG THEME ====================

class PlatformDialogTheme {
  static AlertDialog buildDialog({
    required BuildContext context,
    required String title,
    required Widget content,
    required List<Widget> actions,
    bool loading = false,
  }) {
    return AlertDialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.greenAccent, width: 2),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          color: Colors.greenAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: content,
      actions: actions,
    );
  }

  static Widget buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color.fromARGB(255, 203, 203, 203)),
          filled: true,
          fillColor: Colors.black,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.greenAccent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.greenAccent, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
        ),
        validator: isRequired
            ? (val) => val!.isEmpty ? 'Enter $label' : null
            : null,
      ),
    );
  }

  static List<Widget> buildDialogActions({
    required BuildContext context,
    required VoidCallback onSubmit,
    bool loading = false,
  }) {
    return [
      TextButton(
        onPressed: loading ? null : () => Navigator.pop(context),
        child: const Text('Cancel', style: TextStyle(color: Colors.greenAccent)),
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.greenAccent,
          foregroundColor: Colors.black,
        ),
        onPressed: loading ? null : onSubmit,
        child: loading
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : const Text('Connect'),
      ),
    ];
  }
}

// ==================== LINKEDIN DIALOG ====================

// ==================== UPDATED LINKEDIN DIALOG ====================

class LinkedInConnectDialog extends StatefulWidget {
  const LinkedInConnectDialog({Key? key}) : super(key: key);

  @override
  _LinkedInConnectDialogState createState() => _LinkedInConnectDialogState();
}

class _LinkedInConnectDialogState extends State<LinkedInConnectDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _profileUrlController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final profileUrl = _profileUrlController.text.trim();
    final username = _usernameController.text.trim();
    
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('connected_platforms')
            .doc('linkedin')
            .set({
          'username': username,  // Added username field
          'profile_url': profileUrl,
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
    return PlatformDialogTheme.buildDialog(
      context: context,
      title: 'Connect LinkedIn',
      loading: _loading,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PlatformDialogTheme.buildTextField(
              controller: _usernameController,
              label: 'LinkedIn Username',
            ),
            PlatformDialogTheme.buildTextField(
              controller: _profileUrlController,
              label: 'LinkedIn Profile URL',
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
          ],
        ),
      ),
      actions: PlatformDialogTheme.buildDialogActions(
        context: context,
        onSubmit: _submit,
        loading: _loading,
      ),
    );
  }
}
// ==================== LEETCODE DIALOG ====================

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
    setState(() => _loading = true);

    final username = _usernameController.text.trim();
    try {
      final response = await http.get(
          Uri.parse("https://leetcode-stats-api.herokuapp.com/$username"));
      if (response.statusCode != 200) throw Exception("LeetCode user not found");

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
    return PlatformDialogTheme.buildDialog(
      context: context,
      title: 'Connect LeetCode',
      loading: _loading,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PlatformDialogTheme.buildTextField(
              controller: _usernameController,
              label: 'LeetCode Username',
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
          ],
        ),
      ),
      actions: PlatformDialogTheme.buildDialogActions(
        context: context,
        onSubmit: _submit,
        loading: _loading,
      ),
    );
  }
}

// ==================== GFG DIALOG ====================

class GFGConnectDialog extends StatefulWidget {
  const GFGConnectDialog({Key? key}) : super(key: key);

  @override
  _GFGConnectDialogState createState() => _GFGConnectDialogState();
}

class _GFGConnectDialogState extends State<GFGConnectDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final username = _usernameController.text.trim();

    try {
      final response = await http.get(
          Uri.parse("https://geeks-for-geeks-api.vercel.app/$username"));
      if (response.statusCode != 200) throw Exception("GFG user not found");

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
    return PlatformDialogTheme.buildDialog(
      context: context,
      title: 'Connect GeeksforGeeks',
      loading: _loading,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PlatformDialogTheme.buildTextField(
              controller: _usernameController,
              label: 'GFG Username',
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
          ],
        ),
      ),
      actions: PlatformDialogTheme.buildDialogActions(
        context: context,
        onSubmit: _submit,
        loading: _loading,
      ),
    );
  }
}

// ==================== GITHUB DIALOG ====================

class GitHubConnectDialog extends StatefulWidget {
  const GitHubConnectDialog({Key? key}) : super(key: key);

  @override
  _GitHubConnectDialogState createState() => _GitHubConnectDialogState();
}

class _GitHubConnectDialogState extends State<GitHubConnectDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

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
    final phone = _phoneController.text.trim();

    try {
      final response = await http
          .get(Uri.parse("https://api.github.com/users/$username"));
      if (response.statusCode != 200) throw Exception("GitHub user not found");

      final data = json.decode(response.body);
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('connected_platforms')
            .doc('github')
            .set({
          'username': username,
          'name': data['name'],
          'avatar_url': data['avatar_url'],
          'public_repos': data['public_repos'],
          'followers': data['followers'],
          'following': data['following'],
          'email': email,
          'phone': phone,
          'fetched_at': FieldValue.serverTimestamp(),
        });

        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformDialogTheme.buildDialog(
      context: context,
      title: 'Connect GitHub',
      loading: _loading,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PlatformDialogTheme.buildTextField(
              controller: _usernameController,
              label: 'GitHub Username',
            ),
            PlatformDialogTheme.buildTextField(
              controller: _emailController,
              label: 'Email',
            ),
            PlatformDialogTheme.buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              isRequired: false,
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
          ],
        ),
      ),
      actions: PlatformDialogTheme.buildDialogActions(
        context: context,
        onSubmit: _submit,
        loading: _loading,
      ),
    );
  }
}