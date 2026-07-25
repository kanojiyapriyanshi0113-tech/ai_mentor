import "package:flutter/material.dart";

import "../models/chat_message_dummy.dart";

class ChatHistoryDrawer extends StatelessWidget {
  final List<ChatSessionDummy> sessions;
  final VoidCallback onNewChat;
  final ValueChanged<ChatSessionDummy> onSelectSession;

  const ChatHistoryDrawer({
    super.key,
    required this.sessions,
    required this.onNewChat,
    required this.onSelectSession,
  });

  String _formatRelative(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inHours < 1) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: onNewChat,
                icon: const Icon(Icons.add),
                label: const Text("New Chat"),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Text(
                "Chat History",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.grey[600]),
              ),
            ),
            Expanded(
              child: sessions.isEmpty
                  ? Center(
                      child: Text("No previous chats", style: TextStyle(color: Colors.grey[500])),
                    )
                  : ListView.builder(
                      itemCount: sessions.length,
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        return ListTile(
                          leading: const Icon(Icons.chat_bubble_outline, size: 20),
                          title: Text(
                            session.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            _formatRelative(session.lastUpdated),
                            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                          ),
                          onTap: () => onSelectSession(session),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
