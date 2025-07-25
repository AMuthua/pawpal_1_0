// lib/services/support_chat_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pawpal/models/support_chat.dart';
import 'package:pawpal/models/support_message.dart'; // Ensure this is imported

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
        'status': 'open', // Initial status
        'last_message_at': DateTime.now().toIso8601String(),
        'is_read_by_user': true, // Client initiating, so read by client
        'is_read_by_admin': false, // Not yet read by admin
      }).select().single();

      // .single() typically returns Map<String, dynamic> directly,
      // so explicit cast here is usually not needed, but good to be aware.
      return SupportChat.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create support chat: $e');
    }
  }

  // 2. Get a single support chat by ID (for both client and admin)
  Future<SupportChat> getSupportChatById(String chatId) async {
    try {
      final response = await _supabase
          .from('support_chats')
          .select()
          .eq('id', chatId)
          .single();
      // No explicit cast needed for .single() as it typically returns Map<String, dynamic>
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
        .order('last_message_at', ascending: false) // Order by latest message
        .map((data) {
          // *** THE CRITICAL FIX FOR TypeError: List<dynamic> is not a subtype of List<Map<String, dynamic>> ***
          // Explicitly cast the incoming 'data' list to the expected type
          final List<Map<String, dynamic>> typedData = List<Map<String, dynamic>>.from(data);
          return typedData.map((json) => SupportChat.fromJson(json)).toList();
        });
  }

  // 4. Get all support chats for admin view
  Stream<List<SupportChat>> getAllSupportChatsStreamForAdmin() {
    return _supabase
        .from('support_chats')
        .stream(primaryKey: ['id'])
        .order('last_message_at', ascending: false) // Order by latest message
        .map((data) {
          // *** THE CRITICAL FIX FOR TypeError: List<dynamic> is not a subtype of List<Map<String, dynamic>> ***
          // Explicitly cast the incoming 'data' list to the expected type
          final List<Map<String, dynamic>> typedData = List<Map<String, dynamic>>.from(data);
          return typedData.map((json) => SupportChat.fromJson(json)).toList();
        });
  }

  // 5. Add a message to a chat
  // Future<void> addMessageToChat({
  //   required String chatId,
  //   required String senderId,
  //   required String senderDisplayName,
  //   required String content,
  //   required bool isClient, // True if sent by client, false if by admin
  // }) async {
  //   try {
  //     await _supabase.from('support_messages').insert({
  //       'chat_id': chatId,
  //       'sender_id': senderId,
  //       'sender_display_name': senderDisplayName,
  //       'content': content,
  //       'is_client': isClient,
  //       'created_at': DateTime.now().toIso8601String(),
  //     });

   Future<void> addMessageToChat({
    required String chatId,
    required String senderId,
    required String senderDisplayName,
    required String content,
    required bool isClient, // True if sent by client, false if by admin
    required String senderRole, // <--- ADD THIS NEW PARAMETER
  }) async {
    try {
      await _supabase.from('support_messages').insert({
        'chat_id': chatId,
        'sender_id': senderId,
        'sender_display_name': senderDisplayName,
        'content': content,
        'is_client': isClient,
        'created_at': DateTime.now().toIso8601String(),
        'sender_role': senderRole, // <--- ADD THIS TO THE INSERT
      });

      // Update the last_message_at and read status in the chat
      await _supabase.from('support_chats').update({
        'last_message_at': DateTime.now().toIso8601String(),
        // Mark as unread for the *other* party
        'is_read_by_user': !isClient, // If admin sends, client hasn't read
        'is_read_by_admin': isClient, // If client sends, admin hasn't read
      }).eq('id', chatId);
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
      .order('created_at', ascending: true) // <--- CHANGE THIS TO TRUE
      .map((data) {
        final List<Map<String, dynamic>> typedData = List<Map<String, dynamic>>.from(data);
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
}