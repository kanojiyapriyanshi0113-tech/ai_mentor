import 'package:dio/dio.dart';

import 'api_client.dart';

class SendMessageResult {
  final String reply;
  final String sessionId;

  SendMessageResult({required this.reply, required this.sessionId});
}

class ChatMessageApi {
  final String role;
  final String message;
  final DateTime createdAt;

  ChatMessageApi({
    required this.role,
    required this.message,
    required this.createdAt,
  });

  factory ChatMessageApi.fromJson(Map<String, dynamic> json) {
    return ChatMessageApi(
      role: json['role'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class ChatSessionApi {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatSessionApi({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatSessionApi.fromJson(Map<String, dynamic> json) {
    return ChatSessionApi(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class ChatSessionDetail {
  final ChatSessionApi session;
  final List<ChatMessageApi> messages;

  ChatSessionDetail({required this.session, required this.messages});
}

class AIChatApiService {
  final Dio _dio = ApiClient().dio;

  /// Sends a message. Pass sessionId=null (or empty) to start a new,
  /// auto-titled session — the backend returns the resolved session id.
  Future<SendMessageResult> sendMessage(String message, {String? sessionId}) async {
    final response = await _dio.post('/ai/chat', data: {
      'message': message,
      if (sessionId != null && sessionId.isNotEmpty) 'session_id': sessionId,
    });
    final data = response.data['data'] as Map<String, dynamic>;
    return SendMessageResult(
      reply: data['reply'] as String,
      sessionId: data['session_id'] as String,
    );
  }

  Future<List<ChatSessionApi>> listSessions() async {
    final response = await _dio.get('/chat/sessions');
    final list = response.data['data'] as List<dynamic>;
    return list.map((e) => ChatSessionApi.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ChatSessionDetail> getSession(String sessionId) async {
    final response = await _dio.get('/chat/session/$sessionId');
    final data = response.data['data'] as Map<String, dynamic>;
    return ChatSessionDetail(
      session: ChatSessionApi.fromJson(data['session'] as Map<String, dynamic>),
      messages: (data['messages'] as List<dynamic>)
          .map((e) => ChatMessageApi.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<void> renameSession(String sessionId, String title) async {
    await _dio.patch('/chat/session/$sessionId', data: {'title': title});
  }

  Future<void> deleteSession(String sessionId) async {
    await _dio.delete('/chat/session/$sessionId');
  }
}
