import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VerificationLogsScreen extends StatefulWidget {
  const VerificationLogsScreen({super.key});

  @override
  State<VerificationLogsScreen> createState() => _VerificationLogsScreenState();
}

class _VerificationLogsScreenState extends State<VerificationLogsScreen> {
  int _selectedFilter = 0; // 0: All, 1: Biometric, 2: GPS, 3: Wi-Fi

  final List<Map<String, String>> _logs = [
    {
      'name': 'Sarah Johnson',
      'type': 'Biometric',
      'time': '8:02 AM',
      'outcome': 'Success',
    },
    {
      'name': 'Michael Brown',
      'type': 'GPS',
      'time': '7:58 AM',
      'outcome': 'Success',
    },
    {
      'name': 'Emily Davis',
      'type': 'Wi-Fi',
      'time': '7:45 AM',
      'outcome': 'Success',
    },
    {
      'name': 'James Wilson',
      'type': 'Biometric',
      'time': '7:32 AM',
      'outcome': 'Failed',
    },
    {
      'name': 'Olivia Martinez',
      'type': 'GPS',
      'time': '7:20 AM',
      'outcome': 'Success',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _logs.where((l) {
      if (_selectedFilter == 1) return l['type'] == 'Biometric';
      if (_selectedFilter == 2) return l['type'] == 'GPS';
      if (_selectedFilter == 3) return l['type'] == 'Wi-Fi';
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
          'Verification Logs',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _buildFilterTab('All', 0),
                const SizedBox(width: 8),
                _buildFilterTab('Biometric', 1),
                const SizedBox(width: 8),
                _buildFilterTab('GPS', 2),
                const SizedBox(width: 8),
                _buildFilterTab('Wi-Fi', 3),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Logs
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final log = filtered[index];
                final isSuccess = log['outcome'] == 'Success';

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFFE0F2F1),
                        child: Text(
                          log['name']!.split(' ').map((n) => n[0]).join(''),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log['name']!,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${log['type']} • ${log['time']}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSuccess ? const Color(0xFFECFDF5) : const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          log['outcome']!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSuccess ? const Color(0xFF059669) : const Color(0xFFDC2626),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String title, int index) {
    final isSelected = _selectedFilter == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0D9488) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
