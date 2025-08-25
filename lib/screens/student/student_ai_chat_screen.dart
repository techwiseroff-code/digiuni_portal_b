import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../utils/styles.dart';
import '../../widgets/glass_container.dart';

const String apiKey = "AIzaSyAaTgCsbmO8K1YeyAPY9IOWcd7jFV7-Vbc";
const String model = "gemini-2.5-flash";

class StudentAIChatScreen extends StatefulWidget {
  const StudentAIChatScreen({super.key});

  @override
  State<StudentAIChatScreen> createState() => _StudentAIChatScreenState();
}

class _StudentAIChatScreenState extends State<StudentAIChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> messages = [];
  bool _isTyping = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );
    _fadeController.forward();

    // Add initial AI message
    messages.add({
      "role": "assistant",
      "text": "Hello! I'm your AI assistant. How can I help you today?",
      "timestamp": "10:30 AM",
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Response copied to clipboard!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add({
        "role": "user",
        "text": text,
        "timestamp": _getCurrentTime(),
      });
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse(
          "https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey",
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": text},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply =
            data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"] ??
            "I'm sorry, I couldn't process your request. Please try again.";

        setState(() {
          messages.add({
            "role": "assistant",
            "text": reply,
            "timestamp": _getCurrentTime(),
          });
          _isTyping = false;
        });
      } else {
        setState(() {
          messages.add({
            "role": "assistant",
            "text":
                "I'm sorry, there was an error processing your request. Please try again.",
            "timestamp": _getCurrentTime(),
          });
          _isTyping = false;
        });
      }
    } catch (e) {
      setState(() {
        messages.add({
          "role": "assistant",
          "text":
              "I'm sorry, there was a connection error. Please check your internet connection and try again.",
          "timestamp": _getCurrentTime(),
        });
        _isTyping = false;
      });
    }

    _controller.clear();
    _scrollToBottom();
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
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
    return Container(
      decoration: BoxDecoration(gradient: Styles.backgroundGradientFromImage),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Top Bar with Notification
                _buildTopBar(),

                // Chat Header
                _buildChatHeader(),

                // Chat Messages
                Expanded(child: _buildChatMessages()),

                // Suggested Actions
                _buildSuggestedActions(),

                // Input Field
                _buildInputField(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black.withOpacity(0.3), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          const Spacer(),
          // Title
          const Text(
            'Student Portal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildChatHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // AI Assistant Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withOpacity(0.8),
                  Colors.blue.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Title and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Study Assistant',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your personal academic helper',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessages() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && _isTyping) {
          return _buildTypingIndicator();
        }

        final message = messages[index];
        final isUser = message["role"] == "user";

        return _buildMessageBubble(message, isUser);
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isUser) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUser
                  ? Colors.blue.withOpacity(0.8)
                  : Colors.purple.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomLeft: isUser
                    ? const Radius.circular(20)
                    : const Radius.circular(5),
                bottomRight: isUser
                    ? const Radius.circular(5)
                    : const Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message["text"],
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                if (!isUser) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => _copyToClipboard(message["text"]),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.copy,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(
              left: isUser ? 0 : 16,
              right: isUser ? 16 : 0,
            ),
            child: Text(
              message["timestamp"] ?? "",
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.8),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [_buildDot(0), _buildDot(1), _buildDot(2)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildSuggestedActions() {
    final actions = [
      {'text': 'Help with assignment', 'icon': Icons.assignment},
      {'text': 'Study schedule', 'icon': Icons.schedule},
      {'text': 'Exam preparation', 'icon': Icons.school},
      {'text': 'Subject resources', 'icon': Icons.book},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildActionButton(actions[0])),
              const SizedBox(width: 8),
              Expanded(child: _buildActionButton(actions[1])),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildActionButton(actions[2])),
              const SizedBox(width: 8),
              Expanded(child: _buildActionButton(actions[3])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(Map<String, dynamic> action) {
    return GestureDetector(
      onTap: () => sendMessage(action['text']),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        borderRadius: 12,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action['icon'], color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                action['text'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: GlassContainer(
              borderRadius: 20,
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "Ask me anything about your studies...",
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 16,
                  ),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: sendMessage,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => sendMessage(_controller.text),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
