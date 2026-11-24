import 'package:flutter/material.dart';

import '../services/session.dart';
import 'login_screen.dart' show kEmailPattern;

/// Screen 2b - Register (Form validation incl. matching passwords).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _code = TextEditingController();
  UserRole _role = UserRole.user;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _password, _confirm, _code]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Session.register(_name.text, _email.text, _role,
          phone: _phone.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created. Please log in.')),
      );
      Navigator.pop(context); // back to Login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                          labelText: 'Full name',
                          prefixIcon: Icon(Icons.person_outline)),
                      validator: (v) => (v == null || v.trim().length < 3)
                          ? 'Enter your full name (min 3 letters)'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined)),
                      validator: (v) => !kEmailPattern.hasMatch(v?.trim() ?? '')
                          ? 'Enter a valid email address'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                          labelText: 'Phone number',
                          prefixIcon: Icon(Icons.phone_outlined)),
                      validator: (v) {
                        final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
                        if (digits.length < 9 || digits.length > 12) {
                          return 'Enter a valid phone number (9-12 digits)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline)),
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Password must be at least 6 characters'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirm,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Confirm password',
                          prefixIcon: Icon(Icons.lock_reset)),
                      validator: (v) =>
                          v != _password.text ? 'Passwords do not match' : null,
                    ),
                    const SizedBox(height: 20),
                    Text('Register as',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    SegmentedButton<UserRole>(
                      segments: const [
                        ButtonSegment(
                            value: UserRole.user,
                            icon: Icon(Icons.person_outline),
                            label: Text('User')),
                        ButtonSegment(
                            value: UserRole.volunteer,
                            icon: Icon(Icons.volunteer_panel_settings_outlined),
                            label: Text('Volunteer')),
                      ],
                      selected: {_role},
                      onSelectionChanged: (s) =>
                          setState(() => _role = s.first),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _role == UserRole.volunteer
                          ? 'Volunteers can add and edit shelters. You need an volunteer ID code from your organisation.'
                          : 'Users can find and view shelters.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    // Only volunteers must enter an organisation / volunteer ID code.
                    if (_role == UserRole.volunteer) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _code,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'Volunteer ID code',
                          helperText: 'Given to you by your organisation',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: (v) => Session.isValidAdminCode(v ?? '')
                            ? null
                            : 'Invalid volunteer ID code',
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                        onPressed: _submit, child: const Text('Register')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
