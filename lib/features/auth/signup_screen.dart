import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _loading = false;

  Future<void> _signUp() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text;
  final displayName = _nameController.text.trim();

  setState(() => _loading = true);

  try {
    final result = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );

    final user = result.user;
    if (user != null) {
      // 👇 Insert into 'profiles' table
      await Supabase.instance.client.from('profiles').insert({
        'id': user.id,
        'display_name': displayName,
        'email': email,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signup successful.')),
      );
      context.go('/home');
    }
  } on AuthException catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Signup failed: ${error.message}')),
    );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unexpected error occurred')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Profile Name'),
            ),

            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 16),
            TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _signUp,
              child: _loading ? const CircularProgressIndicator() : const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
