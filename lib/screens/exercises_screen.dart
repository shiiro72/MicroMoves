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
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showInfoDialog(context);
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: categoryKeys.length,
        itemBuilder: (context, idx) {
          final category = categoryKeys[idx];
          final categoryExercises = categories[category]!;

          return ExpansionTile(
            title: Text(
              category,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            initiallyExpanded: true,
            children: categoryExercises.map((ex) {
              final valueText = ex.isTimeBased
                  ? (ex.currentValue >= 60 ? '${ex.currentValue ~/ 60}m ${ex.currentValue % 60 > 0 ? "${ex.currentValue % 60}s" : ""}' : '${ex.currentValue}s')
                  : '${ex.currentValue} reps';

              final progressionText = ex.incrementFrequency > 0
                  ? '+${ex.incrementAmount} every ${ex.incrementFrequency} completions (max: ${ex.maxValue})'
                  : 'No progression';

              return ListTile(
                title: Text(ex.name),
                subtitle: Text('$valueText • $progressionText'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: ex.isEnabled,
                      onChanged: (val) {
                        appState.toggleExerciseEnabled(ex.id!, val);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {
                        _showExerciseDialog(context, appState, exercise: ex);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        _confirmDelete(context, appState, ex);
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showExerciseDialog(context, appState);
        },
        tooltip: 'Add Custom Exercise',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How Progression Works'),
        content: const Text(
          'Exercises automatically increase in intensity as you complete them.\n\n'
          'For example, Squats might start at 12 reps and increase by 2 reps every 5 completions, up to a maximum of 30 reps.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppState appState, Exercise exercise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exercise?'),
        content: Text('Are you sure you want to delete "${exercise.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              appState.deleteExercise(exercise.id!);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
              title: Text(isEdit ? 'Edit Exercise' : 'Add Custom Exercise'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Exercise Name (e.g. Squats)'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(labelText: 'Category (e.g. Legs, Core, Upper Body)'),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      title: const Text('Time-Based (Seconds instead of Reps)'),
                      value: isTimeBased,
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
                      decoration: const InputDecoration(labelText: 'Current Value'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: startValueController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Starting Value'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: incrementAmountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Increment Amount'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: incrementFrequencyController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Increment Frequency (completions)'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: maxValueController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Maximum Value'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
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
