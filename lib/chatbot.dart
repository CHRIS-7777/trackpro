import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class LearningAssistantPage extends StatefulWidget {
  const LearningAssistantPage({super.key});

  @override
  State<LearningAssistantPage> createState() => _LearningAssistantPageState();
}

class _LearningAssistantPageState extends State<LearningAssistantPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;

  // Predefined responses
  static const Map<String, String> predefinedResponses = {
    'thank': 'You\'re welcome! Is there anything else I can help you with?',
    'hello': 'Hello! How can I assist you with your learning today?',
    'hi': 'Hi there! What would you like to learn about?',
    'help': 'I can help with:\n- Explaining concepts\n- Suggesting resources\n- Answering questions\nWhat do you need?',
  };

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _messages.add(ChatMessage(
      text: 'Welcome to your Learning Assistant! How can I help you today?',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  void _handlePredefinedMessage(String text) {
    final lowerText = text.toLowerCase();
    for (var entry in predefinedResponses.entries) {
      if (lowerText.contains(entry.key)) {
        _addBotMessage(entry.value);
        return;
      }
    }
    _sendToGemini(text);
  }

  void _addBotMessage(String text) {
    // Remove markdown formatting and limit response length
    final cleanText = text
        .replaceAll('**', '')
        .replaceAll('*', '')
        .replaceAll('#', '')
        .replaceAll('```', '');
    
    final shortenedText = cleanText.length > 300 
        ? '${cleanText.substring(0, 300)}...' 
        : cleanText;

    setState(() {
      _messages.add(ChatMessage(
        text: shortenedText,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _isTyping = false;
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  Future<void> _sendToGemini(String prompt) async {
    setState(() => _isTyping = true);
    
    try {
      // Request concise responses from Gemini
      final result = await Gemini.instance.text(
        "Provide a concise response to: $prompt. "
        "Keep it under 300 characters and avoid markdown formatting."
      );
      _addBotMessage(result?.output ?? "I couldn't generate a response. Please try again.");
    } catch (e) {
      _addBotMessage("Sorry, I encountered an error. Please try again later.");
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scrollController = PrimaryScrollController.of(context);
      scrollController?.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Learning Assistant', 
          style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.greenAccent),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF111111),
                    Color(0xFF000000),
                  ],
                ),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return ChatBubble(
                    message: message,
                    isLoading: _isTyping && index == _messages.length - 1 && !message.isUser,
                  );
                },
              ),
            ),
          ),
          if (_isLoading)
            const LinearProgressIndicator(
              color: Colors.greenAccent,
              backgroundColor: Colors.black,
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                border: Border(
                  top: BorderSide(
                    color: Colors.grey[800]!,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Type your question...",
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send, color: Colors.greenAccent),
                          onPressed: () {
                            final text = _messageController.text.trim();
                            if (text.isNotEmpty) {
                              _addUserMessage(text);
                              _handlePredefinedMessage(text);
                              _messageController.clear();
                            }
                          },
                        ),
                      ),
                      onSubmitted: (text) {
                        if (text.trim().isNotEmpty) {
                          _addUserMessage(text);
                          _handlePredefinedMessage(text);
                          _messageController.clear();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isLoading;

  const ChatBubble({
    super.key,
    required this.message,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser)
            CircleAvatar(
              backgroundColor: Colors.grey[900],
              child: const Icon(Icons.school, color: Colors.greenAccent),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? Colors.greenAccent.withOpacity(0.9)
                    : Colors.grey[800],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(message.isUser ? 18 : 0),
                  bottomRight: Radius.circular(message.isUser ? 0 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),), 
                ],
              ),
              child: isLoading
                  ? const TypingIndicator()
                  : Text(
                      message.text,
                      style: TextStyle(
                        color: message.isUser ? Colors.black : Colors.white,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 8),
          if (message.isUser)
            CircleAvatar(
              backgroundColor: Colors.grey[900],
              child: const Icon(Icons.person, color: Colors.greenAccent),
            ),
        ],
      ),
    );
  }
}

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildDot(0),
          _buildDot(1),
          _buildDot(2),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        color: Colors.greenAccent,
        shape: BoxShape.circle,
      ),
      margin: const EdgeInsets.all(2),
    );
  }
}