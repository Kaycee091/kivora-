import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// EXTRA — Manager Support screen
class ManagerSupportScreen extends StatelessWidget {
  const ManagerSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'q': 'How do I approve a member join request?',
        'a': 'Go to Members → Membership Approval to review and approve or reject pending join requests.',
      },
      {
        'q': 'How do I generate an invite code?',
        'a': 'Navigate to Quick Actions on your dashboard and tap "Create Invite Code". The code can be shared with prospective members.',
      },
      {
        'q': 'How do I configure attendance rules?',
        'a': 'Go to Branch Settings → Attendance Rules to configure grace periods, late thresholds, and half-day cutoffs.',
      },
      {
        'q': 'Can I export attendance reports?',
        'a': 'Yes. Go to Reports and use the export button to download CSV or PDF reports for any date range.',
      },
      {
        'q': 'How do I set up geofencing?',
        'a': 'Go to Branch Settings → Location & Geofence to define the GPS coordinates and radius for your branch.',
      },
    ];

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
          'Help & Support',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact cards
            Row(
              children: [
                Expanded(child: _buildContactCard(Icons.email_outlined, 'Email Support', 'support@kivora.app', const Color(0xFF3B82F6))),
                const SizedBox(width: 12),
                Expanded(child: _buildContactCard(Icons.chat_bubble_outline, 'Live Chat', 'Available 9–5', const Color(0xFF0D9488))),
              ],
            ),

            const SizedBox(height: 24),

            const Text('Frequently Asked Questions', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 12),

            ...faqs.map((faq) => _buildFaqTile(faq['q']!, faq['a']!)),

            const SizedBox(height: 24),

            // Report issue
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bug_report_outlined, color: Color(0xFFF59E0B), size: 22),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Report a Bug', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                        Text('Help us improve Kivora by reporting issues', style: TextStyle(fontSize: 11, color: Color(0xFFB45309))),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Report', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(IconData icon, String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildFaqTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(question, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
        iconColor: const Color(0xFF0D9488),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.5)),
          ),
        ],
      ),
    );
  }
}

/// EXTRA — Manager Privacy Policy screen
class ManagerPrivacyScreen extends StatelessWidget {
  const ManagerPrivacyScreen({super.key});

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
          'Privacy Policy',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.privacy_tip_outlined, color: Color(0xFF3B82F6), size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Last updated: October 22, 2026',
                      style: TextStyle(fontSize: 13, color: Color(0xFF1D4ED8), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildPrivacySection('Data We Collect',
              'Kivora collects attendance records, GPS coordinates, device identifiers, biometric fingerprints (locally stored only), and network information to provide the attendance verification service.'),
            _buildPrivacySection('How We Use Your Data',
              'Your data is used exclusively to verify attendance, generate reports for your organization, and maintain audit trails for compliance purposes.'),
            _buildPrivacySection('Data Storage & Security',
              'All data is encrypted in transit using TLS 1.3 and at rest using AES-256. Biometric data never leaves your device.'),
            _buildPrivacySection('Data Retention',
              'Attendance records are retained for 3 years. You may request deletion of your account and associated data at any time by contacting support.'),
            _buildPrivacySection('Third Parties',
              'Kivora does not sell your data. We use Supabase for database infrastructure and may share anonymized aggregate statistics with your organization administrators.'),
            _buildPrivacySection('Your Rights',
              'You have the right to access, correct, or request deletion of your personal data. Contact support@kivora.app to exercise these rights.'),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.6)),
        ],
      ),
    );
  }
}

/// EXTRA — Manager About screen
class ManagerAboutScreen extends StatelessWidget {
  const ManagerAboutScreen({super.key});

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
          'About Kivora',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Text('K', style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Kivora', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const Text('Smart Attendance Platform', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Version 1.0.0 (Build 100)', style: TextStyle(fontSize: 12, color: Color(0xFF3B82F6), fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 32),
            _buildAboutTile(Icons.description_outlined, 'Terms of Service', () {}),
            _buildAboutTile(Icons.privacy_tip_outlined, 'Privacy Policy', () => context.push('/manager/privacy')),
            _buildAboutTile(Icons.help_outline, 'Help & Support', () => context.push('/manager/support')),
            _buildAboutTile(Icons.open_in_new, 'Visit Website', () {}),
            const SizedBox(height: 32),
            const Text('© 2026 Kivora. All rights reserved.', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutTile(IconData icon, String label, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF0D9488), size: 20),
        title: Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
        onTap: onTap,
      ),
    );
  }
}

/// EXTRA — Manager Device Permissions screen
class ManagerPermissionsScreen extends StatefulWidget {
  const ManagerPermissionsScreen({super.key});

  @override
  State<ManagerPermissionsScreen> createState() => _ManagerPermissionsScreenState();
}

class _ManagerPermissionsScreenState extends State<ManagerPermissionsScreen> {
  bool _locationEnabled = true;
  bool _cameraEnabled = true;
  bool _biometricEnabled = true;
  bool _notificationsEnabled = true;
  bool _storageEnabled = false;

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
          'Device Permissions',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDFA),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFCCFBF1)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF0D9488), size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Kivora needs these permissions to verify attendance accurately.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF0F766E)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildPermTile(
              Icons.location_on_outlined,
              'Location',
              'Required for GPS-based geofence verification',
              _locationEnabled,
              (v) => setState(() => _locationEnabled = v),
              const Color(0xFF10B981),
            ),
            _buildPermTile(
              Icons.camera_alt_outlined,
              'Camera',
              'Used for profile photo and document uploads',
              _cameraEnabled,
              (v) => setState(() => _cameraEnabled = v),
              const Color(0xFF3B82F6),
            ),
            _buildPermTile(
              Icons.fingerprint,
              'Biometrics',
              'Enables fingerprint login and attendance verification',
              _biometricEnabled,
              (v) => setState(() => _biometricEnabled = v),
              const Color(0xFF8B5CF6),
            ),
            _buildPermTile(
              Icons.notifications_outlined,
              'Notifications',
              'Sends alerts for approvals, announcements, and reminders',
              _notificationsEnabled,
              (v) => setState(() => _notificationsEnabled = v),
              const Color(0xFFF59E0B),
            ),
            _buildPermTile(
              Icons.folder_outlined,
              'Storage',
              'Needed to save exported reports locally',
              _storageEnabled,
              (v) => setState(() => _storageEnabled = v),
              const Color(0xFF64748B),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.settings_outlined, size: 18),
                label: const Text('Open System Settings'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0D9488),
                  side: const BorderSide(color: Color(0xFF0D9488)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermTile(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: value ? color.withOpacity(0.12) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: value ? color : const Color(0xFF94A3B8), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: color,
          ),
        ],
      ),
    );
  }
}
