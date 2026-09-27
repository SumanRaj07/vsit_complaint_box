import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/animations.dart';
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _userCtrl = TextEditingController(text: 'admin');
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: FadeSlideIn(
              offsetY: 24,
              child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: C.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x180D1B3E),
                    blurRadius: 28,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [C.navy, C.royal]),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      children: const [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.admin_panel_settings_outlined,
                            color: C.navy,
                            size: 30,
                          ),
                        ),
                        SizedBox(height: 14),
                        Text(
                          'Admin Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'VSIT Grievance Management Console',
                          style: TextStyle(
                            color: Color(0xFFD8E2F3),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_error != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: C.danger.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: C.danger.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                color: C.danger,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        const Text(
                          'USERNAME',
                          style: TextStyle(
                            color: C.muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.7,
                          ),
                        ),
                        const SizedBox(height: 7),
                        TextField(
                          controller: _userCtrl,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person_outline),
                            hintText: 'admin',
                          ),
                          onSubmitted: (_) => _login(),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'PASSWORD',
                          style: TextStyle(
                            color: C.muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.7,
                          ),
                        ),
                        const SizedBox(height: 7),
                        TextField(
                          controller: _passCtrl,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline),
                            hintText: 'Enter password',
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            ),
                          ),
                          onSubmitted: (_) => _login(),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _loading ? null : _login,
                            icon: _loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.login_outlined),
                            label: const Text('Sign In'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            'Demo credentials: admin / vsit2024',
                            style: TextStyle(
                              color: C.muted.withValues(alpha: 0.85),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Center(
                          child: TextButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back, size: 16),
                            label: const Text('Back to student portal'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });

    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    final user = _userCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    if (user == 'admin' && (pass == 'vsit2024' || pass == 'vsit2025')) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      );
      return;
    }

    setState(() {
      _loading = false;
      _error = 'Invalid username or password.';
    });
  }
}
