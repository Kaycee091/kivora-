import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/kivora_service.dart';

class SendAnnouncementScreen extends StatefulWidget {
  const SendAnnouncementScreen({super.key});

  @override
  State<SendAnnouncementScreen> createState() => _SendAnnouncementScreenState();
}

class _SendAnnouncementScreenState extends State<SendAnnouncementScreen> {
  bool _isLoading = false;
  final List<Map<String, String>> _announcements = [];

  final List<Map<String, String>> _demoAnnouncements = [
    {
      'sender': 'Admin',
      'scope': 'All Members • Apr 16, 2025',
      'message': 'Staff meeting at 10 AM tomorrow.',
    },
    {
      'sender': 'Branch Manager',
      'scope': 'All Members • Apr 15, 2025',
      'message': 'Please remember to submit your weekly reports.',
    },
    {
      'sender': 'Admin',
      'scope': 'Students • Apr 14, 2025',
      'message': 'No classes on Friday.',
    },
  ];

  @override
  void initState() {
    super.initState();
    if (AuthService().isDemoMode) {
      _announcements.addAll(_demoAnnouncements);
    } else {
      _loadLiveAnnouncements();
    }
  }

  Future<void> _loadLiveAnnouncements() async {
    final branchId = KivoraService().currentBranchId;
    if (branchId == null) return;

    setState(() => _isLoading = true);
    try {
      final client = Supabase.instance.client;
      final res = await client
          .from('announcements')
          .select('id, title, content, created_at, target_role, profiles(full_name)')
          .eq('branch_id', branchId)
          .order('created_at', ascending: false);

      final list = (res as List).map((row) {
        final profile = row['profiles'] as Map<String, dynamic>?;
        final sender = profile?['full_name'] as String? ?? 'Branch Manager';
        final role = row['target_role'] ?? 'all';
        final createdAt = DateTime.tryParse(row['created_at']?.toString() ?? '');
        final dateStr = createdAt != null
            ? '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}'
            : 'Recent';

        return {
          'id': row['id']?.toString() ?? '',
          'sender': sender,
          'scope': '$role • $dateStr',
          'message': row['content']?.toString() ?? (row['title']?.toString() ?? ''),
        };
      }).toList();

      if (mounted) {
        setState(() {
          _announcements.clear();
          _announcements.addAll(list);
        });
      }
    } catch (e) {
      debugPrint('[Kivora] Error loading announcements: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showNewAnnouncementDialog() {
    final titleCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Announcement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: TextField(
          controller: titleCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter announcement text...',
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = titleCtrl.text.trim();
              if (text.isEmpty) return;

              Navigator.pop(ctx);

              if (AuthService().isLiveMode) {
                final branchId = KivoraService().currentBranchId;
                final userId = AuthService().currentUserId;
                if (branchId != null && userId != null) {
                  try {
                    await Supabase.instance.client.from('announcements').insert({
                      'branch_id': branchId,
                      'author_id': userId,
                      'title': 'Branch Notice',
                      'content': text,
                      'target_role': 'all',
                    });
                    await _loadLiveAnnouncements();
                  } catch (e) {
                    debugPrint('Error broadcasting announcement: $e');
                  }
                }
              } else {
                setState(() {
                  _announcements.insert(0, {
                    'sender': 'Branch Manager',
                    'scope': 'All Members • Today',
                    'message': text,
                  });
                });
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Announcement broadcasted.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488)),
            child: const Text('Broadcast', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

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
          'Announcements',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // New Announcement Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _showNewAnnouncementDialog,
                icon: const Icon(Icons.campaign, color: Colors.white, size: 20),
                label: const Text(
                  'New Announcement',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),

            const SizedBox(height: 24),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: Color(0xFF0D9488)),
                ),
              )
            else if (_announcements.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: const [
                    Icon(Icons.campaign_outlined, size: 48, color: Color(0xFF94A3B8)),
                    SizedBox(height: 12),
                    Text(
                      'No announcements yet',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Broadcast an announcement to your branch members above.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              // Announcements feed
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _announcements.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final a = _announcements[index];
                  final sender = a['sender'] ?? 'Admin';
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: const Color(0xFFE0F2F1),
                          child: Text(
                            sender.isNotEmpty ? sender[0].toUpperCase() : 'A',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sender,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                a['scope'] ?? '',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                a['message'] ?? '',
                                style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
