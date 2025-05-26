import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class SessionChecker extends StatelessWidget {
  const SessionChecker({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    Future.delayed(Duration.zero, () {
      if (session != null) {
        context.go('/home');
      } else {
        context.go('/login');
      }
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
