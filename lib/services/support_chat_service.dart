// // lib/services/support_chat_service.dart
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:pawpal/models/support_chat.dart';
// import 'package:pawpal/models/support_message.dart';

// class SupportChatService {
//   final SupabaseClient _supabase;

//   SupportChatService(this._supabase);

//   // 1. Create a new support chat
//   Future<SupportChat> createSupportChat({
//     required String clientId,
//     required String clientDisplayName,
//     required String subject,
//   }) async {
//     try {
//       final response = await _supabase.from('support_chats').insert({
//         'client_id': clientId,
//         'client_display_name': clientDisplayName,
//         'subject': subject,
//         'status': 'open',
//         'last_message_at': DateTime.now().toIso8601String(),
//         'is_read_by_user': true,
//         'is_read_by_admin': false,
//       }).select().single();

//       return SupportChat.fromJson(response);
//     } catch (e) {
//       throw Exception('Failed to create support chat: $e');
//     }
//   }

//   // 2. Get a single support chat by ID
//   Future<SupportChat> getSupportChatById(String chatId) async {
//     try {
//       final response = await _supabase
//           .from('support_chats')
//           .select()
//           .eq('id', chatId)
//           .single();
//       return SupportChat.fromJson(response);
//     } catch (e) {
//       throw Exception('Failed to fetch support chat: $e');
//     }
//   }

//   // 3. Get all support chats for a specific client (for client view)
//   Stream<List<SupportChat>> getClientSupportChatsStream(String clientId) {
//     return _supabase
//         .from('support_chats')
//         .stream(primaryKey: ['id'])
//         .eq('client_id', clientId)
//         .order('last_message_at', ascending: false)
//         .map((data) {
//       final typedData = List<Map<String, dynamic>>.from(data);
//       return typedData.map((json) => SupportChat.fromJson(json)).toList();
//     });
//   }

//   // 4. Get all support chats for admin view
//   Stream<List<SupportChat>> getAllSupportChatsStreamForAdmin() {
//     return _supabase
//         .from('support_chats')
//         .stream(primaryKey: ['id'])
//         .order('last_message_at', ascending: false)
//         .map((data) {
//       final typedData = List<Map<String, dynamic>>.from(data);
//       return typedData.map((json) => SupportChat.fromJson(json)).toList();
//     });
//   }

//   // 5. Add a message to a chat
//   Future<void> addMessageToChat({
//     required String chatId,
//     required String senderId,
//     required String senderDisplayName,
//     required String content,
//     required bool isClient,
//     required String senderRole,
//   }) async {
//     try {
//       final response = await _supabase.from('support_messages').insert({
//         'chat_id': chatId,
//         'sender_id': senderId,
//         'sender_display_name': senderDisplayName,
//         'content': content,
//         'is_client': isClient,
//         'sender_role': senderRole,
//         'message_type': 'chat',
//         'created_at': DateTime.now().toIso8601String(),
//       }).select().single();

//       // Update the last_message_at and read status in the chat
//       await _supabase.from('support_chats').update({
//         'last_message_at': DateTime.now().toIso8601String(),
//         'is_read_by_user': !isClient,
//         'is_read_by_admin': isClient,
//       }).eq('id', chatId);

//       // Invoke the AI Edge Function if the message is from the client
//       if (isClient) {
//         // Pass the entire inserted message record to the Edge Function
//         await _supabase.functions.invoke(
//           'ai-support-agent',
//           body: { 'record': response },
//         );
//       }
//     } catch (e) {
//       throw Exception('Failed to add message to chat: $e');
//     }
//   }

//   // 6. Get messages for a specific chat (stream)
//   Stream<List<SupportMessage>> getMessagesForChatStream(String chatId) {
//     return _supabase
//         .from('support_messages')
//         .stream(primaryKey: ['id'])
//         .eq('chat_id', chatId)
//         // This is the fix for message arrangement
//         .order('created_at', ascending: true)
//         .map((data) {
//       // Correctly cast the outer list and then map each element
//       final typedData = List<Map<String, dynamic>>.from(data);
//       return typedData.map((json) => SupportMessage.fromJson(json)).toList();
//     });
//   }

//   // 7. Mark chat as read by client
//   Future<void> markChatAsReadByClient(String chatId) async {
//     try {
//       await _supabase
//           .from('support_chats')
//           .update({'is_read_by_user': true}).eq('id', chatId);
//     } catch (e) {
//       throw Exception('Failed to mark chat as read by client: $e');
//     }
//   }

//   // 8. Mark chat as read by admin
//   Future<void> markChatAsReadByAdmin(String chatId) async {
//     try {
//       await _supabase
//           .from('support_chats')
//           .update({'is_read_by_admin': true}).eq('id', chatId);
//     } catch (e) {
//       throw Exception('Failed to mark chat as read by admin: $e');
//     }
//   }

//   // 9. Update chat status (for admin)
//   Future<void> updateChatStatus(String chatId, String status) async {
//     try {
//       await _supabase
//           .from('support_chats')
//           .update({'status': status}).eq('id', chatId);
//     } catch (e) {
//       throw Exception('Failed to update chat status: $e');
//     }
//   }
// }








// lib/services/support_chat_service.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pawpal/models/support_chat.dart';
import 'package:pawpal/models/support_message.dart';

class SupportChatService {
  final SupabaseClient _supabase;

  SupportChatService(this._supabase);

  // 1. Create a new support chat
  Future<SupportChat> createSupportChat({
    required String clientId,
    required String clientDisplayName,
    required String subject,
  }) async {
    try {
      final response = await _supabase.from('support_chats').insert({
        'client_id': clientId,
        'client_display_name': clientDisplayName,
        'subject': subject,
        'status': 'open',
        'last_message_at': DateTime.now().toIso8601String(),
        'is_read_by_user': true,
        'is_read_by_admin': false,
      }).select().single();

      return SupportChat.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create support chat: $e');
    }
  }

  // 2. Get a single support chat by ID
  Future<SupportChat> getSupportChatById(String chatId) async {
    try {
      final response = await _supabase
          .from('support_chats')
          .select()
          .eq('id', chatId)
          .single();
      return SupportChat.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch support chat: $e');
    }
  }

  // 3. Get all support chats for a specific client (for client view)
  Stream<List<SupportChat>> getClientSupportChatsStream(String clientId) {
    return _supabase
        .from('support_chats')
        .stream(primaryKey: ['id'])
        .eq('client_id', clientId)
        .order('last_message_at', ascending: false)
        .map((data) {
      final typedData = List<Map<String, dynamic>>.from(data);
      return typedData.map((json) => SupportChat.fromJson(json)).toList();
    });
  }

  // 4. Get all support chats for admin view
  Stream<List<SupportChat>> getAllSupportChatsStreamForAdmin() {
    return _supabase
        .from('support_chats')
        .stream(primaryKey: ['id'])
        .order('last_message_at', ascending: false)
        .map((data) {
      final typedData = List<Map<String, dynamic>>.from(data);
      return typedData.map((json) => SupportChat.fromJson(json)).toList();
    });
  }

  // 5. Add a message to a chat
  Future<void> addMessageToChat({
    required String chatId,
    required String senderId,
    required String senderDisplayName,
    required String content,
    required bool isClient,
    required String senderRole,
  }) async {
    try {
      final response = await _supabase.from('support_messages').insert({
        'chat_id': chatId,
        'sender_id': senderId,
        'sender_display_name': senderDisplayName,
        'content': content,
        'is_client': isClient,
        'sender_role': senderRole,
        'message_type': 'chat',
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();

      await _supabase.from('support_chats').update({
        'last_message_at': DateTime.now().toIso8601String(),
        'is_read_by_user': !isClient,
        'is_read_by_admin': isClient,
      }).eq('id', chatId);

      if (isClient) {
        await _supabase.functions.invoke(
          'ai-support-agent',
          body: { 'record': response },
        );
      }
    } catch (e) {
      throw Exception('Failed to add message to chat: $e');
    }
  }

  // 6. Get messages for a specific chat (stream)
  Stream<List<SupportMessage>> getMessagesForChatStream(String chatId) {
    return _supabase
        .from('support_messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at', ascending: true)
        .map((data) {
      final typedData = List<Map<String, dynamic>>.from(data);
      return typedData.map((json) => SupportMessage.fromJson(json)).toList();
    });
  }

  // 7. Mark chat as read by client
  Future<void> markChatAsReadByClient(String chatId) async {
    try {
      await _supabase
          .from('support_chats')
          .update({'is_read_by_user': true}).eq('id', chatId);
    } catch (e) {
      throw Exception('Failed to mark chat as read by client: $e');
    }
  }

  // 8. Mark chat as read by admin
  Future<void> markChatAsReadByAdmin(String chatId) async {
    try {
      await _supabase
          .from('support_chats')
          .update({'is_read_by_admin': true}).eq('id', chatId);
    } catch (e) {
      throw Exception('Failed to mark chat as read by admin: $e');
    }
  }

  // 9. Update chat status (for admin)
  Future<void> updateChatStatus(String chatId, String status) async {
    try {
      await _supabase
          .from('support_chats')
          .update({'status': status}).eq('id', chatId);
    } catch (e) {
      throw Exception('Failed to update chat status: $e');
    }
  }

  // 10. Delete a specific message from a chat
  Future<void> deleteMessage(String messageId) async {
    try {
      await _supabase
          .from('support_messages')
          .delete()
          .eq('id', messageId);
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  // 11. Delete an entire chat and all its messages
  Future<void> deleteSupportChat(String chatId) async {
    try {
      // First, delete all messages associated with the chat
      await _supabase
          .from('support_messages')
          .delete()
          .eq('chat_id', chatId);

      // Then, delete the chat itself
      await _supabase
          .from('support_chats')
          .delete()
          .eq('id', chatId);
    } catch (e) {
      throw Exception('Failed to delete chat: $e');
    }
  }

  Future<void> markChatAsRead(String chatId) async {
  try {
    await _supabase.from('support_chats').update({
      'is_read_by_user': true,
    }).eq('id', chatId);
    debugPrint('Chat $chatId marked as read.');
  } catch (e) {
    debugPrint('Error marking chat as read: $e');
  }
}
}