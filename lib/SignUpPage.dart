import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackpro/homepage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionHelper {
  static final _key = encrypt.Key.fromUtf8('16charsecretkey!'); // 16 chars
  static final _iv = encrypt.IV.fromLength(16);

  static String encryptData(String plainText) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final encrypted = encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  static String decryptData(String encryptedText) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    return encrypter.decrypt64(encryptedText, iv: _iv);
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void registerUser() async {
    try {
      // 1. Create user in Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // 2. Encrypt data before saving to Firestore
      final encryptedName =
          EncryptionHelper.encryptData(nameController.text.trim());
      final encryptedEmail =
          EncryptionHelper.encryptData(emailController.text.trim());

      // 3. Save encrypted details to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': encryptedName,
        'email': encryptedEmail,
        'createdAt': DateTime.now(),
      });

      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account Created Successfully")),
      );
 
      // Navigate to home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Signup Failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF0D1B2A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                  child: Icon(Icons.person_add, size: 30, color: Colors.white),
                ),
                const SizedBox(height: 20),
                _buildTextField(Icons.person, "Full Name",
                    controller: nameController),
                const SizedBox(height: 10),
                _buildTextField(Icons.email, "Email ID",
                    controller: emailController),
                const SizedBox(height: 10),
                _buildTextField(Icons.lock, "Password",
                    isPassword: true, controller: passwordController),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 183, 140),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("SIGN UP",
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text("Already have an acc? Login",
                      style: TextStyle(color: Colors.white70)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(IconData icon, String hint,
      {bool isPassword = false, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
