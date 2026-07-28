enum ChatSender { user, ai }

class ChatMessageDummy {
  final String id;
  final String text;
  final ChatSender sender;
  final DateTime timestamp;

  const ChatMessageDummy({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
  });
}

class ChatSessionDummy {
  final String id;
  final String title;
  final DateTime lastUpdated;

  const ChatSessionDummy({
    required this.id,
    required this.title,
    required this.lastUpdated,
  });
}

class DummyChatRepository {
  static List<ChatSessionDummy> getChatHistory() {
    final now = DateTime.now();
    return [
      ChatSessionDummy(id: "s1", title: "Doubt on Rotational Motion", lastUpdated: now.subtract(const Duration(hours: 2))),
      ChatSessionDummy(id: "s2", title: "Organic Chemistry reactions", lastUpdated: now.subtract(const Duration(days: 1))),
      ChatSessionDummy(id: "s3", title: "Integration by parts help", lastUpdated: now.subtract(const Duration(days: 2))),
      ChatSessionDummy(id: "s4", title: "NEET Biology — Photosynthesis", lastUpdated: now.subtract(const Duration(days: 4))),
    ];
  }

  static List<String> getSuggestedPrompts() {
    return const [
      "Explain Newton's Second Law",
      "Solve this integration problem",
      "Difference between speed and velocity",
      "Summarize Photosynthesis in simple terms",
    ];
  }

  static List<ChatMessageDummy> getInitialConversation() {
    final now = DateTime.now();
    return [
      ChatMessageDummy(
        id: "m1",
        text: "Hi! I'm your AI Mentor. Ask me any doubt from your syllabus and I'll help you understand it step by step.",
        sender: ChatSender.ai,
        timestamp: now.subtract(const Duration(minutes: 5)),
      ),
    ];
  }
}
