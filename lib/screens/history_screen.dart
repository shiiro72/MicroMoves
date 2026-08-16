import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../widgets/monthly_calendar.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final history = appState.history;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MonthlyCalendar(history: history),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5722),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? Colors.white70 : Colors.black87, width: 2),
                    ),
                    child: const Text(
                      'Activity Log',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (history.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 36.0, horizontal: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE082),
                            shape: BoxShape.circle,
                            border: Border.all(color: isDark ? Colors.white70 : Colors.black87, width: 2.5),
                          ),
                          child: const Icon(
                            Icons.history_rounded,
                            size: 48,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No history yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Completed exercises will appear here.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: history.map((entry) {
                    final timestamp = DateTime.tryParse(entry.timestamp);
                    final formattedTime = timestamp != null
                        ? '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')} • '
                            '${_getMonthName(timestamp.month)} ${timestamp.day}, ${timestamp.year}'
                        : entry.timestamp;

                    IconData iconData;
                    Color iconBgColor;
                    String statusLabel;

                    switch (entry.status) {
                      case 'completed':
                        iconData = Icons.check_circle_rounded;
                        iconBgColor = const Color(0xFF4CAF50);
                        statusLabel = 'Completed';
                        break;
                      case 'skipped':
                        iconData = Icons.skip_next_rounded;
                        iconBgColor = const Color(0xFFFF9800);
                        statusLabel = 'Skipped';
                        break;
                      case 'snoozed':
                        iconData = Icons.snooze_rounded;
                        iconBgColor = const Color(0xFFFFC107);
                        statusLabel = 'Snoozed';
                        break;
                      case 'dismissed':
                        iconData = Icons.close_rounded;
                        iconBgColor = const Color(0xFFF44336);
                        statusLabel = 'Dismissed';
                        break;
                      default:
                        iconData = Icons.help_outline_rounded;
                        iconBgColor = Colors.grey;
                        statusLabel = 'Unknown';
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? Colors.white24 : Colors.black87,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: iconBgColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black87, width: 2),
                              ),
                              child: Icon(
                                iconData,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.exerciseName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${entry.category} • $statusLabel',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: iconBgColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    formattedTime,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (entry.status == 'completed')
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE082),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.black87, width: 2),
                                ),
                                child: Text(
                                  '${entry.value}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }
}
