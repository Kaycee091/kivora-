import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/kivora_theme.dart';
import '../../../core/widgets/kivora_components.dart';

class MemberHomeScreen extends StatelessWidget {
  const MemberHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with Greeting & Avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.between,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: KivoraColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text('K', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Kivora', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none, color: KivoraColors.textPrimary),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 4),
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: KivoraColors.primaryLight,
                        child: Icon(Icons.person, color: KivoraColors.primary, size: 22),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // User Title
              const Text('Good morning,', style: TextStyle(fontSize: 14, color: KivoraColors.textSecondary)),
              const Text(
                'Alex Johnson',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: KivoraColors.textPrimary),
              ),
              const Text(
                'Student • West Campus',
                style: TextStyle(fontSize: 13, color: KivoraColors.textMuted),
              ),
              const SizedBox(height: 20),

              // Inspirational Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Every presence\nbuilds a better\ntomorrow.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Today's Attendance Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: KivoraColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: KivoraColors.successSurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.check_circle, color: KivoraColors.success, size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Today's Attendance", style: TextStyle(fontSize: 12, color: KivoraColors.textSecondary)),
                          SizedBox(height: 2),
                          Text("Present", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: KivoraColors.textPrimary)),
                          Text("Checked in 08:02 AM", style: TextStyle(fontSize: 12, color: KivoraColors.success)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: KivoraColors.textMuted),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions Grid
              const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: KivoraColors.textPrimary)),
              const SizedBox(height: 12),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _QuickActionCard(
                    title: 'Check In',
                    icon: Icons.fingerprint,
                    color: KivoraColors.primary,
                    onTap: () => context.go('/member/attendance/check-in'),
                  ),
                  _QuickActionCard(
                    title: 'My Schedule',
                    icon: Icons.calendar_today_outlined,
                    color: Colors.blue,
                    onTap: () {},
                  ),
                  _QuickActionCard(
                    title: 'Attendance History',
                    icon: Icons.access_time,
                    color: Colors.teal,
                    onTap: () {},
                  ),
                  _QuickActionCard(
                    title: 'My Profile',
                    icon: Icons.person_outline,
                    color: Colors.indigo,
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarStyle.fixed,
        selectedItemColor: KivoraColors.primary,
        unselectedItemColor: KivoraColors.textMuted,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: KivoraColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: KivoraColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
