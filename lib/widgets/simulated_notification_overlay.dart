import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class SimulatedNotificationOverlay extends StatelessWidget {
  const SimulatedNotificationOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final sim = appState.activeSimulation;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (sim == null) return const SizedBox.shrink();

    final valueText = sim.isTimeBased
        ? (sim.value >= 60 ? '${sim.value ~/ 60}m ${sim.value % 60 > 0 ? "${sim.value % 60}s" : ""}' : '${sim.value}s')
        : '${sim.value}';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF37474F) : const Color(0xFFFFE082),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.black87, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 0,
            offset: Offset(4, 6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5722),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black87, width: 2),
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Time to move!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      appState.handleSimulatedAction('dismiss');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black87, width: 2),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF263238) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black87, width: 2),
                ),
                child: Row(
                  children: [
                    Text(
                      '$valueText ',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFF5722),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        sim.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      appState.handleSimulatedAction('skip');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : Colors.black87,
                      side: const BorderSide(color: Colors.black87, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {
                      appState.handleSimulatedAction('snooze');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : Colors.black87,
                      side: const BorderSide(color: Colors.black87, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Snooze', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      appState.handleSimulatedAction('done');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.black87, width: 2),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    ),
                    child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
