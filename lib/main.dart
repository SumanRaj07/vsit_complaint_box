import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/complaint_provider.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/submit_screen.dart';
import 'screens/track_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/animations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: C.navy,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: C.bg,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => ComplaintProvider(),
      child: const VSITApp(),
    ),
  );
}

class VSITApp extends StatelessWidget {
  const VSITApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VSIT Grievance Portal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _PortalHeader(onAdminTap: _openAdmin),
            _NavigationBar(
              index: _index,
              onChanged: (value) => setState(() => _index = value),
            ),
            Expanded(
              child: IndexedStack(
                index: _index,
                children: const [SubmitScreen(), TrackScreen()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAdmin() {
    Navigator.of(
      context,
    ).push(FadeThroughRoute(page: const AdminLoginScreen()));
  }
}

class _PortalHeader extends StatelessWidget {
  final VoidCallback onAdminTap;

  const _PortalHeader({required this.onAdminTap});

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.of(context).size.width < 720;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [C.navy, C.royal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              compact ? 16 : 28,
              18,
              compact ? 16 : 28,
              18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: compact ? 48 : 56,
                      height: compact ? 48 : 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: C.gold, width: 3),
                      ),
                      child: const Icon(
                        Icons.school_outlined,
                        color: C.navy,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            compact
                                ? 'VSIT Grievance Portal'
                                : 'Vidyalankar School of Information Technology',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: C.serif(
                              size: 20,
                              weight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Student Complaint and Grievance Redressal System',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(0xFFD8E2F3),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!compact) ...[
                      _HeaderChip(
                        icon: Icons.verified_user_outlined,
                        label: 'Confidential',
                      ),
                      const SizedBox(width: 10),
                      _HeaderChip(
                        icon: Icons.schedule_outlined,
                        label: 'SLA tracked',
                      ),
                      const SizedBox(width: 12),
                    ],
                    OutlinedButton.icon(
                      onPressed: onAdminTap,
                      icon: const Icon(
                        Icons.admin_panel_settings_outlined,
                        size: 18,
                      ),
                      label: Text(compact ? 'Admin' : 'Admin Login'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.42),
                        ),
                        backgroundColor: Colors.white.withValues(alpha: 0.07),
                      ),
                    ),
                  ],
                ),
                if (compact) ...[
                  const SizedBox(height: 12),
                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _HeaderChip(
                        icon: Icons.verified_user_outlined,
                        label: 'Confidential',
                      ),
                      _HeaderChip(
                        icon: Icons.schedule_outlined,
                        label: 'SLA tracked',
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeaderChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: C.gold, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _NavigationBar({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: _NavButton(
                    active: index == 0,
                    icon: Icons.edit_document,
                    label: 'Submit Complaint',
                    onTap: () => onChanged(0),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _NavButton(
                    active: index == 1,
                    icon: Icons.manage_search_outlined,
                    label: 'Track Status',
                    onTap: () => onChanged(1),
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

class _NavButton extends StatelessWidget {
  final bool active;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavButton({
    required this.active,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: active ? C.royal : C.bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? C.royal : C.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: active ? Colors.white : C.muted),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: active ? Colors.white : C.text,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
