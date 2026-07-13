import 'dart:math';
import '../models/exercise.dart';

class ExerciseSelectionService {
  final Random _random;

  ExerciseSelectionService({Random? random}) : _random = random ?? Random();

  /// Selects the next exercise from the list of enabled exercises,
  /// avoiding consecutive repetition of the same exercise or category.
  Exercise? selectNextExercise(
    List<Exercise> exercises, {
    String? lastExerciseName,
    String? lastCategory,
  }) {
    final enabled = exercises.where((e) => e.isEnabled).toList();
    if (enabled.isEmpty) return null;

    // Try to filter out both same exercise and same category
    var pool = enabled.where((e) {
      final isSameName = lastExerciseName != null && e.name.toLowerCase() == lastExerciseName.toLowerCase();
      final isSameCategory = lastCategory != null && e.category.toLowerCase() == lastCategory.toLowerCase();
      return !isSameName && !isSameCategory;
    }).toList();

    if (pool.isNotEmpty) {
      return pool[_random.nextInt(pool.length)];
    }

    // Fallback 1: Avoid same exercise, but allow same category
    pool = enabled.where((e) {
      final isSameName = lastExerciseName != null && e.name.toLowerCase() == lastExerciseName.toLowerCase();
      return !isSameName;
    }).toList();

    if (pool.isNotEmpty) {
      return pool[_random.nextInt(pool.length)];
    }

    // Fallback 2: Any enabled exercise
    return enabled[_random.nextInt(enabled.length)];
  }
}
