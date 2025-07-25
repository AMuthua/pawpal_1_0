// lib/models/support_message.dart
import 'package:intl/intl.dart'; // Import for date formatting

class SupportMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String? senderDisplayName; // Matches DB column name
  final String? content;
  final bool? isClient;
  final DateTime? createdAt;

  SupportMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.senderDisplayName,
    this.content,
    this.isClient,
    this.createdAt,
  });

  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    return SupportMessage(
      id: json['id'] as String,
      chatId: json['chat_id'] as String,
      senderId: json['sender_id'] as String,
      // *** THIS LINE IS CRITICAL ***
      // It MUST read from 'sender_display_name' which is the column in your DB
      senderDisplayName: json['sender_display_name'] as String?,
      content: json['content'] as String?,
      isClient: json['is_client'] as bool?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      // *** THIS LINE IS CRITICAL ***
      // It MUST write to 'sender_display_name' which is the column in your DB
      'sender_display_name': senderDisplayName,
      'content': content,
      'is_client': isClient,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  String get formattedCreatedAt {
    return createdAt != null ? DateFormat('MMM dd, hh:mm a').format(createdAt!) : 'N/A';
  }
}