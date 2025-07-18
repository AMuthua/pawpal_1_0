// // lib/services/support_chat_service.dart
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:pawpal/models/support_chat.dart';
// import 'package:pawpal/models/support_message.dart';
// import 'package:logger/logger.dart'; // Import a logging package

// class SupportChatService {
//   final SupabaseClient _supabase = Supabase.instance.client;
//   final Logger _logger = Logger(); // Initialize a logger

//   /// Creates a new support chat and the initial message from the client.
//   /// Returns the newly created SupportChat object.
//   Future<SupportChat> createChat({
//     required String clientId,
//     required String clientDisplayName,
//     required String initialMessageContent,
//     String? subject,
//   }) async {
//     try {
//       // 1. Create the chat entry
//       // Changed the type to Map<String, dynamic> as .single() returns a single map
//       final Map<String, dynamic> chatResponse = await _supabase
//           .from('support_chats')
//           .insert({
//             'client_id': clientId,
//             'client_display_name': clientDisplayName,
//             'status': 'assistant_handling', // Initial status
//             'last_message_at': DateTime.now().toIso8601String(),
//             'last_message_text': initialMessageContent,
//             'subject': subject,
//           })
//           .select() // Select the created row to get its ID and other defaults
//           .single(); // Expecting a single map

//       final SupportChat newChat = SupportChat.fromMap(chatResponse); // Pass the map directly

//       // 2. Add the initial message to the messages subcollection
//       await _supabase.from('support_messages').insert({
//         'chat_id': newChat.id,
//         'sender_id': clientId,
//         'sender_role': 'client',
//         'content': initialMessageContent,
//         'created_at': DateTime.now().toIso8601String(),
//         'message_type': 'chat',
//       });

//       // TODO: Trigger the Edge Function for AI response here (next step)
//       // For now, we'll just create the chat and message.
//       // The AI response will be handled by a Supabase Database Trigger -> Edge Function.

//       return newChat;
//     } on PostgrestException catch (e) {
//       _logger.e('Supabase Error creating chat: ${e.message}', error: e); // Use logger for errors
//       throw Exception('Failed to create chat: ${e.message}');
//     } catch (e) {
//       _logger.e('Unexpected Error creating chat: $e', error: e); // Use logger for errors
//       throw Exception('An unexpected error occurred while creating chat: $e');
//     }
//   }

//   /// Sends a new message to an existing chat.
//   Future<SupportMessage> sendMessage({
//     required String chatId,
//     required String? senderId, // Null for assistant messages
//     required String senderRole, // 'client', 'admin', 'assistant'
//     required String content,
//     String? aiInputText, // Only for 'assistant' role
//     String messageType = 'chat', // 'chat' or 'admin_comment'
//   }) async {
//     try {
//       final now = DateTime.now();
//       // Changed the type to Map<String, dynamic>
//       final Map<String, dynamic> messageResponse = await _supabase
//           .from('support_messages')
//           .insert({
//             'chat_id': chatId,
//             'sender_id': senderId,
//             'sender_role': senderRole,
//             'content': content,
//             'created_at': now.toIso8601String(),
//             'ai_input_text': aiInputText,
//             'message_type': messageType,
//           })
//           .select()
//           .single(); // Expecting a single map

//       // Update the last_message_at and last_message_text in the parent chat
//       await _supabase.from('support_chats').update({
//         'last_message_at': now.toIso8601String(),
//         'last_message_text': content,
//       }).eq('id', chatId);

//       return SupportMessage.fromMap(messageResponse); // Pass the map directly
//     } on PostgrestException catch (e) {
//       _logger.e('Supabase Error sending message: ${e.message}', error: e);
//       throw Exception('Failed to send message: ${e.message}');
//     } catch (e) {
//       _logger.e('Unexpected Error sending message: $e', error: e);
//       throw Exception('An unexpected error occurred while sending message: $e');
//     }
//   }

//   /// Fetches all messages for a specific chat.
//   Future<List<SupportMessage>> getChatMessages(String chatId) async {
//     try {
//       final List<Map<String, dynamic>> data = await _supabase
//           .from('support_messages')
//           .select('*')
//           .eq('chat_id', chatId)
//           .order('created_at', ascending: true); // Order chronologically

//       return data.map((json) => SupportMessage.fromMap(json)).toList();
//     } on PostgrestException catch (e) {
//       _logger.e('Supabase Error fetching chat messages: ${e.message}', error: e);
//       throw Exception('Failed to fetch chat messages: ${e.message}');
//     } catch (e) {
//       _logger.e('Unexpected Error fetching chat messages: $e', error: e);
//       throw Exception('An unexpected error occurred while fetching chat messages: $e');
//     }
//   }

//   /// Streams real-time updates for messages in a specific chat.
//   Stream<List<SupportMessage>> streamChatMessages(String chatId) {
//     return _supabase
//         .from('support_messages')
//         .stream(primaryKey: ['id']) // Listen for changes to individual messages
//         .eq('chat_id', chatId) // Filter for messages in this chat
//         .order('created_at', ascending: true)
//         .map((events) => events.map((json) => SupportMessage.fromMap(json)).toList());
//   }

//   /// Fetches all support chats for a given client.
//   Future<List<SupportChat>> getClientChats(String clientId) async {
//     try {
//       final List<Map<String, dynamic>> data = await _supabase
//           .from('support_chats')
//           .select('*')
//           .eq('client_id', clientId)
//           .order('last_message_at', ascending: false); // Most recent chats first

//       return data.map((json) => SupportChat.fromMap(json)).toList();
//     } on PostgrestException catch (e) {
//       _logger.e('Supabase Error fetching client chats: ${e.message}', error: e);
//       throw Exception('Failed to fetch client chats: ${e.message}');
//     } catch (e) {
//       _logger.e('Unexpected Error fetching client chats: $e', error: e);
//       throw Exception('An unexpected error occurred while fetching client chats: $e');
//     }
//   }

//   /// Streams real-time updates for a client's support chats.
//   Stream<List<SupportChat>> streamClientChats(String clientId) {
//     return _supabase
//         .from('support_chats')
//         .stream(primaryKey: ['id'])
//         .eq('client_id', clientId)
//         .order('last_message_at', ascending: false)
//         .map((events) => events.map((json) => SupportChat.fromMap(json)).toList());
//   }

//   /// Fetches all open or in-progress chats for admin dashboard.
//   Future<List<SupportChat>> getAdminOpenChats() async {
//     try {
//       final List<Map<String, dynamic>> data = await _supabase
//           .from('support_chats')
//           .select('*')
//           .inFilter('status', ['open', 'in_progress', 'assistant_handling']) // Include assistant_handling
//           .order('last_message_at', ascending: false);

//       return data.map((json) => SupportChat.fromMap(json)).toList();
//     } on PostgrestException catch (e) {
//       _logger.e('Supabase Error fetching admin open chats: ${e.message}', error: e);
//       throw Exception('Failed to fetch admin open chats: ${e.message}');
//     } catch (e) {
//       _logger.e('Unexpected Error fetching admin open chats: $e', error: e);
//       throw Exception('An unexpected error occurred while fetching admin open chats: $e');
//     }
//   }

//   /// Streams real-time updates for admin's open/in-progress chats.
//   Stream<List<SupportChat>> streamAdminOpenChats() {
//     return _supabase
//         .from('support_chats')
//         .stream(primaryKey: ['id'])
//         .inFilter('status', ['open', 'in_progress', 'assistant_handling'])
//         .order('last_message_at', ascending: false)
//         .map((events) => events.map((json) => SupportChat.fromMap(json)).toList());
//   }

//   /// Assigns an admin to a chat and changes its status to 'in_progress'.
//   Future<void> assignAdminToChat(String chatId, String adminId) async {
//     try {
//       await _supabase.from('support_chats').update({
//         'admin_id': adminId,
//         'status': 'in_progress',
//       }).eq('id', chatId);
//     } on PostgrestException catch (e) {
//       _logger.e('Supabase Error assigning admin to chat: ${e.message}', error: e);
//       throw Exception('Failed to assign admin to chat: ${e.message}');
//     } catch (e) {
//       _logger.e('Unexpected Error assigning admin to chat: $e', error: e);
//       throw Exception('An unexpected error occurred while assigning admin to chat: $e');
//     }
//   }

//   /// Changes chat status to 'open' (escalate to human).
//   Future<void> escalateChatToAdmin(String chatId) async {
//     try {
//       await _supabase.from('support_chats').update({
//         'status': 'open',
//       }).eq('id', chatId);
//     } on PostgrestException catch (e) {
//       _logger.e('Supabase Error escalating chat: ${e.message}', error: e);
//       throw Exception('Failed to escalate chat: ${e.message}');
//     } catch (e) {
//       _logger.e('Unexpected Error escalating chat: $e', error: e);
//       throw Exception('An unexpected error occurred while escalating chat: $e');
//     }
//   }

//   /// Closes a support chat.
//   Future<void> closeChat(String chatId) async {
//     try {
//       await _supabase.from('support_chats').update({
//         'status': 'closed',
//         'admin_id': null, // Unassign admin when closed
//       }).eq('id', chatId);
//     } on PostgrestException catch (e) {
//       _logger.e('Supabase Error closing chat: ${e.message}', error: e);
//       throw Exception('Failed to close chat: ${e.message}');
//     } catch (e) {
//       _logger.e('Unexpected Error closing chat: $e', error: e);
//       throw Exception('An unexpected error occurred while closing chat: $e');
//     }
//   }

//   /// Adds an internal admin comment to a chat.
//   Future<SupportMessage> addAdminComment({
//     required String chatId,
//     required String adminId,
//     required String commentText,
//   }) async {
//     try {
//       final now = DateTime.now();
//       // Changed the type to Map<String, dynamic>
//       final Map<String, dynamic> messageResponse = await _supabase
//           .from('support_messages')
//           .insert({
//             'chat_id': chatId,
//             'sender_id': adminId,
//             'sender_role': 'admin', // Admin is the sender
//             'content': commentText,
//             'created_at': now.toIso8601String(),
//             'message_type': 'admin_comment', // Mark as an internal comment
//           })
//           .select()
//           .single(); // Expecting a single map

//       // Do NOT update last_message_at/text for internal comments
//       return SupportMessage.fromMap(messageResponse); // Pass the map directly
//     } on PostgrestException catch (e) {
//       _logger.e('Supabase Error adding admin comment: ${e.message}', error: e);
//       throw Exception('Failed to add admin comment: ${e.message}');
//     } catch (e) {
//       _logger.e('Unexpected Error adding admin comment: $e', error: e);
//       throw Exception('An unexpected error occurred while adding admin comment: $e');
//     }
//   }
// }






import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/support_chat.dart';
import '../models/support_message.dart';

class SupportChatService extends ChangeNotifier {
  final SupabaseClient _supabase;
  User? _currentUser;

  SupportChatService() : _supabase = Supabase.instance.client {
    _currentUser = _supabase.auth.currentUser;
    _supabase.auth.onAuthStateChange.listen((data) {
      _currentUser = data.session?.user;
      notifyListeners();
    });
  }

  String? get currentUserId => _currentUser?.id;

  // --- Chat Management ---

  Stream<List<SupportChat>> getChatsForUser() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    // Admins can see all chats
    // Regular users can only see chats they are part of (client_id = currentUserId)
    final query = _supabase
        .from('support_chats')
        .stream(primaryKey: ['id'])
        .order('last_message_at', ascending: false) // Order by latest message
        .map((chatsData) {
          return chatsData
              .map((chatMap) => SupportChat.fromMap(chatMap))
              .toList();
        });

    return query;
  }

  Future<SupportChat> createSupportChat({
  required String clientId,
  required String clientDisplayName,
  required String? subject, // Make sure this is 'String?'
  String? initialMessageContent, // Allow initial message with chat creation
  }) async {
    final Map<String, dynamic> newChatData = {
      'client_id': clientId,
      'client_display_name': clientDisplayName,
      'subject': subject,
      'status': 'open',
      'created_at': DateTime.now().toIso8601String(),
      // 'type' and 'admin_name' are in your model. If they are DB columns, add them here
      // For a new chat, type might default to 'user_chat' and adminName to null
      // 'type': 'user_chat', // Assuming 'type' is a column
      // 'admin_name' is typically populated by an admin
    };

    final response = await _supabase
        .from('support_chats')
        .insert(newChatData)
        .select()
        .single();

    final createdChat = SupportChat.fromMap(response);

    // If there's an initial message, send it immediately
    if (initialMessageContent != null && initialMessageContent.isNotEmpty) {
      final initialMessage = SupportMessage(
        id: const Uuid().v4(), // Requires uuid package, make sure it's imported in ClientChatScreen if not already
        chatId: createdChat.id,
        senderId: clientId,
        senderRole: 'client',
        content: initialMessageContent,
        createdAt: DateTime.now(),
        messageType: 'chat',
      );
      await sendMessage(initialMessage);
    }

    return createdChat;
  }


  Future<void> updateChatStatus(String chatId, String status) async {
    await _supabase
        .from('support_chats')
        .update({'status': status})
        .eq('id', chatId);
  }

  // --- Message Management ---

  Stream<List<SupportMessage>> getMessagesForChat(String chatId) {
    return _supabase
        .from('support_messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at', ascending: true) // Order by your 'createdAt'
        .map((messagesData) {
          return messagesData
              .map((messageMap) => SupportMessage.fromMap(messageMap))
              .toList();
        });
  }

  Future<void> sendMessage(SupportMessage message) async {
    // Insert the new message
    await _supabase.from('support_messages').insert(message.toMap());

    // Update the parent chat's last_message_text and last_message_at
    // And also update is_read flags
    await _supabase.from('support_chats').update({
      'last_message_text': message.content, // Use 'content' from your model
      'last_message_at': message.createdAt.toIso8601String(), // Use 'createdAt' from your model
      // Mark for the *other* party as unread.
      // This logic depends on whether the sender is client or admin.
      // You'll need to fetch the chat details or sender's role to set this accurately.
      // For now, let's simplify for common use:
      // If client sends, admin hasn't read. If admin sends, client hasn't read.
      'is_read_by_user': message.senderRole == 'client' ? true : false, // true if client sent, false if admin sent
      'is_read_by_admin': message.senderRole == 'admin' ? true : false, // true if admin sent, false if client sent
    }).eq('id', message.chatId);
  }

  Future<void> markMessagesAsRead(String chatId, String readerId) async {
    // Determine which 'is_read' column to update based on who is reading
    // Assuming 'client' and 'admin' roles.
    final Map<String, dynamic>? userProfile = await _supabase
        .from('profiles') // Assuming your profiles table where role is stored
        .select('role')
        .eq('id', readerId)
        .maybeSingle();

    final String? readerRole = userProfile?['role'] as String?;

    Map<String, dynamic> updateData = {};
    if (readerRole == 'client') {
      updateData['is_read_by_user'] = true; // User (client) has read messages
    } else if (readerRole == 'admin') {
      updateData['is_read_by_admin'] = true; // Admin has read messages
    }

    if (updateData.isNotEmpty) {
      await _supabase
          .from('support_chats')
          .update(updateData)
          .eq('id', chatId);
    }
  }

  // Helper to get user role (used in markMessagesAsRead)
  Future<String?> _getUserRole(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .maybeSingle();
      return response?['role'] as String?;
    } catch (e) {
      print('Error fetching user role for markAsRead: $e');
      return null;
    }
  }

  createChat({required String clientId, required String clientDisplayName, required String initialMessageContent, String? subject}) {}

  streamClientChats(String currentUserId) {}
}