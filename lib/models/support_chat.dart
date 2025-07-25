// lib/models/support_chat.dart
import 'package:intl/intl.dart';

class SupportChat {
  final String id;
  final String clientId;
  final String clientDisplayName;
  final String subject;
  final String status; // e.g., 'open', 'resolved', 'closed'
  final DateTime lastMessageAt;
  final bool isReadByUser;
  final bool isReadByAdmin;

  SupportChat({
    required this.id,
    required this.clientId,
    required this.clientDisplayName,
    required this.subject,
    required this.status,
    required this.lastMessageAt,
    required this.isReadByUser,
    required this.isReadByAdmin,
  });

  factory SupportChat.fromJson(Map<String, dynamic> json) {
    return SupportChat(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      clientDisplayName: json['client_display_name'] as String,
      subject: json['subject'] as String,
      status: json['status'] as String,
      lastMessageAt: DateTime.parse(json['last_message_at'] as String),
      isReadByUser: json['is_read_by_user'] as bool,
      isReadByAdmin: json['is_read_by_admin'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'client_display_name': clientDisplayName,
      'subject': subject,
      'status': status,
      'last_message_at': lastMessageAt.toIso8601String(),
      'is_read_by_user': isReadByUser,
      'is_read_by_admin': isReadByAdmin,
    };
  }

  String get formattedLastMessageTime {
    return DateFormat('MMM dd, hh:mm a').format(lastMessageAt);
  }
}