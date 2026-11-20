import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/auth_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedTabIndex = 0; // 0: All, 1: Attendance, 2: System
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadLiveNotifications();
  }

  Future<void> _loadLiveNotifications() async {
    final userId = AuthService().currentUserId;
    if (userId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No authenticated user session. Please sign in to view notifications.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final client = Supabase.instance.client;
      final res = await client
          .from('notifications')
          .select('id, category, title, body, is_read, created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final list = (res as List).map((row) {
        final category = (row['category']?.toString() ?? 'system').toLowerCase();
        final isRead = row['is_read'] == true;
        final createdAt = DateTime.tryParse(row['created_at']?.toString() ?? '');
        final timeStr = _formatNotificationTime(createdAt);

        return {
          'id': row['id']?.toString() ?? '',
          'title': row['title']?.toString() ?? 'Notification',
          'body': row['body']?.toString() ?? '',
          'time': timeStr,
          'type': category == 'attendance' ? 'attendance' : 'system',
          'icon': _getCategoryIcon(category),
          'color': _getCategoryColor(category),
          'isUnread': !isRead,
        };
      }).toList();

      if (mounted) {
        setState(() {
          _notifications = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[Kivora] Error loading notifications: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load notifications from database: $e';
        });
      }
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'attendance':
        return Icons.check_circle_outline;
      case 'announcement':
        return Icons.campaign_outlined;
      case 'request':
        return Icons.swap_horiz_outlined;
      default:
        return Icons.notifications_none_outlined;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'attendance':
        return const Color(0xFF10B981);
      case 'announcement':
        return const Color(0xFF0D9488);
      case 'request':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  String _formatNotificationTime(DateTime? created) {
    if (created == null) return 'Recently';
    final now = DateTime.now();
    final diff = now.difference(created);
    if (diff.inMinutes < 60) {
      final mins = diff.inMinutes.clamp(1, 59);
      return '$mins min${mins > 1 ? 's' : ''} ago';
    } else if (diff.inHours < 24 && created.day == now.day) {
      final hour = created.hour % 12 == 0 ? 12 : created.hour % 12;
      final ampm = created.hour >= 12 ? 'PM' : 'AM';
      final min = created.minute.toString().padLeft(2, '0');
      return '$hour:$min $ampm';
    } else if (diff.inDays < 2) {
      return 'Yesterday';
    } else {
      return '${diff.inDays} days ago';
    }
  }

  Future<void> _markAsRead(Map<String, dynamic> item) async {
    if (item['isUnread'] != true) return;

    final notifId = item['id'] as String;
    setState(() {
      item['isUnread'] = false;
    });

    try {
      final client = Supabase.instance.client;
      await client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notifId);
    } catch (e) {
      debugPrint('[Kivora] Error updating notification read state: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _notifications.where((n) {
      if (_selectedTabIndex == 1) return n['type'] == 'attendance';
      if (_selectedTabIndex == 2) return n['type'] == 'system';
      return true;
    }).toList();

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
          'Notifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Color(0xFF64748B)),
            onPressed: () => context.push('/member/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Segmented filter tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _buildTab('All', 0),
                const SizedBox(width: 8),
                _buildTab('Attendance', 1),
                const SizedBox(width: 8),
                _buildTab('System', 2),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Notifications List / Error / Empty
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D9488)))
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cloud_off, size: 48, color: Color(0xFFEF4444)),
                              const SizedBox(height: 12),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _loadLiveNotifications,
                                icon: const Icon(Icons.refresh, size: 16),
                                label: const Text('Retry Connection'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0D9488),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadLiveNotifications,
                        color: const Color(0xFF0D9488),
                        child: filtered.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: const [
                                  SizedBox(height: 120),
                                  Center(
                                    child: Column(
                                      children: [
                                        Icon(Icons.notifications_off_outlined, size: 48, color: Color(0xFF94A3B8)),
                                        SizedBox(height: 12),
                                        Text(
                                          'No notifications yet',
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          'You will be notified here about attendance confirmations and branch announcements.',
                                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final item = filtered[index];
                                  final isUnread = item['isUnread'] == true;

                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isUnread ? const Color(0xFFCCFBF1) : const Color(0xFFE2E8F0),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.02),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      leading: Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: (item['color'] as Color).withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 22),
                                      ),
                                      title: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item['title'] as String,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                                color: const Color(0xFF0F172A),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (isUnread)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF0D9488),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text(
                                            item['body'] as String,
                                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item['time'] as String,
                                            style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                                          ),
                                        ],
                                      ),
                                      trailing: const Icon(Icons.chevron_right, size: 18, color: Color(0xFFCBD5E1)),
                                      onTap: () => _markAsRead(item),
                                    ),
                                  );
                                },
                              ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D9488) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
