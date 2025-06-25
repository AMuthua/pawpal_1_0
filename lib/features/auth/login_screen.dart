// // ignore_for_file: use_build_context_synchronously

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _loading = false;

//   Future<void> _login() async {
//     setState(() => _loading = true);
//     final email = _emailController.text.trim();
//     final password = _passwordController.text;

//     final response = await Supabase.instance.client.auth.signInWithPassword(
//       email: email,
//       password: password,
//     );

//     if (response.user != null) {
//       // Navigate to Home on success
//       if (!mounted) return;
//       context.go('/home');
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Login failed. Please try again.')),
//       );
//     }

//     setState(() => _loading = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Login')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               controller: _emailController,
//               decoration: const InputDecoration(labelText: 'Email'),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _passwordController,
//               obscureText: true,
//               decoration: const InputDecoration(labelText: 'Password'),
//             ),
//             const SizedBox(height: 28),
//             ElevatedButton(
//               onPressed: _loading ? null : _login,
//               child: _loading
//                   ? const CircularProgressIndicator()
//                   : const Text('Login'),
//             ),
//             const SizedBox(height: 16),
//             TextButton(
//               onPressed: () => context.go('/signup'),
//               child: const Text("Don't have an account? Sign up"),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:email_validator/email_validator.dart'; // For email format validation

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false; // To show loading state on button
  String? _emailErrorText; // For email-specific error
  String? _passwordErrorText; // For password-specific error

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _login() async {
    // Clear previous errors
    setState(() {
      _emailErrorText = null;
      _passwordErrorText = null;
    });

    if (!_formKey.currentState!.validate()) {
      // If form fields have validation errors, do not proceed
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // If login is successful, navigate to home
      if (mounted) {
        _showSnackBar('Login successful!');
        context.go('/home'); // Or whatever your authenticated home route is
      }
    } on AuthException catch (e) {
      // Handle Supabase specific authentication errors
      print('Supabase Auth Error: ${e.message}');
      if (e.message.contains('invalid login credentials') || e.message.contains('Email not confirmed')) {
        setState(() {
          _emailErrorText = 'Invalid email or password.';
          _passwordErrorText = 'Invalid email or password.';
        });
        _showSnackBar('Invalid email or password. Please try again.', isError: true);
      } else {
        _showSnackBar('Login failed: ${e.message}', isError: true);
      }
    } catch (e) {
      // Handle any other unexpected errors
      print('General Login Error: $e');
      _showSnackBar('An unexpected error occurred. Please try again later.', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PawPal Login'),
        backgroundColor: Theme.of(context).colorScheme.primary, // Uses your theme's primary color
        foregroundColor: Theme.of(context).colorScheme.onPrimary, // Text color for app bar
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction, // Validate as user types
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Your App Logo/Image
                // Image.asset(
                //   'assets/logo.png', // Replace with your logo path
                //   height: 120,
                // ),
                const SizedBox(height: 48),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: const Icon(Icons.email),
                    border: const OutlineInputBorder(),
                    errorText: _emailErrorText, // Display specific error here
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required.';
                    }
                    if (!EmailValidator.validate(value.trim())) {
                      return 'Please enter a valid email address.';
                    }
                    return null; // Valid
                  },
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _passwordController,
                  obscureText: true, // Hide password
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    errorText: _passwordErrorText, // Display specific error here
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required.';
                    }
                    if (value.length < 6) { // Example: minimum 6 characters
                      return 'Password must be at least 6 characters.';
                    }
                    return null; // Valid
                  },
                ),
                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: _isLoading ? null : _login, // Disable button if loading
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Login'),
                ),
                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    // Navigate to forgot password screen
                    context.go('/forgot_password'); // Define this route in app_routes.dart
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to sign up screen
                    context.go('/signup'); // Define this route in app_routes.dart
                  },
                  child: Text(
                    'Don\'t have an account? Sign Up',
                    style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
