import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/kivora_service.dart';

class MembershipApprovalScreen extends StatefulWidget {
  final String? branchId;
  const MembershipApprovalScreen({super.key, this.branchId});

  @override
  State<MembershipApprovalScreen> createState() => _MembershipApprovalScreenState();
}

class _MembershipApprovalScreenState extends State<MembershipApprovalScreen> {
  int _selectedApplicationIndex = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    final activeBranchId = widget.branchId ?? KivoraService().currentBranchId ?? '';
    if (activeBranchId.isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        await KivoraService().fetchApplicationsForBranch(activeBranchId);
      } catch (e) {
        debugPrint('fetchApplicationsForBranch error: $e');
      }
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeBranchId = widget.branchId ?? KivoraService().currentBranchId ?? '';
    final pendingApps = KivoraService().getPendingApplications(activeBranchId).reversed.toList();

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
          'Membership Requests',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D9488)))
            : pendingApps.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF0FDFA),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle_outline, size: 54, color: Color(0xFF0D9488)),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Pending Applications',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'All submitted membership requests for this branch have been reviewed.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Applications Queue Selector
                    Text(
                      'Pending Requests (${pendingApps.length})',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 10),

                    SizedBox(
                      height: 48,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: pendingApps.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, idx) {
                          final app = pendingApps[idx];
                          final isSelected = _selectedApplicationIndex == idx;

                          return ChoiceChip(
                            label: Text(app.userName),
                            selected: isSelected,
                            selectedColor: const Color(0xFF0D9488),
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF334155),
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                            onSelected: (_) => setState(() => _selectedApplicationIndex = idx),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Detail review card for selected application
                    Builder(
                      builder: (context) {
                        final safeIdx = _selectedApplicationIndex < pendingApps.length ? _selectedApplicationIndex : 0;
                        final activeApp = pendingApps[safeIdx];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: const Color(0xFFE0F2F1),
                                    backgroundImage: (activeApp.photoUrl != null && activeApp.photoUrl!.isNotEmpty)
                                        ? NetworkImage(activeApp.photoUrl!)
                                        : null,
                                    child: (activeApp.photoUrl == null || activeApp.photoUrl!.isEmpty)
                                        ? Text(
                                            activeApp.userName.split(' ').map((n) => n.isNotEmpty ? n[0] : '').join(''),
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D9488), fontSize: 16),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          activeApp.userName,
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Applied to ${activeApp.branchName} • Code: ${activeApp.inviteCode}',
                                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Submitted Identification Data Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Submitted Identification Details',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                  ),
                                  const SizedBox(height: 16),

                                  _buildReviewRow('Full Name', activeApp.userName),
                                  const Divider(height: 20, color: Color(0xFFF1F5F9)),
                                  _buildReviewRow('Email Address', activeApp.userEmail),
                                  const Divider(height: 20, color: Color(0xFFF1F5F9)),
                                  _buildReviewRow(
                                    'Photo Provided',
                                    activeApp.photoAttached ? 'Yes (Verified Attached)' : 'No Photo',
                                  ),
                                  if (activeApp.photoUrl != null && activeApp.photoUrl!.isNotEmpty) ...[
                                    const Divider(height: 20, color: Color(0xFFF1F5F9)),
                                    const Text('Attached Identity Photograph', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        activeApp.photoUrl!,
                                        height: 120,
                                        width: 120,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Text('Could not load image preview', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                      ),
                                    ),
                                  ],

                                  ...activeApp.submittedData.entries.where((e) =>
                                      e.key != 'full_name' &&
                                      e.key != 'email' &&
                                      e.key != 'photo').map((entry) {
                                    return Column(
                                      children: [
                                        const Divider(height: 20, color: Color(0xFFF1F5F9)),
                                        _buildReviewRow(_formatKey(entry.key), entry.value?.toString() ?? '—'),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Decision Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      await KivoraService().rejectApplication(activeApp.id);
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Application for ${activeApp.userName} was rejected.'),
                                          backgroundColor: const Color(0xFFEF4444),
                                        ),
                                      );
                                      setState(() {
                                        _selectedApplicationIndex = 0;
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Color(0xFFEF4444)),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.close, color: Color(0xFFEF4444), size: 18),
                                        SizedBox(width: 6),
                                        Text('Reject', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await KivoraService().approveApplication(activeApp.id);
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Application for ${activeApp.userName} approved! Member is now active.'),
                                          backgroundColor: const Color(0xFF0D9488),
                                        ),
                                      );
                                      setState(() {
                                        _selectedApplicationIndex = 0;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0D9488),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      elevation: 0,
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check, color: Colors.white, size: 18),
                                        SizedBox(width: 6),
                                        Text('Approve', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  String _formatKey(String key) {
    if (key.contains('_')) {
      return key.split('_').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
    }
    return key;
  }

  Widget _buildReviewRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(label, style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
        ),
      ],
    );
  }
}
