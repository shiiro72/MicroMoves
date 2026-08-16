import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exercise.dart';
import '../services/app_state.dart';

class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final exercises = appState.exercises;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Group exercises by category
    final Map<String, List<Exercise>> categories = {};
    for (var ex in exercises) {
      categories.putIfAbsent(ex.category, () => []).add(ex);
    }

    final categoryKeys = categories.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercises'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'How Progression Works',
            onPressed: () {
              _showInfoDialog(context);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: categoryKeys.map((category) {
            final categoryExercises = categories[category]!;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Card(
                color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB300),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? Colors.white60 : Colors.black87, width: 2),
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${categoryExercises.length})',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    initiallyExpanded: true,
                    children: categoryExercises.map((ex) {
                      final valueText = ex.isTimeBased
                          ? (ex.currentValue >= 60
                              ? '${ex.currentValue ~/ 60}m ${ex.currentValue % 60 > 0 ? "${ex.currentValue % 60}s" : ""}'
                              : '${ex.currentValue}s')
                          : '${ex.currentValue} reps';

                      final progressionText = ex.incrementFrequency > 0
                          ? '+${ex.incrementAmount} every ${ex.incrementFrequency} completions (max: ${ex.maxValue})'
                          : 'No progression';

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: ex.isEnabled
                              ? (isDark ? const Color(0xFF383838) : const Color(0xFFFFF8E1))
                              : (isDark ? const Color(0xFF222222) : const Color(0xFFF5F5F5)),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: ex.isEnabled
                                ? (isDark ? const Color(0xFFFFB300) : Colors.black87)
                                : Colors.grey.shade400,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          ex.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                            color: ex.isEnabled
                                                ? (isDark ? Colors.white : Colors.black87)
                                                : Colors.grey,
                                            decoration: ex.isEnabled ? null : TextDecoration.lineThrough,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF5722),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          valueText,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    progressionText,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(
                                  activeColor: const Color(0xFFFF5722),
                                  value: ex.isEnabled,
                                  onChanged: (val) {
                                    appState.toggleExerciseEnabled(ex.id!, val);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_rounded, size: 20),
                                  onPressed: () {
                                    _showExerciseDialog(context, appState, exercise: ex);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                  onPressed: () {
                                    _confirmDelete(context, appState, ex);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showExerciseDialog(context, appState);
        },
        tooltip: 'Add Custom Exercise',
        icon: const Icon(Icons.add_rounded, size: 26),
        label: const Text(
          'Add Exercise',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: Color(0xFFFFB300)),
            SizedBox(width: 8),
            Text('How Progression Works', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
        content: const Text(
          'Exercises automatically increase in intensity as you complete them!\n\n'
          'For example, Squats might start at 12 reps and increase by 2 reps every 5 completions, up to a maximum of 30 reps.',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5722),
              foregroundColor: Colors.white,
            ),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppState appState, Exercise exercise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exercise?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('Are you sure you want to delete "${exercise.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              appState.deleteExercise(exercise.id!);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showExerciseDialog(BuildContext context, AppState appState, {Exercise? exercise}) {
    final isEdit = exercise != null;

    final nameController = TextEditingController(text: exercise?.name ?? '');
    final categoryController = TextEditingController(text: exercise?.category ?? '');
    final currentValueController = TextEditingController(text: exercise?.currentValue.toString() ?? '10');
    final startValueController = TextEditingController(text: exercise?.startValue.toString() ?? '10');
    final incrementAmountController = TextEditingController(text: exercise?.incrementAmount.toString() ?? '2');
    final incrementFrequencyController = TextEditingController(text: exercise?.incrementFrequency.toString() ?? '5');
    final maxValueController = TextEditingController(text: exercise?.maxValue.toString() ?? '20');

    bool isTimeBased = exercise?.isTimeBased ?? false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                isEdit ? 'Edit Exercise' : 'Add Custom Exercise',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Exercise Name (e.g. Squats)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category (e.g. Legs, Core, Upper Body)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      title: const Text('Time-Based (Seconds instead of Reps)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      value: isTimeBased,
                      activeColor: const Color(0xFFFF5722),
                      onChanged: (val) {
                        setState(() {
                          isTimeBased = val ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: currentValueController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Current Value',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: startValueController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Starting Value',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: incrementAmountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Increment Amount',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: incrementFrequencyController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Increment Frequency (completions)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: maxValueController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Maximum Value',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final category = categoryController.text.trim();

                    if (name.isEmpty || category.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill in Name and Category')),
                      );
                      return;
                    }

                    final currentValue = int.tryParse(currentValueController.text) ?? 10;
                    final startValue = int.tryParse(startValueController.text) ?? 10;
                    final incrementAmount = int.tryParse(incrementAmountController.text) ?? 2;
                    final incrementFrequency = int.tryParse(incrementFrequencyController.text) ?? 5;
                    final maxValue = int.tryParse(maxValueController.text) ?? 20;

                    final updated = Exercise(
                      id: exercise?.id,
                      name: name,
                      category: category,
                      currentValue: currentValue,
                      isTimeBased: isTimeBased,
                      startValue: startValue,
                      incrementAmount: incrementAmount,
                      incrementFrequency: incrementFrequency,
                      maxValue: maxValue,
                      isEnabled: exercise?.isEnabled ?? true,
                      completionCount: exercise?.completionCount ?? 0,
                    );

                    appState.saveExercise(updated);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5722),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
