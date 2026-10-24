import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/kivora_service.dart';

class ManagerBranchSettingsScreen extends StatelessWidget {
  const ManagerBranchSettingsScreen({super.key});

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
          'Branch Settings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Branch Chip Header
            Builder(
              builder: (context) {
                final branchId = KivoraService().currentBranchId;
                final branch = branchId != null ? KivoraService().getBranchById(branchId) : null;
                final display = branch != null ? '${branch.name} Branch' : 'Active Branch';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    display,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Settings Navigation Tiles
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildSettingTile(
                    icon: Icons.apartment,
                    title: 'Branch Information',
                    onTap: () => context.push(
                      '/member/branch',
                      extra: {'branchId': KivoraService().currentBranchId},
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildSettingTile(
                    icon: Icons.tune,
                    title: 'Identification Form Settings',
                    onTap: () => context.push('/manager/settings/id-form'),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildSettingTile(
                    icon: Icons.lock_outline,
                    title: 'Permissions',
                    onTap: () => context.push('/manager/settings/roles'),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildSettingTile(
                    icon: Icons.people_outline,
                    title: 'Roles & Access',
                    onTap: () => context.push('/manager/roles/edit'),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildSettingTile(
                    icon: Icons.rule,
                    title: 'Attendance Rules',
                    onTap: () => context.push('/manager/logs/verification'),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildSettingTile(
                    icon: Icons.notifications_none,
                    title: 'Notifications',
                    onTap: () => context.push('/member/notifications'),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildSettingTile(
                    icon: Icons.settings_outlined,
                    title: 'Advanced Settings',
                    onTap: () => context.push('/manager/logs/audit'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDFA),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF0D9488), size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Color(0xFFCBD5E1)),
      onTap: onTap,
    );
  }
}
