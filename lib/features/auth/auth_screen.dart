import 'package:flutter/material.dart';
import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.mode = 'welcome'});
  final String mode;
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController(text: 'c.warren@example.com');
  final password = TextEditingController(text: 'BarberApp123!');
  final confirm = TextEditingController(text: 'BarberApp123!');
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    confirm.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    await AppScope.of(context).authenticate(email.text.trim());
    if (mounted) context.root('/home');
  }

  @override
  Widget build(BuildContext context) {
    final welcome = widget.mode == 'welcome';
    return Scaffold(
      backgroundColor: ink,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Photo('welcome', radius: 0),
          if (!welcome) const ColoredBox(color: Color(0x45000000)),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 38, 22, 0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.content_cut,
                        color: Colors.white,
                        size: 26,
                      ),
                      const SizedBox(width: 8),
                      Text('BarberApp', style: display(24, Colors.white)),
                    ],
                  ),
                ),
                if (welcome) ...[
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome to', style: display(18, Colors.white70)),
                        const SizedBox(height: 8),
                        Text(
                          'Territory\nof Real Men',
                          style: display(34, Colors.white),
                        ),
                        const SizedBox(height: 48),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                onPressed: () => context.open('/login'),
                                child: const Text('Log In'),
                              ),
                            ),
                            const SizedBox(width: 22),
                            Expanded(
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.white24,
                                ),
                                onPressed: () => context.open('/signup'),
                                child: const Text('Sign Up'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 110),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(22, 60, 22, 20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                      ),
                      child: Form(
                        key: form,
                        child: SingleChildScrollView(child: _fields(context)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fields(BuildContext context) {
    final signup = widget.mode == 'signup';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(signup ? 'Sign Up' : 'Log In', style: display(26, Colors.black26)),
        const SizedBox(height: 32),
        FormEntry(
          label: 'E-mail',
          controller: email,
          type: TextInputType.emailAddress,
          validator: emailValidator,
        ),
        FormEntry(
          label: 'Password',
          controller: password,
          secret: true,
          validator: (v) =>
              (v?.length ?? 0) < 8 ? 'Use at least 8 characters' : null,
        ),
        if (signup)
          FormEntry(
            label: 'Confirm new password',
            controller: confirm,
            secret: true,
            validator: (v) =>
                v != password.text ? 'Passwords do not match' : null,
          ),
        SizedBox(height: signup ? 30 : 0),
        FilledButton(
          onPressed: submit,
          child: Text(signup ? 'Sign Up' : 'Log In'),
        ),
        if (!signup)
          Center(
            child: TextButton(
              onPressed: () => appSheet(
                context,
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Reset password', style: display(24)),
                      const SizedBox(height: 16),
                      const Text(
                        'This is a local demo. Use any valid email and a password with at least 8 characters to explore the app.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Got it'),
                      ),
                    ],
                  ),
                ),
              ),
              child: const Text(
                'Forgot password?',
                style: TextStyle(color: muted),
              ),
            ),
          ),
        const SizedBox(height: 20),
        Center(
          child: TextButton(
            onPressed: () => Navigator.pushReplacementNamed(
              context,
              signup ? '/login' : '/signup',
            ),
            child: Text(
              signup ? 'Log In' : 'Sign Up',
              style: const TextStyle(color: muted),
            ),
          ),
        ),
      ],
    );
  }
}
