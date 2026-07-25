import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/network/ai_chat_api_service.dart';
import 'models/chat_message_dummy.dart';
import 'widgets/chat_history_drawer.dart';
import 'widgets/chat_input_field.dart';
import 'widgets/message_bubble.dart';
import 'widgets/suggested_prompts.dart';
import 'widgets/typing_indicator_bubble.dart';

class AIMentorTabScreen extends StatefulWidget {
  const AIMentorTabScreen({super.key});

  @override
  State<AIMentorTabScreen> createState() => _AIMentorTabScreenState();
}

class _AIMentorTabScreenState extends State<AIMentorTabScreen> {
  final _api = AIChatApiService();
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  List<ChatMessageDummy> _messages = [];
  List<ChatSessionDummy> _sessions = [];
  String? _currentSessionId;
  bool _isAiTyping = false;
  int _messageCounter = 0;

  @override
  void initState() {
    super.initState();
    _resetToWelcome();
    _loadSessions();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _resetToWelcome() {
    _messages = [
      ChatMessageDummy(
        id: "welcome",
        text:
            "Hi! I'm your AI Mentor. Ask me any doubt from your syllabus and I'll help you understand it step by step.",
        sender: ChatSender.ai,
        timestamp: DateTime.now(),
      ),
    ];
    _currentSessionId = null;
  }

  Future<void> _loadSessions() async {
    try {
      final sessions = await _api.listSessions();
      if (!mounted) return;
      setState(() {
        _sessions = sessions
            .map((s) => ChatSessionDummy(id: s.id, title: s.title, lastUpdated: s.updatedAt))
            .toList();
      });
    } catch (_) {
      // Session history is non-critical — fail silently, drawer just stays empty.
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendMessage([String? presetText]) async {
    final text = (presetText ?? _inputController.text).trim();
    if (text.isEmpty) return;

    setState(() {
      _messageCounter++;
      _messages.add(
        ChatMessageDummy(
          id: "u$_messageCounter",
          text: text,
          sender: ChatSender.user,
          timestamp: DateTime.now(),
        ),
      );
      _inputController.clear();
      _isAiTyping = true;
    });
    _scrollToBottom();

    try {
      final result = await _api.sendMessage(text, sessionId: _currentSessionId);
      if (!mounted) return;
      setState(() {
        _currentSessionId = result.sessionId;
        _messageCounter++;
        _messages.add(
          ChatMessageDummy(
            id: "a$_messageCounter",
            text: result.reply,
            sender: ChatSender.ai,
            timestamp: DateTime.now(),
          ),
        );
        _isAiTyping = false;
      });
      _loadSessions();
    } on DioException catch (e) {
      if (!mounted) return;
      final isProviderDown = e.response?.statusCode == 503;
      setState(() {
        _messageCounter++;
        _messages.add(
          ChatMessageDummy(
            id: "a$_messageCounter",
            text: isProviderDown
                ? "AI service is unavailable right now, please try again in a moment."
                : "Something went wrong. Please try again.",
            sender: ChatSender.ai,
            timestamp: DateTime.now(),
          ),
        );
        _isAiTyping = false;
      });
    } finally {
      _scrollToBottom();
    }
  }

  Future<void> _openSession(ChatSessionDummy session) async {
    Navigator.of(context).pop();
    try {
      final detail = await _api.getSession(session.id);
      if (!mounted) return;
      setState(() {
        _currentSessionId = detail.session.id;
        _messages = detail.messages
            .map((m) => ChatMessageDummy(
                  id: "${m.role}_${m.createdAt.microsecondsSinceEpoch}",
                  text: m.message,
                  sender: m.role == "user" ? ChatSender.user : ChatSender.ai,
                  timestamp: m.createdAt,
                ))
            .toList();
        _isAiTyping = false;
      });
      _scrollToBottom();
    } catch (_) {
      // Keep current view if loading the session fails.
    }
  }

  void _startNewChat() {
    Navigator.of(context).pop();
    setState(() {
      _resetToWelcome();
      _isAiTyping = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final showSuggestedPrompts = _messages.length <= 1 && !_isAiTyping;

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Mentor"),
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: ChatHistoryDrawer(
        sessions: _sessions,
        onNewChat: _startNewChat,
        onSelectSession: _openSession,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  ..._messages.map((m) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: MessageBubble(message: m),
                      )),
                  if (_isAiTyping)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 14),
                      child: TypingIndicatorBubble(),
                    ),
                ],
              ),
            ),
            if (showSuggestedPrompts)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: SuggestedPrompts(
                  prompts: DummyChatRepository.getSuggestedPrompts(),
                  onSelect: (prompt) => _sendMessage(prompt),
                ),
              ),
            ChatInputField(
              controller: _inputController,
              onSend: () => _sendMessage(),
              enabled: !_isAiTyping,
            ),
          ],
        ),
      ),
    );
  }
}
