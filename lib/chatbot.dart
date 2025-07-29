import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class EducationChatbotScreen extends StatefulWidget {
  const EducationChatbotScreen({super.key});

  @override
  State<EducationChatbotScreen> createState() => _EducationChatbotScreenState();
}

class _EducationChatbotScreenState extends State<EducationChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeChatbot();
  }

  Future<void> _initializeChatbot() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('chat_sessions').doc(user.uid).set({
        'createdAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
        'context': 'general',
      }, SetOptions(merge: true));
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    final message = _messageController.text;
    _messageController.clear();

    // Add user message to UI immediately
    setState(() {
      _messages.add({
        'text': message,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
    });
    _scrollToBottom();

    // Save message to Firestore
    await _firestore.collection('chat_sessions')
      .doc(user.uid)
      .collection('messages')
      .add({
        'text': message,
        'isUser': true,
        'timestamp': FieldValue.serverTimestamp(),
      });

    // Get bot response using the globally initialized Gemini instance
    final response = await _generateResponse(message);
    
    // Add bot response to UI
    setState(() {
      _messages.add({
        'text': response,
        'isUser': false,
        'timestamp': DateTime.now(),
      });
      _isLoading = false;
    });
    _scrollToBottom();

    // Save bot response to Firestore
    await _firestore.collection('chat_sessions')
      .doc(user.uid)
      .collection('messages')
      .add({
        'text': response,
        'isUser': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
  }

  Future<String> _generateResponse(String message) async {
    try {
      // Using the globally initialized Gemini instance
      final response = await Gemini.instance.text(
        """
        You are an AI educational assistant. Only answer questions related to:
        - Science (Physics, Chemistry, Biology)
        - Mathematics
        - Programming and Computer Science
        - Engineering concepts
        - Academic research
        
        If the question is not educational, politely respond:
        "I specialize in academic topics. Please ask about science, math, or technology."
        
        Current question: $message
        """
      );

      debugPrint('Gemini response: ${response?.content?.parts?.join(' ')}');

      // Handle the response
      if (response != null && response.content != null) {
        return response.content!.parts?.join(' ') ?? 
               "I couldn't generate a response. Please try again.";
      }
      return "I didn't understand that. Could you rephrase your question?";
    } catch (e) {
      debugPrint('Error with Gemini API: $e');
      return "I'm having trouble connecting to the knowledge base. Please try again later.";
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Education Assistant'),
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B2A), Colors.black],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return ChatMessage(
                    text: message['text'],
                    isUser: message['isUser'],
                  );
                },
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ask about any educational topic...',
                hintStyle: const TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFF00B78C),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF00B78C)
                    : Colors.grey.shade800,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft:
                      Radius.circular(isUser ? 12 : 0),
                  bottomRight:
                      Radius.circular(isUser ? 0 : 12),
                ),
              ),
              child: Text(
                text,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}