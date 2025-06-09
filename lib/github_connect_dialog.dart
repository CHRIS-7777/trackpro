import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      final response = await http.get(Uri.parse("https://api.github.com/users/$username"));
      if (response.statusCode != 200) {
        throw Exception("GitHub user not found");
      }

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


        Navigator.pop(context); // Close dialog
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Connect GitHub',style:TextStyle(fontSize:20)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username:'),
              validator: (val) => val!.isEmpty ? 'Enter username' : null,
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email:'),
              validator: (val) => val!.isEmpty ? 'Enter email' : null,
            ),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number:'),
              validator: (val) => val!.isEmpty ? 'Enter phone number' : null,
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
