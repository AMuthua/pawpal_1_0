// // lib/features/support/client_chat_screen.dart
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:pawpal/services/support_chat_service.dart';
// import 'package:pawpal/models/support_message.dart';
// import 'package:pawpal/models/support_chat.dart'; // Ensure this is imported for _currentChat type

// class ClientChatScreen extends StatefulWidget {
//   final String chatId;

//   const ClientChatScreen({super.key, required this.chatId});

//   @override
//   State<ClientChatScreen> createState() => _ClientChatScreenState();
// }

// class _ClientChatScreenState extends State<ClientChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   late final SupportChatService _chatService;
//   late final String _currentUserId;
//   late final String _currentUserDisplayName;

//   SupportChat? _currentChat;

//   @override
//   void initState() {
//     super.initState();
//     debugPrint('ClientChatScreen initState: Chat ID = ${widget.chatId}');

//     _chatService = Provider.of<SupportChatService>(context, listen: false);

//     final currentUser = Supabase.instance.client.auth.currentUser;
//     if (currentUser == null) {
//       debugPrint('ClientChatScreen initState: User not logged in, navigating home.');
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) context.go('/');
//       });
//       _currentUserId = '';
//       _currentUserDisplayName = 'N/A';
//     } else {
//       _currentUserId = currentUser.id;
//       _currentUserDisplayName = currentUser.userMetadata?['full_name'] as String? ?? currentUser.email ?? 'Anonymous User';
//       debugPrint('ClientChatScreen: Initialized for user: $_currentUserId ($_currentUserDisplayName)');

//       _loadChatDetails();
//       _markChatAsRead();
//     }
//   }

//   Future<void> _loadChatDetails() async {
//     if (_currentUserId.isEmpty) return; 

//     debugPrint('ClientChatScreen: Loading chat details for ID: ${widget.chatId}');
//     try {
//       final chat = await _chatService.getSupportChatById(widget.chatId);
//       if (mounted) {
//         setState(() {
//           _currentChat = chat;
//         });
//         if (chat.id.isEmpty) {
//           debugPrint('ClientChatScreen: Chat details for ID ${widget.chatId} not found. Navigating back.');
//           if (mounted) context.pop();
//         } else {
//           debugPrint('ClientChatScreen: Chat details loaded successfully: ${chat.subject}');
//         }
//       }
//     } catch (e) {
//       debugPrint('ClientChatScreen: Error loading chat details: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load chat details: $e')),
//         );
//         context.pop();
//       }
//     }
//   }

//   Future<void> _markChatAsRead() async {
//     if (_currentUserId.isNotEmpty) {
//       debugPrint('ClientChatScreen: Marking chat ${widget.chatId} as read by client.');
//       try {
//         await _chatService.markChatAsReadByClient(widget.chatId);
//       } catch (e) {
//         debugPrint('ClientChatScreen: Error marking chat as read: $e');
//       }
//     }
//   }

//   Future<void> _sendMessage() async {
//     if (_messageController.text.trim().isEmpty) return;

//     final messageContent = _messageController.text.trim();
//     _messageController.clear();

//     if (_currentUserId.isEmpty) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Error: User not logged in. Cannot send message.')),
//         );
//       }
//       return;
//     }

//     try {
//       await _chatService.addMessageToChat(
//         chatId: widget.chatId,
//         senderId: _currentUserId,
//         senderDisplayName: _currentUserDisplayName,
//         content: messageContent,
//         isClient: true,
//         senderRole: 'client',
//       );
//       debugPrint('ClientChatScreen: Message sent successfully.');
//     } catch (e) {
//       debugPrint('ClientChatScreen: Failed to send message: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to send message: $e')),
//         );
//       }
//     }
//   }

//   Future<void> _showStatusChangeDialog() async {
//     final newStatus = await showDialog<String>(
//       context: context,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           title: const Text('Change Chat Status'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // ListTile(
//               //   title: const Text('Open'),
//               //   onTap: () => Navigator.of(dialogContext).pop('open'),
//               // ),
//               ListTile(
//                 title: const Text('Resolved'),
//                 onTap: () => Navigator.of(dialogContext).pop('resolved'),
//               ),
//               // ListTile(
//               //   title: const Text('Closed'),
//               //   onTap: () => Navigator.of(dialogContext).pop('closed'),
//               // ),
//             ],
//           ),
//         );
//       },
//     );

//     if (newStatus != null && newStatus != _currentChat?.status) {
//       try {
//         debugPrint('ClientChatScreen: Attempting to update chat status to $newStatus');
//         await _chatService.updateChatStatus(widget.chatId, newStatus);
//         await _loadChatDetails();
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Chat status updated to: $newStatus')),
//           );
//         }
//       } catch (e) {
//         debugPrint('ClientChatScreen: Failed to update status: $e');
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to update status: $e')),
//           );
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_currentUserId.isEmpty) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Support Chat')),
//         body: const Center(child: Text('Please log in to view chats.')),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Support Chat: ${_currentChat?.subject ?? "Loading..."}'),
//             if (_currentChat != null)
//               Text(
//                 'Status: ${_currentChat!.status.toUpperCase()}',
//                 style: Theme.of(context).textTheme.bodySmall,
//               ),
//           ],
//         ),
//         actions: [
//           if (_currentChat != null && _currentChat!.status != 'closed') 
//             IconButton(
//               icon: const Icon(Icons.edit),
//               tooltip: 'Change Status',
//               onPressed: _showStatusChangeDialog,
//             ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<List<SupportMessage>>(
//               stream: _chatService.getMessagesForChatStream(widget.chatId),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (snapshot.hasError) {
//                   debugPrint('ClientChatScreen StreamBuilder Error: ${snapshot.error}');
//                   return Center(child: Text('Error loading messages: ${snapshot.error}'));
//                 }
//                 if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   debugPrint('ClientChatScreen StreamBuilder: No messages found.');
//                   return const Center(child: Text('No messages yet.'));
//                 }

//                 final messages = snapshot.data!;
//                 final displayedMessages = messages.reversed.toList(); 

//                 return ListView.builder(
//                     reverse: true,
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     itemCount: messages.length,
//                     itemBuilder: (context, index) {
//                     final message = messages[index];
//                     // FIX: Use null-aware operator for message.isClient
//                     final isMe = message.isClient ?? false; // Default to false if isClient is null

//                     return Align(
//                       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//                       child: Container(
//                         margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
//                         padding: const EdgeInsets.all(12.0),
//                         decoration: BoxDecoration(
//                           color: isMe ? Colors.blue[100] : Colors.grey[300],
//                           borderRadius: BorderRadius.circular(8.0),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               isMe ? 'You' : message.senderDisplayName ?? 'Support Agent',
//                               style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black), // Force black for debugging
//                             ),
//                             const SizedBox(height: 4.0),
//                             Text(
//                               message.content ?? 'Message content missing',
//                               style: const TextStyle(fontSize: 16.0, color: Colors.black87), // Force black for debugging
//                             ),
//                             const SizedBox(height: 4.0),
//                             Text(
//                               message.formattedCreatedAt,
//                               style: const TextStyle(fontSize: 12.0, color: Colors.black54),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           if (_currentChat != null && _currentChat!.status != 'closed')
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _messageController,
//                       decoration: InputDecoration(
//                         hintText: 'Type your message...',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(20.0),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                       ),
//                       onSubmitted: (_) => _sendMessage(),
//                     ),
//                   ),
//                   const SizedBox(width: 8.0),
//                   FloatingActionButton(
//                     onPressed: _sendMessage,
//                     mini: true,
//                     child: const Icon(Icons.send),
//                   ),
//                 ],
//               ),
//             )
//           else if (_currentChat != null)
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 'This chat is ${_currentChat!.status}. You can no longer send messages.',
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _messageController.dispose();
//     super.dispose();
//   }
// }




// lib/features/support/client_chat_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  late final SupportChatService _chatService;
  late final String _currentUserId;
  late final String _currentUserDisplayName;

  SupportChat? _currentChat;

  @override
  void initState() {
    super.initState();
    debugPrint('ClientChatScreen initState: Chat ID = ${widget.chatId}');

    _chatService = Provider.of<SupportChatService>(context, listen: false);

    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      debugPrint('ClientChatScreen initState: User not logged in, navigating home.');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/');
      });
      _currentUserId = '';
      _currentUserDisplayName = 'N/A';
    } else {
      _currentUserId = currentUser.id;
      _currentUserDisplayName = currentUser.userMetadata?['full_name'] as String? ?? currentUser.email ?? 'Anonymous User';
      debugPrint('ClientChatScreen: Initialized for user: $_currentUserId ($_currentUserDisplayName)');

      _loadChatDetails();
      _markChatAsRead();
    }
  }

  Future<void> _loadChatDetails() async {
    if (_currentUserId.isEmpty) return; 

    debugPrint('ClientChatScreen: Loading chat details for ID: ${widget.chatId}');
    try {
      final chat = await _chatService.getSupportChatById(widget.chatId);
      if (mounted) {
        setState(() {
          _currentChat = chat;
        });
        if (chat.id.isEmpty) {
          debugPrint('ClientChatScreen: Chat details for ID ${widget.chatId} not found. Navigating back.');
          if (mounted) context.pop();
        } else {
          debugPrint('ClientChatScreen: Chat details loaded successfully: ${chat.subject}');
        }
      }
    } catch (e) {
      debugPrint('ClientChatScreen: Error loading chat details: $e');
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
      debugPrint('ClientChatScreen: Marking chat ${widget.chatId} as read by client.');
      try {
        await _chatService.markChatAsReadByClient(widget.chatId);
      } catch (e) {
        debugPrint('ClientChatScreen: Error marking chat as read: $e');
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageContent = _messageController.text.trim();
    _messageController.clear();

    if (_currentUserId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in. Cannot send message.')),
        );
      }
      return;
    }

    try {
      await _chatService.addMessageToChat(
        chatId: widget.chatId,
        senderId: _currentUserId,
        senderDisplayName: _currentUserDisplayName,
        content: messageContent,
        isClient: true,
        senderRole: 'client',
      );
      debugPrint('ClientChatScreen: Message sent successfully.');
    } catch (e) {
      debugPrint('ClientChatScreen: Failed to send message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }

  // --- NEW: Method to handle single message deletion ---
  Future<void> _deleteMessage(String messageId) async {
    try {
      await _chatService.deleteMessage(messageId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message deleted successfully.')),
        );
      }
    } catch (e) {
      debugPrint('Error deleting message: $e');
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
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Change Chat Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Resolved'),
                onTap: () => Navigator.of(dialogContext).pop('resolved'),
              ),
            ],
          ),
        );
      },
    );

    if (newStatus != null && newStatus != _currentChat?.status) {
      try {
        debugPrint('ClientChatScreen: Attempting to update chat status to $newStatus');
        await _chatService.updateChatStatus(widget.chatId, newStatus);
        await _loadChatDetails();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Chat status updated to: $newStatus')),
          );
        }
      } catch (e) {
        debugPrint('ClientChatScreen: Failed to update status: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update status: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Support Chat')),
        body: const Center(child: Text('Please log in to view chats.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Support Chat: ${_currentChat?.subject ?? "Loading..."}'),
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
              tooltip: 'Change Status',
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
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  debugPrint('ClientChatScreen StreamBuilder Error: ${snapshot.error}');
                  return Center(child: Text('Error loading messages: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  debugPrint('ClientChatScreen StreamBuilder: No messages found.');
                  return const Center(child: Text('No messages yet.'));
                }

                final messages = snapshot.data!;
                
                return ListView.builder(
                  // FIX: Use 'reverse: true' and remove `.reversed.toList()`
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.isClient ?? false;

                    // --- NEW: Wrap with a GestureDetector for long-press deletion ---
                    return GestureDetector(
                      onLongPress: () {
                        // Show a confirmation dialog before deleting
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Delete Message'),
                              content: const Text('Are you sure you want to delete this message?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _deleteMessage(message.id);
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue[100] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(
                                isMe ? 'You' : message.senderDisplayName ?? 'Support Agent',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                message.content ?? 'Message content missing',
                                style: const TextStyle(fontSize: 16.0, color: Colors.black87),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                message.formattedCreatedAt,
                                style: const TextStyle(fontSize: 12.0, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_currentChat != null && _currentChat!.status != 'closed')
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
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  FloatingActionButton(
                    onPressed: _sendMessage,
                    mini: true,
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            )
          else if (_currentChat != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'This chat is ${_currentChat!.status}. You can no longer send messages.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}