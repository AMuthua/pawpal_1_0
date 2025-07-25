// lib/features/admin/admin_support_chat_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:pawpal/services/support_chat_service.dart';
import 'package:pawpal/models/support_chat.dart';

class AdminSupportChatScreen extends StatefulWidget {
  const AdminSupportChatScreen({super.key});

  @override
  State<AdminSupportChatScreen> createState() => _AdminSupportChatScreenState();
}

class _AdminSupportChatScreenState extends State<AdminSupportChatScreen> {
  late final SupportChatService _chatService;

  @override
  void initState() {
    super.initState();
    _chatService = Provider.of<SupportChatService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Support Chats'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<SupportChat>>(
        stream: _chatService.getAllSupportChatsStreamForAdmin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            // Log the error for debugging
            debugPrint('AdminSupportChatScreen StreamBuilder Error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No support chats found.'));
          }

          final chats = snapshot.data!;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              // Determine if the chat has unread messages for the admin
              final bool isUnreadByAdmin = !chat.isReadByAdmin;

              return Card(
                elevation: isUnreadByAdmin ? 4 : 1, // Elevate unread chats
                color: isUnreadByAdmin ? Colors.blue.shade50 : Theme.of(context).cardColor,
                margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    chat.subject ?? 'No Subject',
                    style: TextStyle(
                      fontWeight: isUnreadByAdmin ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Client: ${chat.clientDisplayName}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Status: ${chat.status.toUpperCase()}', // Display chat status
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: chat.status == 'open'
                              ? Colors.green[700]
                              : (chat.status == 'resolved' ? Colors.orange[700] : Colors.grey[700]),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Last Message: ${chat.formattedLastMessageTime}', // Use the formatted getter
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  trailing: isUnreadByAdmin
                      ? const Icon(Icons.mark_email_unread, color: Colors.red, size: 24)
                      : null,
                  onTap: () async {
                    // Mark as read when admin opens the chat
                    await _chatService.markChatAsReadByAdmin(chat.id);
                    if (mounted) {
                      context.push('/admin_dashboard/support_chats/${chat.id}');
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}