import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/kivora_service.dart';

class JoinRequestStatusScreen extends StatefulWidget {
  final String? branchId;
  final String? branchName;
  final String? userName;

  const JoinRequestStatusScreen({
    super.key,
    this.branchId,
    this.branchName,
    this.userName,
  });

  @override
  State<JoinRequestStatusScreen> createState() => _JoinRequestStatusScreenState();
}

class _JoinRequestStatusScreenState extends State<JoinRequestStatusScreen> {
  bool _isChecking = false;
  late String _branchName;
  String _status = 'pending';
  MembershipApplicationModel? _app;

  @override
  void initState() {
    super.initState();
    _branchName = widget.branchName ??
        (KivoraService().currentBranchId != null
            ? KivoraService().getBranchById(KivoraService().currentBranchId!)?.name
            : null) ??
        'Branch';
    _refreshStatus();
  }

  Future<void> _refreshStatus() async {
    final service = KivoraService();

    // In LIVE mode: query Supabase for verified assignment or active request
    if (AuthService().isLiveMode && AuthService().checkSupabaseReady()) {
      try {
        final client = Supabase.instance.client;
        final currentUserId = client.auth.currentUser?.id;

        if (currentUserId != null) {
          // 1. Check user_branch_assignments for approved/active status
          final assignment = await client
              .from('user_branch_assignments')
              .select('branch_id, role, is_active, branches(id, name)')
              .eq('user_id', currentUserId)
              .eq('is_active', true)
              .maybeSingle();

          if (assignment != null) {
            _status = 'approved';
            service.setMembershipStatus('approved');
            final b = assignment['branches'] as Map<String, dynamic>?;
            if (b != null && b['name'] != null) {
              _branchName = b['name'] as String;
              final bId = b['id'] as String? ?? assignment['branch_id'] as String;
              service.setCurrentBranchId(bId);
            }
            if (mounted) setState(() {});
            return;
          }

          // 2. Check branch_membership_requests for latest status
          final req = await client
              .from('branch_membership_requests')
              .select('id, status, branch_id, branches(id, name)')
              .eq('user_id', currentUserId)
              .order('created_at', ascending: false)
              .limit(1)
              .maybeSingle();

          if (req != null) {
            _status = req['status'] as String? ?? 'pending';
            service.setMembershipStatus(_status);
            final b = req['branches'] as Map<String, dynamic>?;
            if (b != null && b['name'] != null) {
              _branchName = b['name'] as String;
            }
            if (mounted) setState(() {});
            return;
          }
        }
      } catch (e) {
        debugPrint('JoinRequestStatusScreen Supabase error: $e');
      }
    }

    // In-memory fallback
    final app = service.currentApplication ??
        (service.applications.isNotEmpty ? service.applications.last : null);

    if (app != null) {
      _app = app;
      _branchName = app.branchName;
      _status = app.status;
      if (mounted) setState(() {});
    }
  }

  Future<void> _checkStatus() async {
    setState(() => _isChecking = true);
    await _refreshStatus();
    if (!mounted) return;
    setState(() => _isChecking = false);

    if (_status == 'approved') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Congratulations! Your application has been approved by the Branch Manager.'),
          backgroundColor: Color(0xFF0D9488),
        ),
      );
    } else if (_status == 'rejected') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your application was not approved. Please contact your administrator.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your application is still under review by the Branch Manager.'),
          backgroundColor: Color(0xFF0F766E),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isApproved = _status == 'approved';
    final isRejected = _status == 'rejected';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => context.canPop() ? context.pop() : context.go('/branch/gateway'),
        ),
        title: const Text(
          'Application Status',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // Status Icon Graphic
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: isApproved
                      ? const Color(0xFFECFDF5)
                      : (isRejected ? const Color(0xFFFEF2F2) : const Color(0xFFE0F2F1)),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    isApproved
                        ? Icons.check_circle_outline
                        : (isRejected ? Icons.cancel_outlined : Icons.access_time_filled),
                    size: 60,
                    color: isApproved
                        ? const Color(0xFF059669)
                        : (isRejected ? const Color(0xFFDC2626) : const Color(0xFF0F766E)),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Text(
                isApproved
                    ? 'Application Approved!'
                    : (isRejected ? 'Application Not Approved' : 'Your account is\nawaiting approval'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  height: 1.25,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 14),

              // Branch & Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.apartment, size: 16, color: Color(0xFF0D9488)),
                    const SizedBox(width: 6),
                    Text(
                      _branchName,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Color(0xFF94A3B8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isApproved ? 'Approved' : (isRejected ? 'Rejected' : 'Pending Review'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isApproved
                            ? const Color(0xFF059669)
                            : (isRejected ? const Color(0xFFDC2626) : const Color(0xFFD97706)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Text(
                isApproved
                    ? 'Your membership has been officially approved. You now have full access to your member dashboard.'
                    : (isRejected
                        ? 'Your registration was reviewed and not accepted. Please verify your invitation details or re-apply.'
                        : 'Your registration has been submitted. A branch administrator must review and approve your account before membership becomes active.'),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 36),

              if (isApproved) ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => context.go('/member/home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Proceed to Member Home',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ] else if (isRejected) ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => context.go('/branch/discover'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF0D9488)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Try Another Invitation Code',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                    ),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isChecking ? null : _checkStatus,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isChecking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Check Status',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.refresh, size: 18, color: Colors.white),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                // Demo helper button allowing testing approval lifecycle directly
                TextButton.icon(
                  onPressed: () {
                    if (_app != null) {
                      KivoraService().approveApplication(_app!.id);
                    } else if (KivoraService().applications.isNotEmpty) {
                      KivoraService().approveApplication(KivoraService().applications.first.id);
                    }
                    setState(() => _refreshStatus());
                  },
                  icon: const Icon(Icons.verified, size: 16, color: Color(0xFF0D9488)),
                  label: const Text(
                    'Simulate Branch Manager Approval (Demo)',
                    style: TextStyle(fontSize: 12.5, color: Color(0xFF0D9488), fontWeight: FontWeight.w600),
                  ),
                ),
              ],

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
