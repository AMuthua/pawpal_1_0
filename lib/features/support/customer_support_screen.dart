// // lib/features/support/customer_support_screen.dart
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:intl/intl.dart';

// import 'package:pawpal/services/support_chat_service.dart';
// import 'package:pawpal/models/support_chat.dart'; // Ensure this is imported

// // It's generally good practice to import the specific screen if you're navigating to it
// // but go_router typically handles navigation via paths, so this might not be strictly necessary
// // if client_chat_screen.dart is only accessed via GoRouter path.
// // import 'package:pawpal/features/support/client_chat_screen.dart';

// class CustomerSupportScreen extends StatefulWidget {
//   const CustomerSupportScreen({super.key});

//   @override
//   State<CustomerSupportScreen> createState() => _CustomerSupportScreenState();
// }

// class _CustomerSupportScreenState extends State<CustomerSupportScreen> {
//   final TextEditingController _subjectController = TextEditingController();
//   final TextEditingController _messageController = TextEditingController();
  
//   // Use 'late final' because it's initialized in initState, which is guaranteed to run
//   late final SupportChatService _chatService;
//   late final String _currentUserId;
//   late final String _currentUserDisplayName;
  

//   @override
//   void initState() {
//     super.initState();
//     // Initialize _chatService using Provider
//     _chatService = Provider.of<SupportChatService>(context, listen: false);
    
//     // Get current user info from Supabase
//     final currentUser = Supabase.instance.client.auth.currentUser;
//     _currentUserId = currentUser?.id ?? '';
//     // Fetch display name from user_metadata or profiles table if available, otherwise fallback to email
//     _currentUserDisplayName = currentUser?.userMetadata?['full_name'] as String? ?? currentUser?.email ?? 'Anonymous User';
    
//     debugPrint('CustomerSupportScreen: Initialized for user: $_currentUserId');
//   }

//   // This method creates a new chat and sends the initial message (subject)
//   Future<void> _createChat() async {
//     // We'll use the messageController for the subject of the chat if subjectController is empty
//     final String chatSubject = _subjectController.text.trim().isNotEmpty 
//                                ? _subjectController.text.trim() 
//                                : _messageController.text.trim().substring(0, _messageController.text.trim().length > 50 ? 50 : _messageController.text.trim().length); // Use start of message as subject

//     if (_messageController.text.trim().isEmpty) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please enter your first message to start the chat.')),
//         );
//       }
//       return;
//     }

//     if (_currentUserId.isEmpty) { // Check if user ID is genuinely empty
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('User information not available. Please log in again.')),
//         );
//       }
//       return;
//     }

//     try {
//       // Create the chat with the initial subject/message
//       final SupportChat newChat = await _chatService.createSupportChat(
//         clientId: _currentUserId,
//         clientDisplayName: _currentUserDisplayName,
//         subject: chatSubject.isNotEmpty ? chatSubject : 'New Chat', // Fallback subject
//       );

//       // Add the initial message to the newly created chat
//       await _chatService.addMessageToChat(
//         chatId: newChat.id,
//         senderId: _currentUserId,
//         senderDisplayName: _currentUserDisplayName,
//         content: _messageController.text.trim(),
//         isClient: true, // This message is from the client
//         senderRole: 'client',
//       );

//       // If successful, navigate to the new chat's detail screen
//       if (mounted) {
//         context.push('/support/chat/${newChat.id}'); // Navigate to the specific chat screen
//         _subjectController.clear();
//         _messageController.clear();
//       }
//     } catch (e) {
//       debugPrint('Error creating chat or sending initial message: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to create chat: $e')),
//         );
//       }
//     }
//   }


//   void _showNewChatDialog() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Start New Support Chat'),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: _subjectController,
//                   decoration: const InputDecoration(labelText: 'Subject (Optional)'),
//                 ),
//                 const SizedBox(height: 10),
//                 TextField(
//                   controller: _messageController,
//                   decoration: const InputDecoration(labelText: 'Your first message'),
//                   maxLines: 3,
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 _subjectController.clear(); // Clear input if cancelled
//                 _messageController.clear();
//               },
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close dialog first
//                 _createChat(); // Call the fixed _createChat method
//               },
//               child: const Text('Start Chat'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_currentUserId.isEmpty) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Support')),
//         body: const Center(child: Text('Please log in to access support.')),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Your Support Chats'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add_comment),
//             tooltip: 'Start New Chat',
//             onPressed: _showNewChatDialog,
//           ),
//         ],
//       ),
//       body: StreamBuilder<List<SupportChat>>(
//         // FIX: Use the correct method name 'getClientSupportChatsStream'
//         stream: _chatService.getClientSupportChatsStream(_currentUserId),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             debugPrint('CustomerSupportScreen StreamBuilder Error: ${snapshot.error}');
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             debugPrint('CustomerSupportScreen StreamBuilder: No chats found for user: $_currentUserId');
//             return const Center(child: Text('You have no support chats. Click + to start one!'));
//           }

//           final chats = snapshot.data!;
//           debugPrint('CustomerSupportScreen StreamBuilder: Found ${chats.length} chats.');

//           return ListView.builder(
//             itemCount: chats.length,
//             itemBuilder: (context, index) {
//               final chat = chats[index];
//               // FIX: Use 'isReadByUser' as defined in the SupportChat model
//               final bool isUnread = !chat.isReadByUser; 

//               debugPrint('Chat ID: ${chat.id}, Subject: ${chat.subject}, Status: ${chat.status}, isUnreadByClient: $isUnread');

//               return Card(
//                 elevation: isUnread ? 4 : 1, // Elevate unread chats
//                 color: isUnread ? Colors.lightBlue.shade50 : Theme.of(context).cardColor,
//                 margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//                 child: ListTile(
//                   // 'subject' in SupportChat is now non-nullable, so no need for ?? 'No Subject'
//                   title: Text(
//                     chat.subject, 
//                     style: TextStyle(
//                       fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
//                     ),
//                   ),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Status: ${chat.status.toUpperCase()}'),
//                       // 'lastMessageAt' in SupportChat is now non-nullable, so no need for !
//                       Text(
//                         'Last Message: ${DateFormat('MMM dd, hh:mm a').format(chat.lastMessageAt)}',
//                         style: Theme.of(context).textTheme.bodySmall,
//                       ),
//                     ],
//                   ),
//                   trailing: isUnread
//                       ? const Icon(Icons.circle, color: Colors.red, size: 12)
//                       : null,
//                   onTap: () {
//                     debugPrint('Tapped on chat ID: ${chat.id}');
//                     // FIX: Ensure your GoRouter path is correct. It should match the one in app_routes.dart
//                     context.push('/support/chat/${chat.id}'); 
//                   },
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _subjectController.dispose();
//     _messageController.dispose();
//     super.dispose();
//   }
// }





// lib/features/support/customer_support_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import 'package:pawpal/services/support_chat_service.dart';
import 'package:pawpal/models/support_chat.dart';

class CustomerSupportScreen extends StatefulWidget {
  const CustomerSupportScreen({super.key});

  @override
  State<CustomerSupportScreen> createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends State<CustomerSupportScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  
  late final SupportChatService _chatService;
  late final String _currentUserId;
  late final String _currentUserDisplayName;
  

  @override
  void initState() {
    super.initState();
    _chatService = Provider.of<SupportChatService>(context, listen: false);
    
    final currentUser = Supabase.instance.client.auth.currentUser;
    _currentUserId = currentUser?.id ?? '';
    _currentUserDisplayName = currentUser?.userMetadata?['full_name'] as String? ?? currentUser?.email ?? 'Anonymous User';
    
    debugPrint('CustomerSupportScreen: Initialized for user: $_currentUserId');
  }

  // This method creates a new chat and sends the initial message (subject)
  Future<void> _createChat() async {
    final String chatSubject = _subjectController.text.trim().isNotEmpty 
                               ? _subjectController.text.trim() 
                               : _messageController.text.trim().substring(0, _messageController.text.trim().length > 50 ? 50 : _messageController.text.trim().length);

    if (_messageController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your first message to start the chat.')),
        );
      }
      return;
    }

    if (_currentUserId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User information not available. Please log in again.')),
        );
      }
      return;
    }

    try {
      final SupportChat newChat = await _chatService.createSupportChat(
        clientId: _currentUserId,
        clientDisplayName: _currentUserDisplayName,
        subject: chatSubject.isNotEmpty ? chatSubject : 'New Chat',
      );

      await _chatService.addMessageToChat(
        chatId: newChat.id,
        senderId: _currentUserId,
        senderDisplayName: _currentUserDisplayName,
        content: _messageController.text.trim(),
        isClient: true,
        senderRole: 'client',
      );

      if (mounted) {
        context.push('/support/chat/${newChat.id}');
        _subjectController.clear();
        _messageController.clear();
      }
    } catch (e) {
      debugPrint('Error creating chat or sending initial message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create chat: $e')),
        );
      }
    }
  }

  // --- NEW: Method to handle chat deletion ---
  Future<void> _deleteChat(String chatId) async {
    try {
      await _chatService.deleteSupportChat(chatId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat deleted successfully.')),
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

  void _showNewChatDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Start New Support Chat'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _subjectController,
                  decoration: const InputDecoration(labelText: 'Subject (Optional)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(labelText: 'Your first message'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _subjectController.clear();
                _messageController.clear();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _createChat();
              },
              child: const Text('Start Chat'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Support')),
        body: const Center(child: Text('Please log in to access support.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Support Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment),
            tooltip: 'Start New Chat',
            onPressed: _showNewChatDialog,
          ),
        ],
      ),
      body: StreamBuilder<List<SupportChat>>(
        stream: _chatService.getClientSupportChatsStream(_currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            debugPrint('CustomerSupportScreen StreamBuilder Error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            debugPrint('CustomerSupportScreen StreamBuilder: No chats found for user: $_currentUserId');
            return const Center(child: Text('You have no support chats. Click + to start one!'));
          }

          final chats = snapshot.data!;
          debugPrint('CustomerSupportScreen StreamBuilder: Found ${chats.length} chats.');

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final bool isUnread = !chat.isReadByUser; 
              
              return Dismissible( // --- NEW: Use a Dismissible widget for swipe-to-delete ---
                key: Key(chat.id), // Unique key for each chat item
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog( // Show a confirmation dialog
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Delete Chat"),
                        content: const Text("Are you sure you want to delete this chat? This action cannot be undone."),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false), // Dismiss and do not delete
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true), // Dismiss and confirm deletion
                            child: const Text("Delete"),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (direction) {
                  // Call the new method to delete the chat
                  _deleteChat(chat.id);
                },
                child: Card(
                  elevation: isUnread ? 4 : 1,
                  color: isUnread
                      ? (Theme.of(context).brightness == Brightness.dark
                          ? Colors.blueGrey.shade800 // A darker color for dark mode
                          : Colors.lightBlue.shade50) // The original color for light mode
                      : Theme.of(context).cardColor,
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: ListTile(
                    title: Text(
                      chat.subject, 
                      style: TextStyle(
                        fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status: ${chat.status.toUpperCase()}'),
                        Text(
                          'Last Message: ${DateFormat('MMM dd, hh:mm a').format(chat.lastMessageAt)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    trailing: isUnread
                        ? const Icon(Icons.circle, color: Colors.red, size: 12)
                        : null,
                    onTap: () {
                      debugPrint('Tapped on chat ID: ${chat.id}');

                      if (!chat.isReadByUser) {
                      _chatService.markChatAsRead(chat.id);
                    }

                      context.push('/support/chat/${chat.id}'); 
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

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}