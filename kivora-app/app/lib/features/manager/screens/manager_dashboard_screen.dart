import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/kivora_service.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  int _bottomNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Brand / User Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            'K',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Kivora',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.swap_horiz, color: Color(0xFF64748B)),
                        tooltip: 'Switch to Member View',
                        onPressed: () {
                          KivoraService().setCurrentUser(
                            email: 'alex.johnson@kivora.edu.ng',
                            name: 'Alex Johnson',
                            role: 'member',
                            branchId: 'branch-west',
                          );
                          context.go('/member/home');
                        },
                      ),
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFFE0F2F1),
                        child: Text(
                          'BM',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Greeting
              const Text(
                'Good morning,',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const Text(
                'Branch Manager',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              Builder(
                builder: (context) {
                  final branchId = KivoraService().currentBranchId;
                  final branch = branchId != null ? KivoraService().getBranchById(branchId) : null;
                  final displayBranch = branch != null ? '${branch.name} Branch' : 'No branch assigned';
                  return Text(
                    displayBranch,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF0D9488), fontWeight: FontWeight.w600),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Total Members Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F766E).withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Total Members',
                          style: TextStyle(fontSize: 13, color: Color(0xFFCCFBF1), fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 6),
                        Text(
                          '48',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ],
                    ),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.people_outline, color: Colors.white, size: 28),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2x2 Stats Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.4,
                children: [
                  _buildStatTile(
                    label: 'Pending Requests',
                    value: '5',
                    icon: Icons.pending_actions_outlined,
                    color: const Color(0xFFF59E0B),
                    onTap: () => context.push('/manager/requests/membership'),
                  ),
                  _buildStatTile(
                    label: "Today's Attendance",
                    value: '42',
                    icon: Icons.check_circle_outline,
                    color: const Color(0xFF10B981),
                    onTap: () => context.push('/manager/attendance/logs'),
                  ),
                  _buildStatTile(
                    label: 'Early Leave Requests',
                    value: '2',
                    icon: Icons.timer_outlined,
                    color: const Color(0xFFEF4444),
                    onTap: () => context.push('/manager/requests/early-leave'),
                  ),
                  _buildStatTile(
                    label: 'Active Classes/Shifts',
                    value: '6',
                    icon: Icons.calendar_month_outlined,
                    color: const Color(0xFF3B82F6),
                    onTap: () => context.push('/manager/schedules'),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickAction(
                    icon: Icons.qr_code,
                    label: 'Create\nInvite Code',
                    onTap: () => context.push('/manager/invites/generate'),
                  ),
                  _buildQuickAction(
                    icon: Icons.people_outline,
                    label: 'View\nMembers',
                    onTap: () => context.push('/manager/members'),
                  ),
                  _buildQuickAction(
                    icon: Icons.assignment_outlined,
                    label: 'Attendance\nLogs',
                    onTap: () => context.push('/manager/attendance/logs'),
                  ),
                  _buildQuickAction(
                    icon: Icons.campaign_outlined,
                    label: 'Send\nAnnouncement',
                    onTap: () => context.push('/manager/announcements/new'),
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
        selectedItemColor: const Color(0xFF0D9488),
        unselectedItemColor: const Color(0xFF94A3B8),
        onTap: (index) {
          setState(() => _bottomNavIndex = index);
          if (index == 1) context.push('/manager/members');
          if (index == 2) context.push('/manager/attendance/logs');
          if (index == 3) context.push('/manager/reports');
          if (index == 4) context.push('/manager/settings/branch');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Members'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Attendance'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, color: color, size: 18),
              ],
            ),
            Text(
              value,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDFA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFCCFBF1)),
              ),
              child: Icon(icon, color: const Color(0xFF0D9488), size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
