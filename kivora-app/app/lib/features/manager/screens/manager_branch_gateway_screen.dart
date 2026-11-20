import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/kivora_service.dart';

class ManagerBranchGatewayScreen extends StatelessWidget {
  const ManagerBranchGatewayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/welcome');
            }
          },
        ),
        title: const Text(
          'Branch & Membership Choice',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              // Header Illustration Graphic
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFCCFBF1), width: 1.5),
                ),
                child: const Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.domain_add, size: 48, color: Color(0xFF0D9488)),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Welcome to Kivora',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose how you want to get started with your workspace.',
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.4),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Option A: Join an Existing Branch
              InkWell(
                onTap: () => context.push('/branch/discover'),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF0D9488), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0D9488).withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDFA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.group_add_outlined, color: Color(0xFF0D9488), size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Join an Existing Branch',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                ),
                                Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'For members, students, teachers, and staff joining an established campus or organization using a branch code or search.',
                              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.35),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Recommended for Members',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF059669)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Option B: Create a New Branch
              InkWell(
                onTap: () => context.push('/manager/branch/new'),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.add_business_outlined, color: Color(0xFF334155), size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Create a New Branch',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                ),
                                Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'For authorized branch managers and institution administrators setting up a new campus, facility, or branch office.',
                              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.35),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'For Branch Managers & Admins',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Returning User Quick Actions
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Returning User?',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.go('/member/home'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: const Text(
                              'Member Home',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final service = KivoraService();
                              if (service.isManagerOrAdmin) {
                                context.go('/manager/dashboard');
                                return;
                              }
                              if (AuthService().isLiveMode && AuthService().checkSupabaseReady()) {
                                try {
                                  await service.resolveLiveUserState();
                                  if (context.mounted && service.isManagerOrAdmin) {
                                    context.go('/manager/dashboard');
                                    return;
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to load manager assignment: $e'),
                                        backgroundColor: const Color(0xFFEF4444),
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                  return;
                                }
                              }
                              if (context.mounted) {
                                if (service.isManagerOrAdmin) {
                                  context.go('/manager/dashboard');
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('No active manager assignment found for this account.'),
                                      backgroundColor: Color(0xFFEF4444),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: const Text(
                              'Manager Dash',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.push('/branch/status'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: const Text(
                              'Check Status',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: () async {
                  await AuthService().signOut();
                  if (context.mounted) {
                    context.go('/welcome');
                  }
                },
                icon: const Icon(Icons.logout, size: 16, color: Color(0xFF94A3B8)),
                label: const Text(
                  'Sign out & return to welcome',
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

