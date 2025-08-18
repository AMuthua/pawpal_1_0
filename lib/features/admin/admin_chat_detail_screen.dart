// // lib/features/admin/admin_chat_detail_screen.dart
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';

// import 'package:pawpal/services/support_chat_service.dart';
// import 'package:pawpal/models/support_chat.dart';
// import 'package:pawpal/models/support_message.dart'; // Ensure this is imported

// class AdminChatDetailScreen extends StatefulWidget {
//   final String chatId;
//   const AdminChatDetailScreen({super.key, required this.chatId});

//   @override
//   State<AdminChatDetailScreen> createState() => _AdminChatDetailScreenState();
// }

// class _AdminChatDetailScreenState extends State<AdminChatDetailScreen> {
//   late final SupportChatService _chatService;
//   final TextEditingController _messageController = TextEditingController();
//   late final String _adminId;
//   late final String _adminDisplayName;

//   SupportChat? _currentChat; // To hold the current chat object

//   @override
//   void initState() {
//     super.initState();
//     _chatService = Provider.of<SupportChatService>(context, listen: false);
//     final currentUser = Supabase.instance.client.auth.currentUser;
//     _adminId = currentUser?.id ?? '';
//     _adminDisplayName = currentUser?.email ?? 'Admin User'; // Default for admin

//     // Fetch initial chat details to display
//     _fetchChatDetails();
//   }

//   Future<void> _fetchChatDetails() async {
//     try {
//       final chat = await _chatService.getSupportChatById(widget.chatId);
//       if (mounted) {
//         setState(() {
//           _currentChat = chat;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error fetching chat details: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load chat details: $e')),
//         );
//       }
//     }
//   }

//   Future<void> _sendMessage() async {
//     if (_messageController.text.trim().isEmpty) return;

//     final content = _messageController.text.trim();
//     _messageController.clear();

//     try {
//       await _chatService.addMessageToChat(
//         chatId: widget.chatId,
//         senderId: _adminId,
//         senderDisplayName: _adminDisplayName,
//         content: content,
//         isClient: false, // This message is from admin
//         senderRole: 'client',
//       );
//       // Mark chat as read by admin after sending a message
//       await _chatService.markChatAsReadByAdmin(widget.chatId);
//     } catch (e) {
//       debugPrint('Error sending message: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to send message: $e')),
//         );
//       }
//     }
//   }

//   Future<void> _updateChatStatus(String status) async {
//     try {
//       await _chatService.updateChatStatus(widget.chatId, status);
//       // Refresh chat details to reflect the new status
//       await _fetchChatDetails();
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Chat status updated to ${status.toUpperCase()}')),
//         );
//       }
//     } catch (e) {
//       debugPrint('Error updating chat status: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to update chat status: $e')),
//         );
//       }
//     }
//   }

//   void _showStatusChangeDialog() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Change Chat Status'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 title: const Text('Open'),
//                 onTap: () {
//                   _updateChatStatus('open');
//                   Navigator.of(context).pop();
//                 },
//               ),
//               ListTile(
//                 title: const Text('Resolved'),
//                 onTap: () {
//                   _updateChatStatus('resolved');
//                   Navigator.of(context).pop();
//                 },
//               ),
//               ListTile(
//                 title: const Text('Closed'),
//                 onTap: () {
//                   _updateChatStatus('closed');
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancel'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Handle nullable clientDisplayName from _currentChat
//             Text('Chat with ${_currentChat?.clientDisplayName ?? "Loading..."}'),
//             if (_currentChat != null)
//               Text(
//                 'Status: ${_currentChat!.status.toUpperCase()}',
//                 style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
//               ),
//           ],
//         ),
//         actions: [
//           if (_currentChat != null) // Only show options if chat is loaded
//             PopupMenuButton<String>(
//               onSelected: (String result) {
//                 if (result == 'change_status') {
//                   _showStatusChangeDialog();
//                 }
//               },
//               itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//                 PopupMenuItem<String>(
//                   value: 'change_status',
//                   child: Text('Change Chat Status (${_currentChat!.status.toUpperCase()})'),
//                 ),
//               ],
//               icon: const Icon(Icons.more_vert), // Three dots icon
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
//                   debugPrint('AdminChatDetailScreen StreamBuilder Error: ${snapshot.error}');
//                   return Center(child: Text('Error loading messages: ${snapshot.error}'));
//                 }
//                 if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return const Center(child: Text('No messages in this chat yet.'));
//                 }

//                 final messages = snapshot.data!;

//                 return ListView.builder(
//                   reverse: true, // Show latest messages at the bottom
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     final message = messages[index];
//                     final bool isMe = message.senderId == _adminId;

//                     return Align(
//                       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//                       child: Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                         decoration: BoxDecoration(
//                           color: isMe ? Theme.of(context).colorScheme.primary.withOpacity(0.9) : Colors.grey[300],
//                           borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(isMe ? 12 : 0),
//                             topRight: Radius.circular(isMe ? 0 : 12),
//                             bottomLeft: const Radius.circular(12),
//                             bottomRight: const Radius.circular(12),
//                           ),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               // Use null-coalescing operator to provide a fallback if null
//                               message.senderDisplayName ?? 'Unknown User',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: isMe ? Colors.white : Colors.black87,
//                                 fontSize: 12,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               // Use null-coalescing operator to provide a fallback if null
//                               message.content ?? 'Message content missing',
//                               style: TextStyle(
//                                 color: isMe ? Colors.white : Colors.black87,
//                                 fontSize: 16,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               // Use the formattedCreatedAt getter which already handles null internally
//                               message.formattedCreatedAt,
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 color: isMe ? Colors.white70 : Colors.black54,
//                               ),
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
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: InputDecoration(
//                       hintText: 'Type a message...',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(25.0),
//                         borderSide: BorderSide.none,
//                       ),
//                       filled: true,
//                       // ✅ NEW: Conditional fillColor for dark mode support
//                       fillColor: Theme.of(context).brightness == Brightness.dark
//                           ? Colors.grey.shade800 // Darker color for dark mode
//                           : Colors.grey.shade200, // Original color for light mode
//                       contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                     ),
//                     // ✅ NEW: Ensure the text color is always readable on the background
//                     style: TextStyle(
//                       color: Theme.of(context).brightness == Brightness.dark
//                           ? Colors.white // White text in dark mode
//                           : Colors.black, // Black text in light mode
//                     ),
//                     minLines: 1,
//                     maxLines: 5,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 FloatingActionButton(
//                   onPressed: _sendMessage,
//                   mini: true,
//                   heroTag: 'sendMessageAdmin', // Unique HeroTag for FloatingActionButton
//                   backgroundColor: Theme.of(context).colorScheme.primary,
//                   child: const Icon(Icons.send, color: Colors.white),
//                 ),
//               ],
//             ),
//           ),
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





// lib/features/admin/admin_chat_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/scheduler.dart'; // Import this for addPostFrameCallback

import 'package:pawpal/services/support_chat_service.dart';
import 'package:pawpal/models/support_chat.dart';
import 'package:pawpal/models/support_message.dart'; 

class AdminChatDetailScreen extends StatefulWidget {
  final String chatId;
  const AdminChatDetailScreen({super.key, required this.chatId});

  @override
  State<AdminChatDetailScreen> createState() => _AdminChatDetailScreenState();
}

class _AdminChatDetailScreenState extends State<AdminChatDetailScreen> {
  late final SupportChatService _chatService;
  final TextEditingController _messageController = TextEditingController();
  late final String _adminId;
  late final String _adminDisplayName;

  // ✅ NEW: Add a ScrollController for the message list
  final ScrollController _scrollController = ScrollController();

  SupportChat? _currentChat;

  @override
  void initState() {
    super.initState();
    _chatService = Provider.of<SupportChatService>(context, listen: false);
    final currentUser = Supabase.instance.client.auth.currentUser;
    _adminId = currentUser?.id ?? '';
    _adminDisplayName = currentUser?.email ?? 'Admin User';

    _fetchChatDetails();
  }

  Future<void> _fetchChatDetails() async {
    try {
      final chat = await _chatService.getSupportChatById(widget.chatId);
      if (mounted) {
        setState(() {
          _currentChat = chat;
        });
      }
    } catch (e) {
      debugPrint('Error fetching chat details: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load chat details: $e')),
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final content = _messageController.text.trim();
    _messageController.clear();

    try {
      await _chatService.addMessageToChat(
        chatId: widget.chatId,
        senderId: _adminId,
        senderDisplayName: _adminDisplayName,
        content: content,
        isClient: false,
        senderRole: 'admin', // Make sure this is 'admin' to differentiate
      );
      await _chatService.markChatAsReadByClient(widget.chatId); // Admin sends, client reads
      
      // No need to manually scroll here, the StreamBuilder handles it
    } catch (e) {
      debugPrint('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }

  Future<void> _updateChatStatus(String status) async {
    try {
      await _chatService.updateChatStatus(widget.chatId, status);
      await _fetchChatDetails();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chat status updated to ${status.toUpperCase()}')),
        );
      }
    } catch (e) {
      debugPrint('Error updating chat status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update chat status: $e')),
        );
      }
    }
  }

  void _showStatusChangeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Chat Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Open'),
                onTap: () {
                  _updateChatStatus('open');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Resolved'),
                onTap: () {
                  _updateChatStatus('resolved');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Closed'),
                onTap: () {
                  _updateChatStatus('closed');
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chat with ${_currentChat?.clientDisplayName ?? "Loading..."}'),
            if (_currentChat != null)
              Text(
                'Status: ${_currentChat!.status.toUpperCase()}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
          ],
        ),
        actions: [
          if (_currentChat != null)
            PopupMenuButton<String>(
              onSelected: (String result) {
                if (result == 'change_status') {
                  _showStatusChangeDialog();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'change_status',
                  child: Text('Change Chat Status (${_currentChat!.status.toUpperCase()})'),
                ),
              ],
              icon: const Icon(Icons.more_vert),
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
                  debugPrint('AdminChatDetailScreen StreamBuilder Error: ${snapshot.error}');
                  return Center(child: Text('Error loading messages: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No messages in this chat yet.'));
                }

                final messages = snapshot.data!;

                // ✅ NEW: Trigger auto-scroll when new messages arrive
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.minScrollExtent, // minScrollExtent is the bottom because `reverse` is true
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController, // ✅ Attach the controller
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final bool isMe = message.senderId == _adminId;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isMe ? Theme.of(context).colorScheme.primary.withOpacity(0.9) : Colors.grey[300],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(isMe ? 12 : 0),
                            topRight: Radius.circular(isMe ? 0 : 12),
                            bottomLeft: const Radius.circular(12),
                            bottomRight: const Radius.circular(12),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.senderDisplayName ?? 'Unknown User',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isMe ? Colors.white : Colors.black87,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              message.content ?? 'Message content missing',
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              message.formattedCreatedAt,
                              style: TextStyle(
                                fontSize: 10,
                                color: isMe ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                    minLines: 1,
                    maxLines: 5,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  mini: true,
                  heroTag: 'sendMessageAdmin',
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose(); // ✅ Don't forget to dispose the controller
    super.dispose();
  }
}