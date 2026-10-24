import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DevicePermissionsScreen extends StatefulWidget {
  const DevicePermissionsScreen({super.key});

  @override
  State<DevicePermissionsScreen> createState() => _DevicePermissionsScreenState();
}

class _DevicePermissionsScreenState extends State<DevicePermissionsScreen> {
  bool _location = true;
  bool _camera = true;
  bool _biometric = true;
  bool _storage = true;
  bool _notifications = true;

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
          'Device Permissions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manage what your device can access.',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildToggleTile(
                    icon: Icons.location_on,
                    title: 'Location',
                    subtitle: 'Required for attendance',
                    value: _location,
                    onChanged: (val) => setState(() => _location = val),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildToggleTile(
                    icon: Icons.camera_alt,
                    title: 'Camera',
                    subtitle: 'For ID and verification',
                    value: _camera,
                    onChanged: (val) => setState(() => _camera = val),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildToggleTile(
                    icon: Icons.fingerprint,
                    title: 'Biometric',
                    subtitle: 'For secure login',
                    value: _biometric,
                    onChanged: (val) => setState(() => _biometric = val),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildToggleTile(
                    icon: Icons.folder,
                    title: 'Storage',
                    subtitle: 'For profile and documents',
                    value: _storage,
                    onChanged: (val) => setState(() => _storage = val),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildToggleTile(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    subtitle: 'Stay updated',
                    value: _notifications,
                    onChanged: (val) => setState(() => _notifications = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Bottom trust card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDFA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFCCFBF1)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: Color(0xFF0D9488), size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your data is always safe and secure with Kivora.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F766E)),
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

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
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
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
      trailing: Switch.adaptive(
        value: value,
        activeColor: const Color(0xFF0D9488),
        onChanged: onChanged,
      ),
    );
  }
}
