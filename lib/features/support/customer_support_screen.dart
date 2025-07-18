// // lib/features/support/customer_support_screen.dart
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:pawpal/models/support_chat.dart';
// import 'package:pawpal/services/support_chat_service.dart';
// import 'package:pawpal/features/support/client_chat_screen.dart'; // Will be created next

// class CustomerSupportScreen extends StatefulWidget {
//   const CustomerSupportScreen({super.key});

//   @override
//   State<CustomerSupportScreen> createState() => _CustomerSupportScreenState();
// }

// class _CustomerSupportScreenState extends State<CustomerSupportScreen> {
//   late final String _currentUserId;
//   final SupportChatService _chatService = SupportChatService();

//   @override
//   void initState() {
//     super.initState();
//     final user = Supabase.instance.client.auth.currentUser;
//     if (user == null) {
//       // User not logged in, redirect to login
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         context.go('/login');
//       });
//       return;
//     }
//     _currentUserId = user.id;
//   }

//   // Function to show a dialog for starting a new chat
//   void _startNewChatDialog() {
//     final TextEditingController subjectController = TextEditingController();
//     final TextEditingController initialMessageController = TextEditingController();
//     final _formKey = GlobalKey<FormState>();

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Start New Support Chat'),
//           content: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextFormField(
//                   controller: subjectController,
//                   decoration: const InputDecoration(
//                     labelText: 'Subject (Optional)',
//                     hintText: 'e.g., Booking issue, App feedback',
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: initialMessageController,
//                   decoration: const InputDecoration(
//                     labelText: 'Your Message',
//                     hintText: 'Describe your issue or question',
//                     alignLabelWithHint: true,
//                   ),
//                   maxLines: 3,
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'Message cannot be empty';
//                     }
//                     return null;
//                   },
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 if (_formKey.currentState!.validate()) {
//                   Navigator.of(context).pop(); // Close dialog immediately

//                   // Get client display name from profiles table
//                   final profileResponse = await Supabase.instance.client
//                       .from('profiles')
//                       .select('display_name')
//                       .eq('id', _currentUserId)
//                       .single();
//                   final String clientDisplayName = profileResponse['display_name'] as String? ?? 'Client';

//                   try {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Starting new chat...')),
//                     );
//                     final newChat = await _chatService.createChat(
//                       clientId: _currentUserId,
//                       clientDisplayName: clientDisplayName,
//                       initialMessageContent: initialMessageController.text.trim(),
//                       subject: subjectController.text.trim().isNotEmpty ? subjectController.text.trim() : null,
//                     );
//                     if (mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Chat started successfully!')),
//                       );
//                       // Navigate to the new chat screen
//                       context.push('/support/chat/${newChat.id}', extra: newChat);
//                     }
//                   } catch (e) {
//                     if (mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Failed to start chat: ${e.toString()}')),
//                       );
//                     }
//                     print('Error starting new chat: $e');
//                   }
//                 }
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
//     // Ensure user is logged in before building the stream
//     if (Supabase.instance.client.auth.currentUser == null) {
//       return const Scaffold(
//         body: Center(child: Text('Please log in to access support.')),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Customer Support'),
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         foregroundColor: Theme.of(context).colorScheme.onPrimary,
//       ),
//       body: StreamBuilder<List<SupportChat>>(
//         stream: _chatService.streamClientChats(_currentUserId),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.support_agent, size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha((255 * 0.5).round())),
//                   const SizedBox(height: 20),
//                   Text(
//                     'No support chats yet.',
//                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                           color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha((255 * 0.7).round()),
//                         ),
//                   ),
//                   const SizedBox(height: 20),
//                   ElevatedButton.icon(
//                     onPressed: _startNewChatDialog,
//                     icon: const Icon(Icons.add_comment),
//                     label: const Text('Start New Chat'),
//                   ),
//                 ],
//               ),
//             );
//           }

//           final chats = snapshot.data!;
//           return ListView.builder(
//             padding: const EdgeInsets.all(16.0),
//             itemCount: chats.length,
//             itemBuilder: (context, index) {
//               final chat = chats[index];
//               return Card(
//                 margin: const EdgeInsets.only(bottom: 12.0),
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                 child: InkWell(
//                   onTap: () {
//                     // Navigate to the specific chat screen
//                     context.push('/support/chat/${chat.id}', extra: chat);
//                   },
//                   borderRadius: BorderRadius.circular(12),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 chat.subject != null && chat.subject!.isNotEmpty
//                                     ? chat.subject!
//                                     : 'Support Chat #${chat.id.substring(0, 8)}', // Display subject or truncated ID
//                                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                                       fontWeight: FontWeight.bold,
//                                       color: Theme.of(context).colorScheme.primary,
//                                     ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                             Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                               decoration: BoxDecoration(
//                                 color: _getChatStatusColor(chat.status),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Text(
//                                 chat.status.replaceAll('_', ' ').toUpperCase(),
//                                 style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           chat.lastMessageText ?? 'No messages yet.',
//                           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                                 color: Theme.of(context).colorScheme.onSurfaceVariant,
//                               ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 8),
//                         Align(
//                           alignment: Alignment.bottomRight,
//                           child: Text(
//                             chat.formattedLastMessageTime, // Use the getter from SupportChat model
//                             style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                                   color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha((255 * 0.6).round()),
//                                 ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _startNewChatDialog,
//         icon: const Icon(Icons.add_comment),
//         label: const Text('New Chat'),
//         backgroundColor: Theme.of(context).colorScheme.secondary,
//         foregroundColor: Theme.of(context).colorScheme.onSecondary,
//       ),
//     );
//   }

//   // Helper function to determine chat status color
//   Color _getChatStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'assistant_handling':
//         return Colors.blueGrey; // AI is currently handling
//       case 'open':
//         return Colors.orange; // Waiting for human admin
//       case 'in_progress':
//         return Colors.green; // Human admin is actively chatting
//       case 'closed':
//         return Colors.grey; // Chat is resolved
//       default:
//         return Colors.grey;
//     }
//   }
// }










import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart'; // Keep this if you use Provider.of in build
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pawpal/models/support_chat.dart';
import 'package:pawpal/services/support_chat_service.dart';
import 'package:pawpal/features/support/client_chat_screen.dart'; // Will be created next

class CustomerSupportScreen extends StatefulWidget {
  const CustomerSupportScreen({super.key});

  @override
  State<CustomerSupportScreen> createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends State<CustomerSupportScreen> {
  late final String _currentUserId;
  // Initialize _chatService here. If you're using Provider for it, you'd get it in initState or build.
  // Given your current usage (not listening to changes), direct instantiation is okay for now.
  // If SupportChatService ever becomes a ChangeNotifier that needs to rebuild widgets,
  // then it should be obtained via Provider.of in build or initState with listen: false.
  final SupportChatService _chatService = SupportChatService();

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) { // Ensure widget is still mounted before navigating
          context.go('/login');
        }
      });
      return;
    }
    _currentUserId = user.id;
  }

  void _startNewChatDialog() {
    final TextEditingController subjectController = TextEditingController();
    final TextEditingController initialMessageController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) { // Use dialogContext to avoid conflicts with outer context
        return AlertDialog(
          title: const Text('Start New Support Chat'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Subject (Optional)',
                    hintText: 'e.g., Booking issue, App feedback',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: initialMessageController,
                  decoration: const InputDecoration(
                    labelText: 'Your Message',
                    hintText: 'Describe your issue or question',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Message cannot be empty';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // Use dialogContext for pop to ensure it pops the correct dialog
                  Navigator.of(dialogContext).pop(); 

                  // Get client display name from profiles table
                  // Make sure this isn't called after `mounted` check fails,
                  // it's an API call, not UI interaction.
                  final profileResponse = await Supabase.instance.client
                      .from('profiles')
                      .select('display_name')
                      .eq('id', _currentUserId)
                      .single();
                  final String clientDisplayName = profileResponse['display_name'] as String? ?? 'Client';

                  try {
                    // Use `context` (outer context) for ScaffoldMessenger, but with `mounted` check
                    if (mounted) { 
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Starting new chat...')),
                      );
                    }
                    
                    final newChat = await _chatService.createSupportChat( // Changed to createSupportChat
                      clientId: _currentUserId,
                      clientDisplayName: clientDisplayName,
                      initialMessageContent: initialMessageController.text.trim(),
                      subject: subjectController.text.trim().isNotEmpty ? subjectController.text.trim() : null,
                    );

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Chat started successfully!')),
                      );
                      // Navigate to the new chat screen
                      context.push('/support/chat/${newChat.id}', extra: newChat);
                    }
                  } catch (e) {
                    print('Error starting new chat: $e');
                    if (mounted) { // <--- ADD THIS CHECK
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to start chat: ${e.toString()}')),
                      );
                    }
                  }
                }
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
    // Ensure user is logged in before building the stream
    if (Supabase.instance.client.auth.currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to access support.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Support'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: StreamBuilder<List<SupportChat>>(
        stream: _chatService.getChatsForUser(), // Changed to getChatsForUser
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.support_agent, size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha((255 * 0.5).round())),
                  const SizedBox(height: 20),
                  Text(
                    'No support chats yet.',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha((255 * 0.7).round()),
                        ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _startNewChatDialog,
                    icon: const Icon(Icons.add_comment),
                    label: const Text('Start New Chat'),
                  ),
                ],
              ),
            );
          }

          final chats = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: () {
                    // Navigate to the specific chat screen
                    context.push('/support/chat/${chat.id}', extra: chat);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                chat.subject != null && chat.subject!.isNotEmpty
                                    ? chat.subject!
                                    : 'Support Chat #${chat.id.substring(0, 8)}', // Display subject or truncated ID
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getChatStatusColor(chat.status),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                chat.status.replaceAll('_', ' ').toUpperCase(),
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          chat.lastMessageText ?? 'No messages yet.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            chat.formattedLastMessageTime, // Use the getter from SupportChat model
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha((255 * 0.6).round()),
                                ),
                          ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startNewChatDialog,
        icon: const Icon(Icons.add_comment),
        label: const Text('New Chat'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
      ),
    );
  }

  Color _getChatStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'assistant_handling':
        return Colors.blueGrey;
      case 'open':
        return Colors.orange;
      case 'in_progress':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}