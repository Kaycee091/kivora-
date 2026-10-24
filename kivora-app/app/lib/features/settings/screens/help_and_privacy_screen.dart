import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HelpAndPrivacyScreen extends StatelessWidget {
  const HelpAndPrivacyScreen({super.key});

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
          'Help & Privacy',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand About Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text(
                        'K',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Kivora',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Every presence counts.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF0D9488), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'App Version v1.0.0',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Support section
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'How can we help you?',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildTile(Icons.help_outline, 'FAQs', 'Find answers to common questions'),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildTile(Icons.headset_mic_outlined, 'Contact Support', 'Chat with our support team'),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildTile(Icons.report_problem_outlined, 'Report a Problem', 'Send us a detailed report'),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildTile(Icons.feedback_outlined, 'Feedback', 'Share your thoughts'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Privacy section
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'Your Privacy Matters',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildTile(Icons.privacy_tip_outlined, 'Data Usage', 'How we use your data'),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildTile(Icons.security_outlined, 'Permissions', 'Manage app permissions'),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildTile(Icons.cookie_outlined, 'Cookies', 'Manage cookie preferences'),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildTile(Icons.hub_outlined, 'Third-party Services', 'Connected services'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF0D9488), size: 20),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
      trailing: const Icon(Icons.chevron_right, size: 18, color: Color(0xFFCBD5E1)),
      onTap: () {},
    );
  }
}
