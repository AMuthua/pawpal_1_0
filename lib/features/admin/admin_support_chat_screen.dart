// // lib/features/admin/admin_support_chat_screen.dart
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';

// import 'package:pawpal/services/support_chat_service.dart';
// import 'package:pawpal/models/support_chat.dart';

// class AdminSupportChatScreen extends StatefulWidget {
//   const AdminSupportChatScreen({super.key});

//   @override
//   State<AdminSupportChatScreen> createState() => _AdminSupportChatScreenState();
// }

// class _AdminSupportChatScreenState extends State<AdminSupportChatScreen> {
//   late final SupportChatService _chatService;

//   @override
//   void initState() {
//     super.initState();
//     _chatService = Provider.of<SupportChatService>(context, listen: false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Admin Support Chats'),
//         centerTitle: true,
//       ),
//       body: StreamBuilder<List<SupportChat>>(
//         stream: _chatService.getAllSupportChatsStreamForAdmin(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             // Log the error for debugging
//             debugPrint('AdminSupportChatScreen StreamBuilder Error: ${snapshot.error}');
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No support chats found.'));
//           }

//           final chats = snapshot.data!;

//           return ListView.builder(
//             itemCount: chats.length,
//             itemBuilder: (context, index) {
//               final chat = chats[index];
//               // Determine if the chat has unread messages for the admin
//               final bool isUnreadByAdmin = !chat.isReadByAdmin;

//               return Card(
//                 elevation: isUnreadByAdmin ? 4 : 1, // Elevate unread chats
//                 color: isUnreadByAdmin ? Colors.blue.shade50 : Theme.of(context).cardColor,
//                 margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: ListTile(
//                   contentPadding: const EdgeInsets.all(16),
//                   title: Text(
//                     chat.subject ?? 'No Subject',
//                     style: TextStyle(
//                       fontWeight: isUnreadByAdmin ? FontWeight.bold : FontWeight.normal,
//                       fontSize: 16,
//                       color: Theme.of(context).colorScheme.onSurface,
//                     ),
//                   ),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 4),
//                       Text(
//                         'Client: ${chat.clientDisplayName}',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Theme.of(context).colorScheme.onSurfaceVariant,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         'Status: ${chat.status.toUpperCase()}', // Display chat status
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                           color: chat.status == 'open'
//                               ? Colors.green[700]
//                               : (chat.status == 'resolved' ? Colors.orange[700] : Colors.grey[700]),
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         'Last Message: ${chat.formattedLastMessageTime}', // Use the formatted getter
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8),
//                         ),
//                       ),
//                     ],
//                   ),
//                   trailing: isUnreadByAdmin
//                       ? const Icon(Icons.mark_email_unread, color: Colors.red, size: 24)
//                       : null,
//                   onTap: () async {
//                     // Mark as read when admin opens the chat
//                     await _chatService.markChatAsReadByAdmin(chat.id);
//                     if (mounted) {
//                       context.push('/admin_dashboard/support_chats/${chat.id}');
//                     }
//                   },
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }





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
  String _selectedStatusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _chatService = Provider.of<SupportChatService>(context, listen: false);
  }

  Future<void> _deleteChat(String chatId) async {
    try {
      await _chatService.deleteSupportChat(chatId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat and all its messages deleted successfully.')),
        );
      }
    } catch (e) {
      debugPrint('Error deleting chat: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete chat: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Support Chats'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: SegmentedButton<String>(
              segments: const <ButtonSegment<String>>[
                ButtonSegment<String>(value: 'all', label: Text('All')),
                ButtonSegment<String>(value: 'open', label: Text('Open')),
                ButtonSegment<String>(value: 'resolved', label: Text('Resolved')),
                ButtonSegment<String>(value: 'closed', label: Text('Closed')),
              ],
              selected: <String>{_selectedStatusFilter},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedStatusFilter = newSelection.first;
                });
              },
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<SupportChat>>(
        stream: _chatService.getAllSupportChatsStreamForAdmin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            debugPrint('AdminSupportChatScreen StreamBuilder Error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No support chats found.'));
          }

          final chats = snapshot.data!;
          final filteredChats = chats.where((chat) {
            if (_selectedStatusFilter == 'all') {
              return true;
            }
            return chat.status == _selectedStatusFilter;
          }).toList();

          if (filteredChats.isEmpty) {
            return const Center(child: Text('No chats found for this status.'));
          }

          return ListView.builder(
            itemCount: filteredChats.length,
            itemBuilder: (context, index) {
              final chat = filteredChats[index];
              final bool isUnreadByAdmin = !chat.isReadByAdmin;

              return Dismissible(
                key: Key(chat.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Delete Chat"),
                        content: const Text("Are you sure you want to delete this chat? This action is permanent."),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              _deleteChat(chat.id);
                              Navigator.of(context).pop(true);
                            },
                            child: const Text("Delete"),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Card(
                  elevation: isUnreadByAdmin ? 4 : 1,
                  color: isUnreadByAdmin ? Colors.blue.shade50 : Theme.of(context).cardColor,
                  margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      chat.subject,
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
                          'Client: ${chat.clientDisplayName ?? 'No Name'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Status: ${chat.status.toUpperCase()}',
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
                          'Last Message: ${chat.formattedLastMessageTime}',
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
                      await _chatService.markChatAsReadByAdmin(chat.id);
                      if (mounted) {
                        context.push('/admin_dashboard/support_chats/${chat.id}');
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}