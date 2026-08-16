import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final settings = appState.settings;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          // Section: General Settings
          _buildSectionHeader(context, 'Reminder Schedule', isDark),
          const SizedBox(height: 8),
          Card(
            color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
            child: Column(
              children: [
                // Interval minutes
                ListTile(
                  title: const Text('Reminder Interval', style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('${settings.intervalMinutes} minutes', style: const TextStyle(fontWeight: FontWeight.w500)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE082),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black87, width: 2),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: settings.intervalMinutes,
                        dropdownColor: const Color(0xFFFFE082),
                        style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black87),
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
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),

                // Snooze duration
                ListTile(
                  title: const Text('Snooze Duration', style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('${settings.snoozeDurationMinutes} minutes', style: const TextStyle(fontWeight: FontWeight.w500)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE082),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black87, width: 2),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: settings.snoozeDurationMinutes,
                        dropdownColor: const Color(0xFFFFE082),
                        style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black87),
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
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),

                // Start Time Picker
                ListTile(
                  title: const Text('Work Start Time', style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text(settings.startTime, style: const TextStyle(fontWeight: FontWeight.w500)),
                  trailing: ElevatedButton(
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5722),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Edit'),
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),

                // End Time Picker
                ListTile(
                  title: const Text('Work End Time', style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text(settings.endTime, style: const TextStyle(fontWeight: FontWeight.w500)),
                  trailing: ElevatedButton(
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5722),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Edit'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section: Active Days
          _buildSectionHeader(context, 'Active Weekdays', isDark),
          const SizedBox(height: 8),
          Card(
            color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: weekdays.map((day) {
                  final name = day['name'] as String;
                  final value = day['value'] as int;
                  final isActive = settings.activeWeekdays.contains(value);

                  return CheckboxListTile(
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    value: isActive,
                    activeColor: const Color(0xFFFF5722),
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
          const SizedBox(height: 20),

          // Section: Utilities / Storage
          _buildSectionHeader(context, 'App Management', isDark),
          const SizedBox(height: 8),
          Card(
            color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
            child: Column(
              children: [
                ListTile(
                  title: const Text('Clear All History', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.redAccent)),
                  subtitle: const Text('Remove all completed, skipped, and snoozed records.', style: TextStyle(fontWeight: FontWeight.w500)),
                  trailing: ElevatedButton(
                    onPressed: () {
                      _confirmClearHistory(context, appState);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Clear'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFFB300),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white70 : Colors.black87, width: 2),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  void _confirmClearHistory(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Are you sure you want to delete your entire completion history? This will also reset your streak.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              appState.clearHistory();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
