import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MicroMoves'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Streak Card
            Card(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF5252),
                      Color(0xFFFF9800),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black87, width: 2.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_fire_department,
                        color: Color(0xFFFF5722),
                        size: 52,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${appState.currentStreak} Day Streak',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            offset: Offset(1.5, 1.5),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Keep moving to maintain your streak!',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Statistics row (Completed & Skipped)
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: isDark ? const Color(0xFF1B382B) : const Color(0xFFE8F5E9),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2E7D32) : const Color(0xFFA5D6A7),
                              shape: BoxShape.circle,
                              border: Border.all(color: isDark ? Colors.white54 : Colors.black87, width: 2),
                            ),
                            child: const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Completed Today',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${appState.completedTodayCount}',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    color: isDark ? const Color(0xFF3E2723) : const Color(0xFFFFF3E0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFFD84315) : const Color(0xFFFFCC80),
                              shape: BoxShape.circle,
                              border: Border.all(color: isDark ? Colors.white54 : Colors.black87, width: 2),
                            ),
                            child: const Icon(
                              Icons.skip_next_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Skipped Today',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${appState.skippedTodayCount}',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: isDark ? const Color(0xFFFFB74D) : const Color(0xFFE65100),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Reminder Trigger Simulation Card
            Card(
              color: isDark ? const Color(0xFF263238) : const Color(0xFFE0F7FA),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB300),
                        shape: BoxShape.circle,
                        border: Border.all(color: isDark ? Colors.white70 : Colors.black87, width: 2),
                      ),
                      child: const Icon(
                        Icons.timer_rounded,
                        color: Colors.black87,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ready for a break?',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Trigger a mock reminder notification to test your workout logic and progress rules!',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey.shade300 : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        appState.triggerReminder();
                      },
                      icon: const Icon(Icons.notifications_active_rounded),
                      label: const Text('Simulate Reminder Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5722),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isDark ? Colors.white70 : Colors.black87,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
