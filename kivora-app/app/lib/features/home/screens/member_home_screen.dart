import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/kivora_theme.dart';
import '../../../core/services/kivora_service.dart';

class MemberHomeScreen extends StatefulWidget {
  const MemberHomeScreen({super.key});

  @override
  State<MemberHomeScreen> createState() => _MemberHomeScreenState();
}

class _MemberHomeScreenState extends State<MemberHomeScreen> {
  int _bottomNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with Greeting, Role Switcher & Avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: KivoraColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text('K', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Kivora', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: KivoraColors.textPrimary)),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.swap_horiz, color: Color(0xFF64748B)),
                        tooltip: 'Switch to Branch Manager View',
                        onPressed: () => context.go('/manager/dashboard'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_none, color: KivoraColors.textPrimary),
                        tooltip: 'Notifications',
                        onPressed: () => context.push('/member/notifications'),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => context.push('/member/profile'),
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: KivoraColors.primaryLight,
                          child: Icon(Icons.person, color: KivoraColors.primary, size: 22),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // User Title & Branch
              GestureDetector(
                onTap: () => context.push('/member/profile'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Good morning,', style: TextStyle(fontSize: 14, color: KivoraColors.textSecondary)),
                    Text(
                      KivoraService().currentUserName.isNotEmpty ? KivoraService().currentUserName : 'Alex Johnson',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: KivoraColors.textPrimary),
                    ),
                    Builder(
                      builder: (context) {
                        final branchId = KivoraService().currentBranchId;
                        final branch = branchId != null ? KivoraService().getBranchById(branchId) : null;
                        final displayBranch = branch != null ? 'Student • ${branch.name}' : 'Student • Member';
                        return Text(
                          displayBranch,
                          style: const TextStyle(fontSize: 13, color: KivoraColors.primary, fontWeight: FontWeight.w600),
                        );
                      },
                    ),
                  ],
                ),
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
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0D9488).withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
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

              // Today's Attendance Card (Clickable to History)
              GestureDetector(
                onTap: () => context.push('/member/attendance/history'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: KivoraColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
                            Text("Checked in 08:02 AM • Verified", style: TextStyle(fontSize: 12, color: KivoraColors.success)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: KivoraColors.textMuted),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions Grid Header & Link
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: KivoraColors.textPrimary)),
                  TextButton(
                    onPressed: () => context.push('/member/search'),
                    child: const Text('View All', style: TextStyle(fontSize: 13, color: KivoraColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 2x3 Quick Actions Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _QuickActionCard(
                    title: 'Check In',
                    icon: Icons.fingerprint,
                    color: KivoraColors.primary,
                    onTap: () => context.push('/member/attendance/check-in'),
                  ),
                  _QuickActionCard(
                    title: 'My Schedule',
                    icon: Icons.calendar_today_outlined,
                    color: Colors.blue,
                    onTap: () => context.push('/member/schedule'),
                  ),
                  _QuickActionCard(
                    title: 'Attendance History',
                    icon: Icons.access_time,
                    color: Colors.teal,
                    onTap: () => context.push('/member/attendance/history'),
                  ),
                  _QuickActionCard(
                    title: 'Digital ID Card',
                    icon: Icons.badge_outlined,
                    color: Colors.indigo,
                    onTap: () => context.push('/member/digital-id'),
                  ),
                  _QuickActionCard(
                    title: 'Request Leave',
                    icon: Icons.event_note_outlined,
                    color: Colors.orange,
                    onTap: () => context.push('/member/requests/leave/new'),
                  ),
                  _QuickActionCard(
                    title: 'My Profile',
                    icon: Icons.person_outline,
                    color: Colors.purple,
                    onTap: () => context.push('/member/profile'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: KivoraColors.primary,
        unselectedItemColor: KivoraColors.textMuted,
        onTap: (index) {
          setState(() => _bottomNavIndex = index);
          if (index == 0) context.go('/member/home');
          if (index == 1) context.push('/member/schedule');
          if (index == 2) context.push('/member/attendance/history');
          if (index == 3) context.push('/member/profile');
        },
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: KivoraColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
