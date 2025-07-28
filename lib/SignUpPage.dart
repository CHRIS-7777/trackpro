import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _auth = FirebaseAuth.instance;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;
  final String _googleScriptUrl = "https://script.google.com/macros/s/AKfycbyyPczMYQKcs0T5b73eHpzxRHIYOX6Epx-uwx0AVKlF7KbN1-D0rnucdVxmPSf5zy9p2Q/exec";
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Caesar cipher encryption (shift of 5)
  String _caesarEncrypt(String text, {int shift = 5}) {
    String result = '';
    for (int i = 0; i < text.length; i++) {
      int charCode = text.codeUnitAt(i);
      if (charCode >= 65 && charCode <= 90) {
        result += String.fromCharCode((charCode - 65 + shift) % 26 + 65);
      } else if (charCode >= 97 && charCode <= 122) {
        result += String.fromCharCode((charCode - 97 + shift) % 26 + 97);
      } else if (charCode >= 48 && charCode <= 57) {
        result += String.fromCharCode((charCode - 48 + shift) % 10 + 48);
      } else {
        result += text[i];
      }
    }
    return result;
  }

  Future<String> _getUserIP() async {
    try {
      final response = await http.get(Uri.parse('https://api.ipify.org?format=json'));
      return jsonDecode(response.body)['ip'];
    } catch (e) {
      debugPrint('IP Fetch Error: $e');
      return 'unknown';
    }
  }

  Future<Map<String, dynamic>> _checkIP(String ip) async {
    try {
      final response = await http.get(
        Uri.parse('http://ip-api.com/json/$ip?fields=status,message,country,proxy,hosting')
      );
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('IP Check Error: $e');
      return {'status': 'fail', 'message': 'API error'};
    }
  }

  Future<void> _logToGoogleSheets(Map<String, dynamic> data) async {
    final fullData = {
      ...data,
      'log_source': 'Signup Attempt',
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      debugPrint('Attempting Sheets write: ${fullData.toString()}');
      
      final response = await http.post(
        Uri.parse(_googleScriptUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(fullData),
      ).timeout(const Duration(seconds: 15));

      debugPrint('Sheets response: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode != 200) {
        throw Exception('Sheets returned ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Sheets write failed: $e');
      await _logToFirestore({
        ...fullData,
        'error': e.toString(),
      });
    }
  }

  Future<void> _logToFirestore(Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance.collection('security_logs').add({
        'timestamp': FieldValue.serverTimestamp(),
        'email': data['email'],
        'ip': data['ip'],
        'country': data['country'],
        'is_vpn': data['is_vpn'],
        'risk_level': data['risk_level'],
        'log_source': 'Firestore Fallback',
        'error': 'Sheets access denied'
      });
      debugPrint('📝 Firestore fallback successful');
    } catch (e) {
      debugPrint('‼️ Firestore failed too: $e');
    }
  }

  Future<void> _showIPAlert(BuildContext context, String ip, Map<String, dynamic> ipData) async {
    bool isClean = ipData['proxy'] == false && ipData['hosting'] == false;
    
    if (!isClean) {
      await _logToGoogleSheets({
        'email': emailController.text.trim(),
        'ip': ip,
        'country': ipData['country'] ?? 'Unknown',
        'is_vpn': true,
        'risk_level': 'High'
      });
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isClean ? '✅ Clean IP' : '⚠️ Suspicious IP - Logged'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('IP: $ip'),
            Text('Country: ${ipData['country'] ?? 'Unknown'}'),
            if (ipData['proxy'] == true) const Text('Proxy: Detected'),
            if (ipData['hosting'] == true) const Text('Hosting/VPN: Detected'),
            if (!isClean) const Text('\nThis attempt has been logged', 
                style: TextStyle(color: Colors.red)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _registerUser() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Step 1: Get and check IP
      final ip = await _getUserIP();
      final ipData = await _checkIP(ip);
      
      // Step 2: Show IP status popup (logs if suspicious)
      await _showIPAlert(context, ip, ipData);
      
      // Step 3: Block if VPN detected
      if (ipData['proxy'] == true || ipData['hosting'] == true) {
        return; 
      }
      
      // Step 4: Proceed with encrypted registration
      final encryptedName = _caesarEncrypt(nameController.text.trim());
      final encryptedEmail = _caesarEncrypt(emailController.text.trim());
      
      await _auth.createUserWithEmailAndPassword(
        email: encryptedEmail,
        password: passwordController.text.trim(),
      );
      
      await _auth.currentUser?.updateDisplayName(encryptedName);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account Created Successfully")),
      );
      Navigator.pushReplacementNamed(context, '/home');
      
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Signup Failed")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isKeyboardOpen = mediaQuery.viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: mediaQuery.size.height,
            ),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Color(0xFF0D1B2A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isKeyboardOpen) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.white30),
                            ),
                            child: const Text(
                              "Trackpro",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white30,
                            child: Icon(Icons.person_add,
                                size: 30, color: Colors.white),
                          ),
                          const SizedBox(height: 20),
                        ],
                        TextFormField(
                          controller: nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            prefixIcon:
                                const Icon(Icons.person, color: Colors.white70),
                            hintText: "Full Name",
                            hintStyle: const TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: Colors.white10,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: emailController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            prefixIcon:
                                const Icon(Icons.email, color: Colors.white70),
                            hintText: "Email ID",
                            hintStyle: const TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: Colors.white10,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            prefixIcon:
                                const Icon(Icons.lock, color: Colors.white70),
                            hintText: "Password",
                            hintStyle: const TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: Colors.white10,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _registerUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 0, 183, 140),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 60, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  "SIGN UP",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/login'),
                          child: const Text("Already have an acc? Login",
                              style: TextStyle(color: Colors.white70)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}