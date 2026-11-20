import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/kivora_service.dart';

class RolePermissionsScreen extends StatefulWidget {
  const RolePermissionsScreen({super.key});

  @override
  State<RolePermissionsScreen> createState() => _RolePermissionsScreenState();
}

class _RolePermissionsScreenState extends State<RolePermissionsScreen> {
  bool _perm = true;
  bool _roles = true;
  bool _supervisor = false;
  bool _notif = true;
  bool _advanced = false;

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Role permissions saved.')),
    );
    context.pop();
  }

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
          'Role Permissions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${KivoraService().currentBranch?.name ?? "Branch"} • Delegated Roles',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
                ),
              ),
              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildSwitchTile(Icons.vpn_key_outlined, 'Permissions', _perm, (v) => setState(() => _perm = v)),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildSwitchTile(Icons.people_outline, 'Roles & Access', _roles, (v) => setState(() => _roles = v)),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildSwitchTile(Icons.admin_panel_settings_outlined, 'Supervisor Rules', _supervisor, (v) => setState(() => _supervisor = v)),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildSwitchTile(Icons.notifications_none, 'Notifications', _notif, (v) => setState(() => _notif = v)),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildSwitchTile(Icons.tune, 'Advanced Settings', _advanced, (v) => setState(() => _advanced = v)),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Save Changes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF0D9488), size: 22),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
      trailing: Switch.adaptive(
        value: value,
        activeColor: const Color(0xFF0D9488),
        onChanged: onChanged,
      ),
    );
  }
}
