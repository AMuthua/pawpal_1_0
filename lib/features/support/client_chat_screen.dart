// lib/features/support/client_chat_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/scheduler.dart';

import 'package:pawpal/services/support_chat_service.dart';
import 'package:pawpal/models/support_message.dart';
import 'package:pawpal/models/support_chat.dart';

class ClientChatScreen extends StatefulWidget {
  final String chatId;
  const ClientChatScreen({super.key, required this.chatId});

  @override
  State<ClientChatScreen> createState() => _ClientChatScreenState();
}

class _ClientChatScreenState extends State<ClientChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final SupportChatService _chatService;
  late final String _currentUserId;
  late final String _currentUserDisplayName;

  SupportChat? _currentChat;

  @override
  void initState() {
    super.initState();
    _chatService = Provider.of<SupportChatService>(context, listen: false);

    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.push('/');
      });
      _currentUserId = '';
      _currentUserDisplayName = 'N/A';
    } else {
      _currentUserId = currentUser.id;
      _currentUserDisplayName =
          currentUser.userMetadata?['full_name'] as String? ??
          currentUser.email ??
          'Anonymous User';

      _loadChatDetails();
      _markChatAsRead();
    }
  }

  Future<void> _loadChatDetails() async {
    try {
      final chat = await _chatService.getSupportChatById(widget.chatId);
      if (mounted) setState(() => _currentChat = chat);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load chat details: $e')),
        );
        context.pop();
      }
    }
  }

  Future<void> _markChatAsRead() async {
    if (_currentUserId.isNotEmpty) {
      try {
        await _chatService.markChatAsReadByClient(widget.chatId);
      } catch (_) {}
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    final msg = _messageController.text.trim();
    _messageController.clear();

    try {
      await _chatService.addMessageToChat(
        chatId: widget.chatId,
        senderId: _currentUserId,
        senderDisplayName: _currentUserDisplayName,
        content: msg,
        isClient: true,
        senderRole: 'client',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    try {
      await _chatService.deleteMessage(messageId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message deleted successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete message: $e')),
        );
      }
    }
  }

  Future<void> _showStatusChangeDialog() async {
    final newStatus = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Chat Status'),
        content: ListTile(
          title: const Text('Resolved'),
          onTap: () => Navigator.pop(context, 'resolved'),
        ),
      ),
    );

    if (newStatus != null && newStatus != _currentChat?.status) {
      try {
        await _chatService.updateChatStatus(widget.chatId, newStatus);
        await _loadChatDetails();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Chat status updated to: $newStatus')),
          );
        }
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view chats.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Support: ${_currentChat?.subject ?? "Loading..."}'),
            if (_currentChat != null)
              Text(
                'Status: ${_currentChat!.status.toUpperCase()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        actions: [
          if (_currentChat != null && _currentChat!.status != 'closed')
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _showStatusChangeDialog,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<SupportMessage>>(
              stream: _chatService.getMessagesForChatStream(widget.chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!;
                messages.sort((a, b) =>
                    (a.createdAt ?? DateTime(0)).compareTo(b.createdAt ?? DateTime(0)));

                SchedulerBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.minScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.isClient ?? false;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: GestureDetector(
                        onLongPress: () {
                          if (isMe) {
                            _deleteMessage(message.id);
                          }
                        },
                        child: _buildMessageBubble(message, isMe, context),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_currentChat != null && _currentChat!.status != 'closed')
            _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(SupportMessage message, bool isMe, BuildContext ctx) {
    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe
            ? Theme.of(ctx).colorScheme.primary.withOpacity(0.9)
            : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            message.senderDisplayName ?? (isMe ? 'You' : 'Support'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isMe ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message.content ?? '',
            style: TextStyle(color: isMe ? Colors.white : Colors.black, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            message.formattedCreatedAt,
            style: TextStyle(
              fontSize: 12,
              color: isMe ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _sendMessage,
            mini: true,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}




// New updates test 9. 