import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/auth_service.dart';

class AttendanceCorrectionScreen extends StatefulWidget {
  const AttendanceCorrectionScreen({super.key});

  @override
  State<AttendanceCorrectionScreen> createState() => _AttendanceCorrectionScreenState();
}

class _AttendanceCorrectionScreenState extends State<AttendanceCorrectionScreen> {
  final TextEditingController _sessionCtrl = TextEditingController(text: 'General Session');
  final TextEditingController _dateCtrl = TextEditingController();
  final TextEditingController _timeCtrl = TextEditingController(text: '05:00 PM');
  final TextEditingController _reasonCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    _dateCtrl.text = 'Today, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  void dispose() {
    _sessionCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final reason = _reasonCtrl.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please state a reason for the correction.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (AuthService().isLiveMode) {
        final client = Supabase.instance.client;
        final userId = AuthService().currentUserId;
        if (userId == null) throw Exception('No active user session');

        final recs = await client
            .from('attendance_records')
            .select('id')
            .eq('user_id', userId)
            .order('check_in_time', ascending: false)
            .limit(1);

        if (recs.isNotEmpty) {
          final recId = recs.first['id'];
          await client.from('correction_requests').insert({
            'attendance_record_id': recId,
            'user_id': userId,
            'reason': reason,
            'status': 'pending',
          });
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 400));
      }

      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance correction request submitted to branch manager.'),
            backgroundColor: Color(0xFF0D9488),
          ),
        );
        context.push('/member/requests');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission error: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Attendance Correction',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Missed Check-Out Correction',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 6),
              const Text(
                'Submit an auditable correction request if you missed check-in/out.',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 24),

              const Text('Session Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
              const SizedBox(height: 6),
              TextField(
                controller: _sessionCtrl,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                ),
              ),

              const SizedBox(height: 18),

              const Text('Session Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
              const SizedBox(height: 6),
              TextField(
                controller: _dateCtrl,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                ),
              ),

              const SizedBox(height: 18),

              const Text('Proposed Check-Out Time', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
              const SizedBox(height: 6),
              TextField(
                controller: _timeCtrl,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                ),
              ),

              const SizedBox(height: 18),

              const Text('Reason / Explanation', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
              const SizedBox(height: 6),
              TextField(
                controller: _reasonCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'State reason for missed check-out...',
                  hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2)),
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Submit Correction', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
