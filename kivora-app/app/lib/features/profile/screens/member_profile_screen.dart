import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/kivora_service.dart';

class MemberProfileScreen extends StatelessWidget {
  const MemberProfileScreen({super.key});

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
          'Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF64748B)),
            onPressed: () => context.push('/member/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Avatar & Name Card
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE0F2F1),
                          border: Border.all(color: const Color(0xFF0D9488), width: 3),
                        ),
                        child: const Center(
                          child: Icon(Icons.person, size: 56, color: Color(0xFF0D9488)),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFF0D9488),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    KivoraService().currentUserName.isNotEmpty
                        ? KivoraService().currentUserName
                        : (KivoraService().currentUserEmail.isNotEmpty
                            ? KivoraService().currentUserEmail.split('@').first
                            : 'Member'),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 4),
                  Builder(
                    builder: (context) {
                      final branch = KivoraService().currentBranch;
                      final branchName = branch?.name ?? 'Techverve Branch';
                      final email = KivoraService().currentUserEmail;
                      return Text(
                        '$email\n$branchName',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.3),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Profile Section Tiles
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildNavTile(
                    icon: Icons.person_outline,
                    title: 'Personal Information',
                    onTap: () => context.push('/member/profile/edit'),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildNavTile(
                    icon: Icons.school_outlined,
                    title: 'Academic Details',
                    onTap: () => context.push('/member/classes/cs-201'),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildNavTile(
                    icon: Icons.phone_outlined,
                    title: 'Contact Information',
                    onTap: () => context.push('/member/profile/edit'),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildNavTile(
                    icon: Icons.emergency_outlined,
                    title: 'Emergency Contact',
                    onTap: () => context.push('/member/profile/edit'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Edit Profile Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () => context.push('/member/profile/edit'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF0D9488)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF0D9488), size: 22),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Color(0xFFCBD5E1)),
      onTap: onTap,
    );
  }
}
