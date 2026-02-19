import 'package:flutter/material.dart';
import '../models/session_result.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

// Stateless Q&A bot — no database, no storage.
// All messages live only in this widget's state.
// Everything is gone when the screen is closed.

class QAScreen extends StatefulWidget {
  final SessionResult result;
  const QAScreen({super.key, required this.result});

  @override
  State<QAScreen> createState() => _QAScreenState();
}

class _QAScreenState extends State<QAScreen> {
  final TextEditingController _ctrl   = TextEditingController();
  final ScrollController       _scroll = ScrollController();

  // In-memory only — cleared when screen closes
  final List<_Message> _messages = [];
  bool _isLoading = false;

  // Suggested quick questions
  static const _suggestions = [
    'What does my AHI score mean?',
    'Is my SpO2 level dangerous?',
    'What is RMSSD and is mine normal?',
    'Should I see a doctor?',
    'What causes sleep apnea?',
    'How can I improve my results?',
  ];

  @override
  void initState() {
    super.initState();
    // Welcome message
    _messages.add(_Message(
      text: 'Hello! I\'ve reviewed your sleep session results. '
            'Ask me anything about your screening — I\'m here to help explain your data.\n\n'
            '⚠️ I\'m an AI assistant, not a doctor. Always consult a sleep specialist for diagnosis.',
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _sendQuestion(String question) async {
    if (question.trim().isEmpty) return;

    setState(() {
      _messages.add(_Message(text: question, isUser: true));
      _isLoading = true;
    });
    _ctrl.clear();
    _scrollToBottom();

    try {
      final answer = await ApiService.ask(question, widget.result);
      setState(() {
        _messages.add(_Message(text: answer, isUser: false));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(_Message(
          text: 'Sorry, I couldn\'t get a response. The AI model might be loading — '
                'please wait 20 seconds and try again.',
          isUser: false,
          isError: true,
        ));
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
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
        title: const Text('AI Sleep Assistant'),
        actions: [
          // Clear button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Clear chat',
            onPressed: () => setState(() {
              _messages.clear();
              _messages.add(_Message(
                text: 'Chat cleared. Ask me anything about your sleep results!',
                isUser: false,
              ));
            }),
          ),
        ],
      ),
      body: Column(
        children: [

          // Session summary bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppTheme.primary.withOpacity(0.08),
            child: Text(
              'Session: ${widget.result.totalDuration}  ·  '
              'Risk: ${widget.result.riskLevel}  ·  '
              'AHI: ${widget.result.ahiEstimate}/hr',
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w500,
                  color: AppTheme.primary),
              textAlign: TextAlign.center,
            ),
          ),

          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, i) {
                if (_isLoading && i == _messages.length) {
                  return const _TypingIndicator();
                }
                return _MessageBubble(message: _messages[i]);
              },
            ),
          ),

          // Suggestions (shown only when no user message yet)
          if (_messages.length == 1)
            SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                scrollDirection: Axis.horizontal,
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) => ActionChip(
                  label: Text(_suggestions[i],
                      style: const TextStyle(fontSize: 11)),
                  onPressed: _isLoading
                      ? null
                      : () => _sendQuestion(_suggestions[i]),
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                  labelStyle: const TextStyle(color: AppTheme.primary),
                  side: const BorderSide(color: AppTheme.primary, width: 0.8),
                ),
              ),
            ),

          const SizedBox(height: 8),

          // Input bar
          Container(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06),
                    blurRadius: 8, offset: const Offset(0, -2)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    enabled: !_isLoading,
                    onSubmitted: _sendQuestion,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      hintText: 'Ask about your results...',
                      hintStyle: const TextStyle(fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide:
                            const BorderSide(color: AppTheme.primary, width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor:
                      _isLoading ? Colors.grey.shade300 : AppTheme.primary,
                  child: IconButton(
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.send_rounded,
                            color: Colors.white, size: 18),
                    onPressed: _isLoading
                        ? null
                        : () => _sendQuestion(_ctrl.text),
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

class _Message {
  final String text;
  final bool isUser;
  final bool isError;
  _Message({required this.text, required this.isUser, this.isError = false});
}

class _MessageBubble extends StatelessWidget {
  final _Message message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: message.isError
              ? Colors.red.shade50
              : message.isUser
                  ? AppTheme.primary
                  : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft:     const Radius.circular(16),
            topRight:    const Radius.circular(16),
            bottomLeft:  Radius.circular(message.isUser ? 16 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06),
                blurRadius: 4, offset: const Offset(0, 1)),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            fontSize: 13.5,
            color: message.isError
                ? Colors.red.shade700
                : message.isUser
                    ? Colors.white
                    : AppTheme.textPrimary,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06),
                blurRadius: 4, offset: const Offset(0, 1)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppTheme.primary),
            ),
            const SizedBox(width: 8),
            Text('AI is thinking...',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecond)),
          ],
        ),
      ),
    );
  }
}
