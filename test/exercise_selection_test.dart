import 'package:flutter_test/flutter_test.dart';
import 'package:micromoves/models/exercise.dart';
import 'package:micromoves/services/exercise_selection_service.dart';

void main() {
  group('ExerciseSelectionService Tests', () {
    final service = ExerciseSelectionService();

    final List<Exercise> testExercises = [
      Exercise(
        id: 1,
        name: 'Squats',
        category: 'Legs',
        currentValue: 10,
        startValue: 10,
        incrementAmount: 2,
        incrementFrequency: 5,
        maxValue: 20,
        isEnabled: true,
      ),
      Exercise(
        id: 2,
        name: 'Lunges',
        category: 'Legs',
        currentValue: 10,
        startValue: 10,
        incrementAmount: 2,
        incrementFrequency: 5,
        maxValue: 20,
        isEnabled: true,
      ),
      Exercise(
        id: 3,
        name: 'Plank',
        category: 'Core',
        currentValue: 30,
        startValue: 30,
        incrementAmount: 5,
        incrementFrequency: 3,
        maxValue: 60,
        isEnabled: true,
      ),
      Exercise(
        id: 4,
        name: 'Neck Stretch',
        category: 'Mobility',
        currentValue: 20,
        startValue: 20,
        incrementAmount: 5,
        incrementFrequency: 5,
        maxValue: 40,
        isEnabled: false, // Disabled!
      ),
    ];

    test('Never selects disabled exercises', () {
      for (int i = 0; i < 20; i++) {
        final selected = service.selectNextExercise(testExercises);
        expect(selected, isNotNull);
        expect(selected!.isEnabled, true);
        expect(selected.name, isNot('Neck Stretch'));
      }
    });

    test('Avoids consecutive duplicate exercise names and categories when possible', () {
      // Last was Squats (Legs)
      final selected = service.selectNextExercise(
        testExercises,
        lastExerciseName: 'Squats',
        lastCategory: 'Legs',
      );

      // Should choose Plank (Core) since Squats and Lunges are Legs category
      expect(selected, isNotNull);
      expect(selected!.name, 'Plank');
      expect(selected.category, 'Core');
    });

    test('Falls back to same category but different exercise if no other categories available', () {
      // Only Legs are enabled
      final legsOnly = testExercises.where((e) => e.category == 'Legs').toList();

      // Last was Squats (Legs)
      final selected = service.selectNextExercise(
        legsOnly,
        lastExerciseName: 'Squats',
        lastCategory: 'Legs',
      );

      // Must select Lunges (even though same category)
      expect(selected, isNotNull);
      expect(selected!.name, 'Lunges');
    });

    test('Returns null if no exercises are enabled', () {
      final allDisabled = testExercises.map((e) => e.copyWith(isEnabled: false)).toList();
      final selected = service.selectNextExercise(allDisabled);
      expect(selected, isNull);
    });
  });
}
