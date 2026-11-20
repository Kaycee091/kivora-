import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/kivora_service.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  int _bottomNavIndex = 0;
  bool _isLoadingBranch = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentBranch();
  }

  Future<void> _loadCurrentBranch() async {
    setState(() => _isLoadingBranch = true);
    try {
      if (KivoraService().currentBranchId == null) {
        await KivoraService().fetchCurrentBranch();
      }
      final bId = KivoraService().currentBranchId;
      if (bId != null) {
        await Future.wait([
          KivoraService().fetchBranchMembers(bId),
          KivoraService().fetchApplicationsForBranch(bId),
        ]);
      }
    } catch (e) {
      debugPrint('Dashboard branch fetch note: $e');
    }
    if (mounted) {
      setState(() => _isLoadingBranch = false);
    }
  }

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
                      if (AuthService().isDemoMode) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFF59E0B)),
                          ),
                          child: const Text(
                            'DEMO',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.swap_horiz, color: Color(0xFF64748B)),
                        tooltip: 'Switch to Member View',
                        onPressed: () {
                          KivoraService().setCurrentUser(
                            email: KivoraService().currentUserEmail.isNotEmpty
                                ? KivoraService().currentUserEmail
                                : 'member@kivora.org',
                            name: KivoraService().currentUserName.isNotEmpty
                                ? KivoraService().currentUserName
                                : 'Member User',
                            role: 'member',
                            branchId: KivoraService().currentBranchId,
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

              // Greeting & Branch Identity
              const Text(
                'Good morning,',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              Text(
                KivoraService().currentUserName.isNotEmpty
                    ? KivoraService().currentUserName
                    : 'Branch Manager',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              Builder(
                builder: (context) {
                  if (_isLoadingBranch) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Text('Loading branch details...', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                    );
                  }
                  final branchId = KivoraService().currentBranchId;
                  final branch = branchId != null ? KivoraService().getBranchById(branchId) : null;
                  final displayBranch = branch != null ? '${branch.name} Branch' : 'No branch assigned';
                  final inviteCode = branch?.inviteCode ?? '';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayBranch,
                        style: TextStyle(
                          fontSize: 12,
                          color: branch != null ? const Color(0xFF0D9488) : const Color(0xFF94A3B8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (branch != null && inviteCode.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDFA),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF99F6E4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.vpn_key_outlined, size: 13, color: Color(0xFF0D9488)),
                              const SizedBox(width: 6),
                              Text(
                                'Invite Code: $inviteCode',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F766E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // If No Branch Assigned, Show Actionable Setup Banner
              Builder(
                builder: (context) {
                  final branchId = KivoraService().currentBranchId;
                  final branch = branchId != null ? KivoraService().getBranchById(branchId) : null;
                  if (branch != null) return const SizedBox.shrink();

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDFA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF99F6E4)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCCFBF1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.add_business_outlined, color: Color(0xFF0D9488), size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Establish Your Branch',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Create a branch to start registering members and tracking verified attendance.',
                                style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () => context.push('/manager/branch/new'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0D9488),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Create Branch',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // KPI Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Registered Members',
                      count: KivoraService().members.length.toString(),
                      icon: Icons.people_outline,
                      color: const Color(0xFF0D9488),
                      bg: const Color(0xFFF0FDFA),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Verified Logs',
                      count: KivoraService().attendanceRecords.length.toString(),
                      icon: Icons.verified_outlined,
                      color: const Color(0xFF6366F1),
                      bg: const Color(0xFFEEF2FF),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Pending Approvals',
                      count: KivoraService().applications.where((a) => a.status == 'pending').length.toString(),
                      icon: Icons.pending_actions_outlined,
                      color: const Color(0xFFF59E0B),
                      bg: const Color(0xFFFFFBEB),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Active Branches',
                      count: KivoraService().branches.length.toString(),
                      icon: Icons.apartment,
                      color: const Color(0xFF10B981),
                      bg: const Color(0xFFECFDF5),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Fast Action Operations
              const Text(
                'Manager Actions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 14),

              _buildActionTile(
                icon: Icons.person_add_outlined,
                title: 'Review Membership Applications',
                subtitle: 'Approve or reject prospective branch members',
                onTap: () => context.push('/manager/requests/membership'),
              ),
              const SizedBox(height: 10),

              _buildActionTile(
                icon: Icons.badge_outlined,
                title: 'ID Form Configuration',
                subtitle: 'Customize membership fields and required ID uploads',
                onTap: () {
                  final branchId = KivoraService().currentBranchId;
                  context.push('/manager/settings/id-form', extra: {'branchId': branchId});
                },
              ),
              const SizedBox(height: 10),

              _buildActionTile(
                icon: Icons.qr_code_scanner_outlined,
                title: 'Generate Branch Invite Code',
                subtitle: 'Create onboarding codes for students or staff',
                onTap: () {
                  final branchId = KivoraService().currentBranchId;
                  context.push('/manager/invites/generate', extra: {'branchId': branchId});
                },
              ),
              const SizedBox(height: 10),

              _buildActionTile(
                icon: Icons.history_toggle_off,
                title: 'Attendance Sign-In Logs',
                subtitle: 'Review immutable timestamps and verification modalities',
                onTap: () => context.push('/manager/attendance/logs'),
              ),
              const SizedBox(height: 10),

              _buildActionTile(
                icon: Icons.security,
                title: 'Delegated Roles & Permissions',
                subtitle: 'Manage administrative privileges and access levels',
                onTap: () => context.push('/manager/settings/roles'),
              ),
              const SizedBox(height: 10),

              _buildActionTile(
                icon: Icons.domain,
                title: 'Branch Workspace Details',
                subtitle: 'View branch address, contact info, and settings',
                onTap: () {
                  final branchId = KivoraService().currentBranchId;
                  context.push('/member/branch', extra: {'branchId': branchId});
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        selectedItemColor: const Color(0xFF0D9488),
        unselectedItemColor: const Color(0xFF94A3B8),
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _bottomNavIndex = index);
          if (index == 1) context.push('/manager/members');
          if (index == 2) context.push('/manager/attendance/logs');
          if (index == 3) context.push('/manager/settings/branch');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Members'),
          BottomNavigationBarItem(icon: Icon(Icons.fact_check_outlined), label: 'Attendance'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            count,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF0D9488), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 13, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }
}
