import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/kivora_service.dart';

/// EXTRA — Manager Settings (account, preferences, security, notifications)
class ManagerSettingsScreen extends StatefulWidget {
  const ManagerSettingsScreen({super.key});

  @override
  State<ManagerSettingsScreen> createState() => _ManagerSettingsScreenState();
}

class _ManagerSettingsScreenState extends State<ManagerSettingsScreen> {
  bool _biometricLogin = true;
  bool _pushNotifications = true;
  bool _emailDigest = false;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF0F172A)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Profile card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(child: Text('BM', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final branchId = KivoraService().currentBranchId;
                          final branch = branchId != null ? KivoraService().getBranchById(branchId) : null;
                          final branchText = branch != null ? '${branch.name} Branch' : 'Active Workspace';
                          final name = KivoraService().currentUserName.isNotEmpty
                              ? KivoraService().currentUserName
                              : 'Branch Manager';
                          final email = KivoraService().currentUserEmail.isNotEmpty
                              ? KivoraService().currentUserEmail
                              : 'manager@kivora.app';
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              Text(email, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                              Text(branchText, style: const TextStyle(fontSize: 11, color: Color(0xFF0D9488), fontWeight: FontWeight.w600)),
                            ],
                          );
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Color(0xFF0D9488)),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            _buildSection('Preferences', [
              _buildToggleTile('Dark Mode', Icons.dark_mode_outlined, _darkMode, (v) => setState(() => _darkMode = v)),
              _buildNavTile('Language', Icons.language_outlined, 'English', () {}),
            ]),

            const SizedBox(height: 16),

            _buildSection('Security', [
              _buildToggleTile('Biometric Login', Icons.fingerprint, _biometricLogin, (v) => setState(() => _biometricLogin = v)),
              _buildNavTile('Change Password', Icons.lock_outline, null, () {}),
              _buildNavTile('Active Sessions', Icons.devices_outlined, '1 device', () {}),
              _buildNavTile('Device Permissions', Icons.security_outlined, null, () => context.push('/manager/permissions')),
            ]),

            const SizedBox(height: 16),

            _buildSection('Notifications', [
              _buildToggleTile('Push Notifications', Icons.notifications_outlined, _pushNotifications, (v) => setState(() => _pushNotifications = v)),
              _buildToggleTile('Email Digest', Icons.email_outlined, _emailDigest, (v) => setState(() => _emailDigest = v)),
            ]),

            const SizedBox(height: 16),

            _buildSection('About', [
              _buildNavTile('Privacy Policy', Icons.privacy_tip_outlined, null, () => context.push('/manager/privacy')),
              _buildNavTile('Help & Support', Icons.help_outline, null, () => context.push('/manager/support')),
              _buildNavTile('About Kivora', Icons.info_outline, 'v1.0.0', () => context.push('/manager/about')),
            ]),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await AuthService().signOut();
                    if (context.mounted) {
                      context.go('/welcome');
                    }
                  },
                  icon: const Icon(Icons.logout, color: Color(0xFFEF4444)),
                  label: const Text('Sign Out', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 0.5)),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: tiles.map((t) {
              final i = tiles.indexOf(t);
              return Column(
                children: [
                  t,
                  if (i < tiles.length - 1) const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 16, endIndent: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleTile(String label, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF0D9488)),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)))),
          Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF0D9488)),
        ],
      ),
    );
  }

  Widget _buildNavTile(String label, IconData icon, String? trailing, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF0D9488), size: 20),
      title: Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Text(trailing, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1), size: 20),
        ],
      ),
      onTap: onTap,
    );
  }
}
