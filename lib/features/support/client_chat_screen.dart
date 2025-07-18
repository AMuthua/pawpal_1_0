// TODO Implement this library.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart'; // For generating unique message IDs

import '../../models/support_chat.dart';
import '../../models/support_message.dart';
import '../../services/support_chat_service.dart';

class ClientChatScreen extends StatefulWidget {
  final String chatId;
  final SupportChat? initialChat;

  const ClientChatScreen({
    Key? key,
    required this.chatId,
    this.initialChat,
  }) : super(key: key);

  @override
  State<ClientChatScreen> createState() => _ClientChatScreenState();
}

class _ClientChatScreenState extends State<ClientChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final SupportChatService _chatService;
  List<SupportMessage> _messages = [];
  Stream<List<SupportMessage>>? _messagesStream;
  SupportChat? _currentChat;

  final _supabase = Supabase.instance.client;
  String? _currentUserId; // To identify current user and differentiate messages
  String? _currentUserRole; // To identify current user's role (client/admin)

  @override
  void initState() {
    super.initState();
    _chatService = Provider.of<SupportChatService>(context, listen: false);
    _currentUserId = _supabase.auth.currentUser?.id;
    _loadUserRole(); // Load user role on init

    if (widget.initialChat != null) {
      _currentChat = widget.initialChat;
    }

    _loadChatDetailsAndMessages();
  }

  Future<void> _loadUserRole() async {
    if (_currentUserId != null) {
      final Map<String, dynamic>? response = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', _currentUserId!)
          .maybeSingle();
      setState(() {
        _currentUserRole = response?['role'] as String?;
      });
    }
  }

  Future<void> _loadChatDetailsAndMessages() async {
    if (_currentChat == null) {
      try {
        final chatData = await _supabase
            .from('support_chats')
            .select()
            .eq('id', widget.chatId)
            .single();
        setState(() {
          _currentChat = SupportChat.fromMap(chatData);
        });
      } catch (e) {
        print('Error loading chat details: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading chat: $e')),
          );
          context.pop();
        }
        return;
      }
    }

    _messagesStream = _chatService.getMessagesForChat(widget.chatId);

    _messagesStream!.listen((messages) {
      setState(() {
        _messages = messages;
      });
      _scrollToBottom();
    });

    if (_currentUserId != null) {
      _chatService.markMessagesAsRead(widget.chatId, _currentUserId!);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final String messageText = _messageController.text.trim();
    _messageController.clear();

    if (_currentUserId == null || _currentUserRole == null) {
      print('User not logged in or role not determined. Cannot send message.');
      return;
    }

    final newMessage = SupportMessage(
      id: const Uuid().v4(),
      chatId: widget.chatId,
      senderId: _currentUserId, // It's nullable in your model
      senderRole: _currentUserRole!, // Use the determined role
      content: messageText, // Use 'content' as per your model
      createdAt: DateTime.now(), // Use 'createdAt' as per your model
      messageType: 'chat', // Default message type for client chat
    );

    try {
      await _chatService.sendMessage(newMessage);
    } catch (e) {
      print('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
      _messageController.text = messageText; // Restore message if failed
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = Supabase.instance.client.auth.currentUser?.id;

    // Use your SupportChat properties here
    // _currentChat?.type (derived or from DB), _currentChat?.adminName
    final bool isAdminChat = _currentChat?.type == 'admin_chat';
    final String chatTitle = _currentChat?.subject ?? _currentChat?.clientDisplayName ?? 'Loading Chat...';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          chatTitle, // Use subject or clientDisplayName for title
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: Text('No messages yet. Start the conversation!'))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      // Determine if the message was sent by the current user based on senderId
                      final bool isMe = message.senderId == currentUserId;

                      // Determine if it's the last message from this sender
                      final bool isLastMessageOfSender = (index == _messages.length - 1) ||
                          (_messages[index + 1].senderId != message.senderId);

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.only(
                            top: isLastMessageOfSender ? 8.0 : 4.0,
                            bottom: 4.0,
                            left: isMe ? 80.0 : 8.0,
                            right: isMe ? 8.0 : 80.0,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                          decoration: BoxDecoration(
                            color: isMe ? Theme.of(context).colorScheme.primary.withOpacity(0.9) : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Column(
                            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              // Display sender role/name if not 'me' and relevant (e.g., admin or assistant)
                              if (!isMe && message.senderRole != 'client') // Show sender role/name if it's not the client (i.e., admin or assistant)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Text(
                                    message.senderRole == 'admin'
                                        ? (_currentChat?.adminName ?? 'Admin')
                                        : (message.senderRole == 'assistant' ? 'PawPal Assistant' : 'Unknown'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isMe ? Colors.white70 : Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              Text(
                                message.content, // Use 'content' from your SupportMessage
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                DateFormat('MMM dd, hh:mm a').format(message.createdAt.toLocal()), // Use 'createdAt' from your SupportMessage
                                style: TextStyle(
                                  color: isMe ? Colors.white70 : Colors.black54,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8.0),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}