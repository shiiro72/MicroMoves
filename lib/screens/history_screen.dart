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
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
              child: Text(
                'Activity Log',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
            if (history.isEmpty)
              SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No history yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Completed exercises will appear here.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...history.map((entry) {
                final timestamp = DateTime.tryParse(entry.timestamp);
                final formattedTime = timestamp != null
                    ? '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')} • '
                        '${_getMonthName(timestamp.month)} ${timestamp.day}, ${timestamp.year}'
                    : entry.timestamp;

                IconData iconData;
                Color iconColor;
                String statusLabel;

                switch (entry.status) {
                  case 'completed':
                    iconData = Icons.check_circle_outline;
                    iconColor = Colors.green.shade600;
                    statusLabel = 'Completed';
                    break;
                  case 'skipped':
                    iconData = Icons.skip_next_outlined;
                    iconColor = Colors.orange.shade600;
                    statusLabel = 'Skipped';
                    break;
                  case 'snoozed':
                    iconData = Icons.snooze_outlined;
                    iconColor = Colors.amber.shade700;
                    statusLabel = 'Snoozed';
                    break;
                  case 'dismissed':
                    iconData = Icons.close_outlined;
                    iconColor = Colors.red.shade600;
                    statusLabel = 'Dismissed';
                    break;
                  default:
                    iconData = Icons.help_outline;
                    iconColor = Colors.grey;
                    statusLabel = 'Unknown';
                }

                return Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                  backgroundColor: iconColor.withValues(alpha: 0.12),
                        child: Icon(iconData, color: iconColor),
                      ),
                      title: Text(
                        entry.exerciseName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${entry.category} • $statusLabel'),
                          const SizedBox(height: 2),
                          Text(
                            formattedTime,
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: entry.status == 'completed'
                          ? Text(
                              '${entry.value}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            )
                          : null,
                    ),
                    const Divider(height: 1),
                  ],
                );
              }),
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
