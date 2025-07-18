// // lib/models/support_message.dart
// import 'package:intl/intl.dart'; // For formatting dates

// class SupportMessage {
//   final String id;
//   final DateTime createdAt;
//   final String chatId;
//   final String? senderId; // Null for 'assistant' messages
//   final String senderRole; // 'client', 'admin', 'assistant'
//   final String content;
//   final String? aiInputText; // Stores the client's message that AI responded to
//   final String messageType; // 'chat', 'admin_comment'

//   SupportMessage({
//     required this.id,
//     required this.createdAt,
//     required this.chatId,
//     this.senderId,
//     required this.senderRole,
//     required this.content,
//     this.aiInputText,
//     required this.messageType,
//   });

//   // Factory constructor to create a SupportMessage from a Supabase row (Map)
//   factory SupportMessage.fromMap(Map<String, dynamic> data) {
//     return SupportMessage(
//       id: data['id'] as String,
//       createdAt: DateTime.parse(data['created_at'] as String),
//       chatId: data['chat_id'] as String,
//       senderId: data['sender_id'] as String?,
//       senderRole: data['sender_role'] as String,
//       content: data['content'] as String,
//       aiInputText: data['ai_input_text'] as String?,
//       messageType: data['message_type'] as String,
//     );
//   }

//   // Method to convert a SupportMessage object to a Map for Supabase insertion
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'created_at': createdAt.toIso8601String(),
//       'chat_id': chatId,
//       'sender_id': senderId,
//       'sender_role': senderRole,
//       'content': content,
//       'ai_input_text': aiInputText,
//       'message_type': messageType,
//     };
//   }

//   // Helper to get formatted message time for display
//   String get formattedTime => DateFormat('HH:mm').format(createdAt);

//   get timestamp => null;

//   String? get message => null;
// }






import 'package:intl/intl.dart'; // For formatting dates

class SupportMessage {
  final String id;
  final DateTime createdAt; // Your existing 'createdAt'
  final String chatId;
  final String? senderId; // Null for 'assistant' messages
  final String senderRole; // 'client', 'admin', 'assistant'
  final String content; // Your existing 'content'
  final String? aiInputText; // Stores the client's message that AI responded to
  final String messageType; // 'chat', 'admin_comment'

  // NEW: Add 'isRead' property (from my previous suggestion, useful for UI)
  final bool isRead; // Assuming you'll add 'is_read' to your Supabase table for messages

  SupportMessage({
    required this.id,
    required this.createdAt,
    required this.chatId,
    this.senderId,
    required this.senderRole,
    required this.content,
    this.aiInputText,
    required this.messageType,
    this.isRead = false, // Default to false if not provided
  });

  // Factory constructor to create a SupportMessage from a Supabase row (Map)
  factory SupportMessage.fromMap(Map<String, dynamic> data) {
    return SupportMessage(
      id: data['id'] as String,
      createdAt: DateTime.parse(data['created_at'] as String),
      chatId: data['chat_id'] as String,
      senderId: data['sender_id'] as String?,
      senderRole: data['sender_role'] as String,
      content: data['content'] as String,
      aiInputText: data['ai_input_text'] as String?,
      messageType: data['message_type'] as String,
      isRead: data['is_read'] as bool? ?? false, // Assuming 'is_read' column might exist
    );
  }

  // Method to convert a SupportMessage object to a Map for Supabase insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'chat_id': chatId,
      'sender_id': senderId,
      'sender_role': senderRole,
      'content': content,
      'ai_input_text': aiInputText,
      'message_type': messageType,
      'is_read': isRead, // Include if you have this column in DB
    };
  }

  // Helper to get formatted message time for display
  String get formattedTime => DateFormat('HH:mm').format(createdAt);

  // NEW: Add getters for 'message' and 'timestamp' to match ClientChatScreen's expectations
  // These will simply return your existing properties with the names ClientChatScreen expects.
  String get message => content; // ClientChatScreen expects 'message.message'
  DateTime get timestamp => createdAt; // ClientChatScreen expects 'message.timestamp'
}