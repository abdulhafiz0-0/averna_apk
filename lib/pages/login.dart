import 'package:flutter/material.dart';
import 'dashboard.dart'; // Make sure the path is correct

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String _selectedRole = '';

  void _login() {
    if (_formKey.currentState!.validate()) {
      if (_selectedRole.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a role')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _isLoading = false;
        });

        // Accept test credentials or any email
        if ((_userController.text == 'superadmin' && _passwordController.text == 'admin') ||
            (_userController.text.contains('@'))) {
          // Navigate to dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid username/email or password')),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _roleButton(String role, String description) {
    final bool isSelected = _selectedRole == role;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      onPressed: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(role, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Circular Logo
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/logo.png'),
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(height: 24),

            // Title & Subtitle
            const Text(
              'Learning Center',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Welcome\nSign in to track attendance, manage fees, and permissions.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _userController,
                    decoration: const InputDecoration(
                      labelText: 'Email or Username',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email or username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                      suffixText: 'Forgot password?',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null; // No minimum length restriction
                    },
                  ),
                  const SizedBox(height: 24),

                  // Role buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _roleButton('Teacher', 'Take attendance, view payments'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _roleButton('Admin', 'Manage users & school settings'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _roleButton('Superadmin', 'Full control: admins, roles, permissions'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Sign in button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Sign in', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Guest login button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Continuing as guest')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Continue as guest', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Terms & privacy
                  const Text(
                    'By continuing you agree to the Terms & Privacy',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
