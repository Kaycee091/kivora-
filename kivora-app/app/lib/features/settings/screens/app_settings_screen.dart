import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _biometricLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            _buildSectionHeader('Account'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildSettingTile(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    onTap: () => context.push('/member/settings/security'),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildSettingTile(
                    icon: Icons.notifications_none,
                    title: 'Notifications',
                    onTap: () => context.push('/member/notifications'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // App Preferences Section
            _buildSectionHeader('App Preferences'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildSettingTile(
                    icon: Icons.light_mode_outlined,
                    title: 'Theme',
                    trailingText: 'Light',
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildSettingTile(
                    icon: Icons.language,
                    title: 'Language',
                    trailingText: 'English',
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  ListTile(
                    leading: const Icon(Icons.fingerprint, color: Color(0xFF0D9488)),
                    title: const Text('Biometric Login', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    trailing: Switch.adaptive(
                      value: _biometricLogin,
                      activeColor: const Color(0xFF0D9488),
                      onChanged: (val) => setState(() => _biometricLogin = val),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Security Section
            _buildSectionHeader('Security'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildSettingTile(
                    icon: Icons.security,
                    title: 'Device Permissions',
                    onTap: () => context.push('/member/settings/permissions'),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildSettingTile(
                    icon: Icons.info_outline,
                    title: 'About Kivora',
                    onTap: () => context.push('/member/settings/help'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton.icon(
                onPressed: () async {
                  await AuthService().signOut();
                  if (context.mounted) {
                    context.go('/welcome');
                  }
                },
                icon: const Icon(Icons.logout, color: Color(0xFFEF4444), size: 18),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF0D9488), size: 20),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(trailingText, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 18, color: Color(0xFFCBD5E1)),
        ],
      ),
      onTap: onTap,
    );
  }
}
