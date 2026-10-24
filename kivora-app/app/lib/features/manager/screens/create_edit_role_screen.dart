import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateEditRoleScreen extends StatefulWidget {
  final String? existingRoleName;
  const CreateEditRoleScreen({super.key, this.existingRoleName});

  @override
  State<CreateEditRoleScreen> createState() => _CreateEditRoleScreenState();
}

class _CreateEditRoleScreenState extends State<CreateEditRoleScreen> {
  final _roleNameController = TextEditingController();
  final _roleDescController = TextEditingController();

  bool _canManageSchedule = false;
  bool _canManageAttendance = false;
  bool _canViewReports = false;
  bool _canManageMembers = false;
  bool _canManageSettings = false;
  bool _canSendAnnouncements = false;
  bool _canApproveLeave = false;
  bool _canViewAuditLogs = false;
  bool _canManageRoles = false;
  bool _canExportData = false;

  String _selectedColor = '#0D9488';
  final List<String> _roleColors = [
    '#0D9488', '#3B82F6', '#8B5CF6', '#F59E0B',
    '#EF4444', '#10B981', '#EC4899', '#64748B',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingRoleName != null) {
      _roleNameController.text = widget.existingRoleName!;
    }
  }

  @override
  void dispose() {
    _roleNameController.dispose();
    _roleDescController.dispose();
    super.dispose();
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingRoleName != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF0F172A)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isEditing ? 'Edit Role' : 'Create Role',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Role Name
            _buildSectionLabel('Role Name'),
            const SizedBox(height: 8),
            TextField(
              controller: _roleNameController,
              decoration: InputDecoration(
                hintText: 'e.g. Senior Supervisor',
                hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),

            const SizedBox(height: 20),

            // Description
            _buildSectionLabel('Description (optional)'),
            const SizedBox(height: 8),
            TextField(
              controller: _roleDescController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe the responsibilities of this role...',
                hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),

            const SizedBox(height: 20),

            // Role Color
            _buildSectionLabel('Role Color'),
            const SizedBox(height: 10),
            Row(
              children: _roleColors.map((hex) {
                final isSelected = _selectedColor == hex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = hex),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _hexToColor(hex),
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Permissions
            _buildSectionLabel('Permissions'),
            const SizedBox(height: 10),
            _buildPermissionsCard(),

            const SizedBox(height: 32),

            // Save Role Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveRole,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  isEditing ? 'Update Role' : 'Create Role',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 12),

            if (isEditing)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _deleteRole,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Delete Role', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
    );
  }

  Widget _buildPermissionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _buildPermTile('Manage Schedule', Icons.calendar_month_outlined, _canManageSchedule,
              (v) => setState(() => _canManageSchedule = v)),
          _buildDivider(),
          _buildPermTile('Manage Attendance', Icons.fact_check_outlined, _canManageAttendance,
              (v) => setState(() => _canManageAttendance = v)),
          _buildDivider(),
          _buildPermTile('View Reports', Icons.bar_chart_outlined, _canViewReports,
              (v) => setState(() => _canViewReports = v)),
          _buildDivider(),
          _buildPermTile('Manage Members', Icons.people_outline, _canManageMembers,
              (v) => setState(() => _canManageMembers = v)),
          _buildDivider(),
          _buildPermTile('Approve Leave', Icons.event_available_outlined, _canApproveLeave,
              (v) => setState(() => _canApproveLeave = v)),
          _buildDivider(),
          _buildPermTile('Send Announcements', Icons.campaign_outlined, _canSendAnnouncements,
              (v) => setState(() => _canSendAnnouncements = v)),
          _buildDivider(),
          _buildPermTile('Manage Roles', Icons.admin_panel_settings_outlined, _canManageRoles,
              (v) => setState(() => _canManageRoles = v)),
          _buildDivider(),
          _buildPermTile('View Audit Logs', Icons.history_outlined, _canViewAuditLogs,
              (v) => setState(() => _canViewAuditLogs = v)),
          _buildDivider(),
          _buildPermTile('Export Data', Icons.download_outlined, _canExportData,
              (v) => setState(() => _canExportData = v)),
          _buildDivider(),
          _buildPermTile('Manage Settings', Icons.settings_outlined, _canManageSettings,
              (v) => setState(() => _canManageSettings = v)),
        ],
      ),
    );
  }

  Widget _buildPermTile(String label, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: value ? const Color(0xFF0D9488) : const Color(0xFF94A3B8)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: value ? const Color(0xFF0F172A) : const Color(0xFF64748B),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF0D9488),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 16, endIndent: 16);
  }

  void _saveRole() {
    if (_roleNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a role name'), backgroundColor: Color(0xFFEF4444)),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.existingRoleName != null
              ? 'Role updated successfully'
              : 'Role "${_roleNameController.text.trim()}" created',
        ),
        backgroundColor: const Color(0xFF0D9488),
      ),
    );
    context.pop();
  }

  void _deleteRole() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Role', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "${widget.existingRoleName}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
