import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final settings = appState.settings;

    final weekdays = [
      {'name': 'Monday', 'value': 1},
      {'name': 'Tuesday', 'value': 2},
      {'name': 'Wednesday', 'value': 3},
      {'name': 'Thursday', 'value': 4},
      {'name': 'Friday', 'value': 5},
      {'name': 'Saturday', 'value': 6},
      {'name': 'Sunday', 'value': 7},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Section: General Settings
          _buildSectionHeader(context, 'Reminder Schedule'),
          Card(
            child: Column(
              children: [
                // Interval minutes
                ListTile(
                  title: const Text('Reminder Interval'),
                  subtitle: Text('${settings.intervalMinutes} minutes'),
                  trailing: DropdownButton<int>(
                    value: settings.intervalMinutes,
                    onChanged: (val) {
                      if (val != null) {
                        appState.updateSettings(
                          settings.copyWith(intervalMinutes: val),
                        );
                      }
                    },
                    items: [1, 5, 10, 20, 30, 45, 50, 60, 90, 120]
                        .map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text('$m mins'),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const Divider(height: 1),

                // Snooze duration
                ListTile(
                  title: const Text('Snooze Duration'),
                  subtitle: Text('${settings.snoozeDurationMinutes} minutes'),
                  trailing: DropdownButton<int>(
                    value: settings.snoozeDurationMinutes,
                    onChanged: (val) {
                      if (val != null) {
                        appState.updateSettings(
                          settings.copyWith(snoozeDurationMinutes: val),
                        );
                      }
                    },
                    items: [2, 5, 10, 15, 20, 30]
                        .map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text('$m mins'),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const Divider(height: 1),

                // Start Time Picker
                ListTile(
                  title: const Text('Work Start Time'),
                  subtitle: Text(settings.startTime),
                  trailing: TextButton(
                    onPressed: () async {
                      final parts = settings.startTime.split(':');
                      final initialTime = TimeOfDay(
                        hour: int.parse(parts[0]),
                        minute: int.parse(parts[1]),
                      );
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: initialTime,
                      );
                      if (picked != null) {
                        final formatted =
                            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                        appState.updateSettings(
                          settings.copyWith(startTime: formatted),
                        );
                      }
                    },
                    child: const Text('Edit'),
                  ),
                ),
                const Divider(height: 1),

                // End Time Picker
                ListTile(
                  title: const Text('Work End Time'),
                  subtitle: Text(settings.endTime),
                  trailing: TextButton(
                    onPressed: () async {
                      final parts = settings.endTime.split(':');
                      final initialTime = TimeOfDay(
                        hour: int.parse(parts[0]),
                        minute: int.parse(parts[1]),
                      );
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: initialTime,
                      );
                      if (picked != null) {
                        final formatted =
                            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                        appState.updateSettings(
                          settings.copyWith(endTime: formatted),
                        );
                      }
                    },
                    child: const Text('Edit'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section: Active Days
          _buildSectionHeader(context, 'Active Weekdays'),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: weekdays.map((day) {
                  final name = day['name'] as String;
                  final value = day['value'] as int;
                  final isActive = settings.activeWeekdays.contains(value);

                  return CheckboxListTile(
                    title: Text(name),
                    value: isActive,
                    onChanged: (checked) {
                      final list = List<int>.from(settings.activeWeekdays);
                      if (checked == true) {
                        if (!list.contains(value)) list.add(value);
                      } else {
                        // Keep at least one active weekday to prevent crash
                        if (list.length > 1) {
                          list.remove(value);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('At least one day must remain active.'),
                            ),
                          );
                        }
                      }
                      // Sort active weekdays
                      list.sort();
                      appState.updateSettings(
                        settings.copyWith(activeWeekdays: list),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Section: Utilities / Storage
          _buildSectionHeader(context, 'App Management'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Clear All History'),
                  subtitle: const Text('Remove all completed, skipped, and snoozed records.'),
                  trailing: TextButton(
                    onPressed: () {
                      _confirmClearHistory(context, appState);
                    },
                    child: const Text('Clear', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0, top: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  void _confirmClearHistory(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History?'),
        content: const Text('Are you sure you want to delete your entire completion history? This will also reset your streak.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              appState.clearHistory();
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
