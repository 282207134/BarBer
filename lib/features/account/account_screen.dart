import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return MainPage(
      index: 2,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              const PageHeader('My profile', back: false),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.open('/edit-profile'),
                      child: const Photo(
                        'profile',
                        width: 76,
                        height: 76,
                        radius: 60,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.name, style: display(24)),
                          const SizedBox(height: 6),
                          Text(
                            s.phone,
                            style: const TextStyle(color: muted, fontSize: 14),
                          ),
                          Text(
                            s.email,
                            style: const TextStyle(color: muted, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    RoundButton(
                      Icons.edit,
                      size: 40,
                      onTap: () => context.open('/edit-profile'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _link('My bonuses', () => context.open('/bonuses')),
              _link('Change password', () => context.open('/password')),
              _link('Exit', () async {
                await s.logout();
                if (context.mounted) context.root('/welcome');
              }),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => info(
                        context,
                        'Have a question?',
                        'Explore local barbershops, choose a service and time, then confirm your reservation. All demo data is stored on this device.',
                      ),
                      child: const Text(
                        'Have question?',
                        style: TextStyle(color: Colors.black26),
                      ),
                    ),
                    TextButton(
                      onPressed: () => info(
                        context,
                        'About BarberApp',
                        'BarberApp 1.0\nFlutter implementation of 25 Pixso reference screens.\nThis preview uses local demo data.',
                      ),
                      child: const Text(
                        'About the app',
                        style: TextStyle(color: Colors.black26),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _link(String title, VoidCallback action) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 22),
    title: Text(
      title,
      style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
    ),
    onTap: action,
  );
  void info(BuildContext context, String title, String body) => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key, this.password = false});
  final bool password;
  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final form = GlobalKey<FormState>();
  late final TextEditingController first, second, third;
  bool initialized = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      final s = AppScope.of(context);
      first = TextEditingController(text: widget.password ? '' : s.name);
      second = TextEditingController(text: widget.password ? '' : s.phone);
      third = TextEditingController(text: widget.password ? '' : s.email);
      initialized = true;
    }
  }

  @override
  void dispose() {
    first.dispose();
    second.dispose();
    third.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    if (!widget.password) {
      await AppScope.of(
        context,
      ).saveProfile(first.text.trim(), second.text.trim(), third.text.trim());
    }
    if (!mounted) return;
    context.notice(
      widget.password
          ? 'Password fields validated. Account security requires a connected backend.'
          : 'Profile saved',
    );
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      context.root('/profile');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Form(
        key: form,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 26, 10, 16),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.canPop(context)
                        ? Navigator.pop(context)
                        : context.root('/profile'),
                    child: const Text(
                      'Close',
                      style: TextStyle(color: Colors.black26),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.password ? 'Change password' : 'Edit profile',
                      style: display(18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  TextButton(onPressed: save, child: const Text('Save')),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 90, 22, 22),
                child: Column(
                  children: [
                    FormEntry(
                      label: widget.password ? 'Current password' : 'Your name',
                      controller: first,
                      secret: widget.password,
                      validator: requiredValidator,
                    ),
                    FormEntry(
                      label: widget.password ? 'New password' : 'Phone number',
                      controller: second,
                      secret: widget.password,
                      hint: widget.password ? 'Enter password' : '',
                      type: widget.password
                          ? TextInputType.text
                          : TextInputType.phone,
                      validator: (v) => widget.password
                          ? ((v?.length ?? 0) < 8
                                ? 'Use at least 8 characters'
                                : null)
                          : ((v?.replaceAll(RegExp(r'\D'), '').length ?? 0) < 7
                                ? 'Enter a valid phone number'
                                : null),
                    ),
                    FormEntry(
                      label: widget.password
                          ? 'Confirm new password'
                          : 'E-mail',
                      controller: third,
                      secret: widget.password,
                      hint: widget.password ? 'Enter password' : '',
                      type: widget.password
                          ? TextInputType.text
                          : TextInputType.emailAddress,
                      validator: (v) => widget.password
                          ? (v != second.text ? 'Passwords do not match' : null)
                          : emailValidator(v),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class BonusesScreen extends StatelessWidget {
  const BonusesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader('My bonuses'),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: ink, fontSize: 17),
                      children: [
                        TextSpan(text: '${s.bonuses}', style: display(52)),
                        const TextSpan(text: '  bonuses'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    '10 bonus point = 1 dollar discount.\nCollect bonuses and pay with them.',
                    style: TextStyle(color: muted, fontSize: 15, height: 1.35),
                  ),
                  const SizedBox(height: 64),
                  SurfaceCard(
                    onTap: () => context.open('/promo'),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'I have promocode',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Icon(Icons.chevron_right, color: muted),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Share promo code',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text('2188765AB', style: display(25)),
                                ],
                              ),
                            ),
                            RoundButton(
                              Icons.copy_outlined,
                              size: 40,
                              onTap: () async {
                                await Clipboard.setData(
                                  const ClipboardData(text: '2188765AB'),
                                );
                                if (context.mounted) {
                                  context.notice('Promo code copied');
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Share this code with friends and when they use it first time they’ll get 5\$ off and you’ll get 5\$ on your bonus balance.',
                          style: TextStyle(
                            color: muted,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PromoScreen extends StatefulWidget {
  const PromoScreen({super.key});
  @override
  State<PromoScreen> createState() => _PromoScreenState();
}

class _PromoScreenState extends State<PromoScreen> {
  final code = TextEditingController();
  String? error;
  @override
  void dispose() {
    code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          const PageHeader('I have promocode'),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 100, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Promo code number',
                  style: TextStyle(color: Colors.black26),
                ),
                TextField(
                  key: const ValueKey('promo-code'),
                  controller: code,
                  onChanged: (_) => setState(() => error = null),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: display(26),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '000 – 000',
                    hintStyle: display(26, Colors.black26),
                    errorText: error,
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: code.text.length != 6
                      ? null
                      : () async {
                          final s = AppScope.of(context);
                          final activated = await s.activatePromo(code.text);
                          if (!context.mounted) return;
                          if (activated) {
                            context.root('/congratulations');
                          } else {
                            setState(
                              () => error = s.promoUsed
                                  ? 'A promo code has already been used.'
                                  : 'Invalid code. Demo code: 218876',
                            );
                          }
                        },
                  child: const Text('Activate'),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
