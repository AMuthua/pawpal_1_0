// // lib/models/support_chat.dart
// import 'package:intl/intl.dart'; // For formatting dates

// class SupportChat {
//   final String id;
//   final DateTime createdAt;
//   final String clientId;
//   final String clientDisplayName;
//   final String? adminId; // Null if not assigned
//   String status; // e.g., 'assistant_handling', 'open', 'in_progress', 'closed'
//   final DateTime? lastMessageAt;
//   final String? lastMessageText;
//   final String? subject;

//   SupportChat({
//     required this.id,
//     required this.createdAt,
//     required this.clientId,
//     required this.clientDisplayName,
//     this.adminId,
//     required this.status,
//     this.lastMessageAt,
//     this.lastMessageText,
//     this.subject,
//   });

//   // Factory constructor to create a SupportChat from a Supabase row (Map)
//   factory SupportChat.fromMap(Map<String, dynamic> data) {
//     return SupportChat(
//       id: data['id'] as String,
//       createdAt: DateTime.parse(data['created_at'] as String),
//       clientId: data['client_id'] as String,
//       clientDisplayName: data['client_display_name'] as String,
//       adminId: data['admin_id'] as String?,
//       status: data['status'] as String,
//       lastMessageAt: data['last_message_at'] != null
//           ? DateTime.parse(data['last_message_at'] as String)
//           : null,
//       lastMessageText: data['last_message_text'] as String?,
//       subject: data['subject'] as String?,
//     );
//   }

//   // Method to convert a SupportChat object to a Map for Supabase insertion/update
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'created_at': createdAt.toIso8601String(),
//       'client_id': clientId,
//       'client_display_name': clientDisplayName,
//       'admin_id': adminId,
//       'status': status,
//       'last_message_at': lastMessageAt?.toIso8601String(),
//       'last_message_text': lastMessageText,
//       'subject': subject,
//     };
//   }

//   // Helper to get a formatted last message time for display
//   String get formattedLastMessageTime {
//     if (lastMessageAt == null) return '';
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final messageDay = DateTime(lastMessageAt!.year, lastMessageAt!.month, lastMessageAt!.day);

//     if (messageDay.isAtSameMomentAs(today)) {
//       return DateFormat('HH:mm').format(lastMessageAt!); // Today: 14:30
//     } else if (messageDay.isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
//       return 'Yesterday'; // Yesterday
//     } else if (now.difference(lastMessageAt!).inDays < 7) {
//       return DateFormat('EEE').format(lastMessageAt!); // Within a week: Mon, Tue
//     } else {
//       return DateFormat('dd/MM/yy').format(lastMessageAt!); // Older: 01/01/23
//     }
//   }

//   get type => null;

//   get adminName => null;
// }






import 'package:intl/intl.dart'; // For formatting dates

class SupportChat {
  final String id;
  final DateTime createdAt;
  final String clientId;
  final String clientDisplayName; // This is essentially the chat "subject" for client-side
  final String? adminId; // Null if not assigned
  String status; // e.g., 'assistant_handling', 'open', 'in_progress', 'closed'
  final DateTime? lastMessageAt;
  final String? lastMessageText;
  final String? subject; // Original subject from when chat was created

  // NEW: Added type and adminName properties
  // You might derive 'type' based on whether adminId is present or a specific column in DB
  // For simplicity, we'll keep it as a field for now, or you can determine its source.
  // For now, let's add a derived 'type' for the ClientChatScreen's logic.
  // Assuming 'admin_chat' if adminId is present, else 'user_chat'
  final String type;
  // If you store admin's display name in a 'profiles' table, you'd fetch it there.
  // For now, let's use a placeholder or assume it comes with the chat details if needed.
  // For the purpose of the client chat screen, `adminName` from chat details implies an admin is involved.
  final String? adminName;


  SupportChat({
    required this.id,
    required this.createdAt,
    required this.clientId,
    required this.clientDisplayName,
    this.adminId,
    required this.status,
    this.lastMessageAt,
    this.lastMessageText,
    this.subject,
    // Add type and adminName here too, even if null by default, or derived in factory
    String? type, // Make this optional if you derive it
    this.adminName,
  }) : type = type ?? (adminId != null ? 'admin_chat' : 'user_chat'); // Derive type if not provided


  // Factory constructor to create a SupportChat from a Supabase row (Map)
  factory SupportChat.fromMap(Map<String, dynamic> data) {
    return SupportChat(
      id: data['id'] as String,
      createdAt: DateTime.parse(data['created_at'] as String),
      clientId: data['client_id'] as String,
      clientDisplayName: data['client_display_name'] as String,
      adminId: data['admin_id'] as String?,
      status: data['status'] as String,
      lastMessageAt: data['last_message_at'] != null
          ? DateTime.parse(data['last_message_at'] as String)
          : null,
      lastMessageText: data['last_message_text'] as String?,
      subject: data['subject'] as String?,
      // NEW: Extract 'type' and 'admin_name' if they exist in your DB or derive them
      // If 'type' exists as a column in your 'support_chats' table, use that.
      // Otherwise, derive it as shown above.
      type: data['type'] as String? ?? (data['admin_id'] != null ? 'admin_chat' : 'user_chat'),
      adminName: data['admin_name'] as String?, // Assuming you might have this in your DB
    );
  }

  // Method to convert a SupportChat object to a Map for Supabase insertion/update
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'client_id': clientId,
      'client_display_name': clientDisplayName,
      'admin_id': adminId,
      'status': status,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'last_message_text': lastMessageText,
      'subject': subject,
      'type': type, // Include type in toMap if it's a DB column
      'admin_name': adminName, // Include admin_name in toMap if it's a DB column
    };
  }

  // Helper to get a formatted last message time for display
  String get formattedLastMessageTime {
    if (lastMessageAt == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(lastMessageAt!.year, lastMessageAt!.month, lastMessageAt!.day);

    if (messageDay.isAtSameMomentAs(today)) {
      return DateFormat('HH:mm').format(lastMessageAt!); // Today: 14:30
    } else if (messageDay.isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
      return 'Yesterday'; // Yesterday
    } else if (now.difference(lastMessageAt!).inDays < 7) {
      return DateFormat('EEE').format(lastMessageAt!); // Within a week: Mon, Tue
    } else {
      return DateFormat('dd/MM/yy').format(lastMessageAt!); // Older: 01/01/23
    }
  }
}