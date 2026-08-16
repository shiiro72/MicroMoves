import 'package:flutter/material.dart';
import '../models/history_entry.dart';

class MonthlyCalendar extends StatefulWidget {
  final List<HistoryEntry> history;

  const MonthlyCalendar({super.key, required this.history});

  @override
  State<MonthlyCalendar> createState() => _MonthlyCalendarState();
}

class _MonthlyCalendarState extends State<MonthlyCalendar> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
  }

  void _prevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final year = _focusedMonth.year;
    final month = _focusedMonth.month;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Days in this month
    final totalDays = DateTime(year, month + 1, 0).day;
    final firstDayWeekday = DateTime(year, month, 1).weekday; // 1 = Monday, 7 = Sunday
    final prefixDays = firstDayWeekday - 1; // Number of empty slots before day 1

    // Group completed entries by day-string: "YYYY-MM-DD"
    final completedCounts = <String, int>{};
    for (var entry in widget.history) {
      if (entry.status == 'completed') {
        final parsed = DateTime.tryParse(entry.timestamp);
        if (parsed != null) {
          final key = "${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}";
          completedCounts[key] = (completedCounts[key] ?? 0) + 1;
        }
      }
    }

    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final monthLabel = "${monthNames[month - 1]} $year";

    final weekdayHeaders = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Month Header with Prev/Next buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB300),
                    shape: BoxShape.circle,
                    border: Border.all(color: isDark ? Colors.white70 : Colors.black87, width: 2),
                  ),
                  child: IconButton(
                    key: const Key('prev_month_button'),
                    icon: const Icon(Icons.chevron_left_rounded, color: Colors.black87),
                    onPressed: _prevMonth,
                  ),
                ),
                Text(
                  monthLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB300),
                    shape: BoxShape.circle,
                    border: Border.all(color: isDark ? Colors.white70 : Colors.black87, width: 2),
                  ),
                  child: IconButton(
                    key: const Key('next_month_button'),
                    icon: const Icon(Icons.chevron_right_rounded, color: Colors.black87),
                    onPressed: _nextMonth,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Weekday Headers
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: 7,
              itemBuilder: (context, index) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE082),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.black87, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        weekdayHeaders[index],
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const Divider(height: 16, thickness: 1.5),

            // Days Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: prefixDays + totalDays,
              itemBuilder: (context, index) {
                if (index < prefixDays) {
                  return const SizedBox.shrink();
                }

                final dayNum = index - prefixDays + 1;
                final dateKey = "$year-${month.toString().padLeft(2, '0')}-${dayNum.toString().padLeft(2, '0')}";
                final completedCount = completedCounts[dateKey] ?? 0;

                final isToday = DateTime.now().year == year &&
                    DateTime.now().month == month &&
                    DateTime.now().day == dayNum;

                return Container(
                  decoration: BoxDecoration(
                    color: isToday
                        ? const Color(0xFFFF7043)
                        : (isDark ? const Color(0xFF333333) : const Color(0xFFFFF8E1)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isToday
                          ? Colors.black87
                          : (isDark ? Colors.white24 : Colors.grey.shade400),
                      width: isToday ? 2 : 1,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        "$dayNum",
                        style: TextStyle(
                          fontWeight: isToday ? FontWeight.w900 : FontWeight.bold,
                          fontSize: 13,
                          color: isToday ? Colors.white : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                      if (completedCount > 0)
                        Positioned(
                          right: 2,
                          top: 2,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black87, width: 1.5),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Center(
                              child: Text(
                                "$completedCount",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
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
