import 'package:thryve/src/data_models/exercise.dart';
import 'package:thryve/src/data_models/program.dart';
import 'package:thryve/src/data_models/workout.dart';

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final Program program;
  final List<Workout> workoutHistory;
  late final Map<String, List<Exercise>> exerciseHistory;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.program,
    required this.workoutHistory,
  }) {
    exerciseHistory = <String, List<Exercise>>{};
    for (final workout in workoutHistory.reversed) {
      for (final exercise in workout.exercises.reversed) {
        exercise.date = workout.startTime;
        if (!exerciseHistory.containsKey(exercise.id)) {
          exerciseHistory[exercise.id] = [];
        }
        for (int setIndex = 0; setIndex < exercise.sets.length; setIndex++) {
          exercise.sets[setIndex] = exercise.sets[setIndex].copyWith(
            toggleCompleted: true,
          );
        }
        exerciseHistory[exercise.id]!.add(exercise);
      }
    }
  }

  factory User.fromMap(
    Map<String, dynamic> map,
  ) {
    final program = map['program'];
    return User(
      id: map['_id'],
      email: map['email'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      program: program != null
          ? Program.fromMap(program as Map<String, dynamic>)
          : Program(workouts: []),
      workoutHistory: (map['workoutHistory'] as List)
          .map((workout) => Workout.fromMap(workout as Map<String, dynamic>))
          .toList(),
    );
  }

  List<Exercise> getExerciseHistory(String exerciseId) {
    return exerciseHistory[exerciseId] ?? [];
  }

  Exercise? getLatestExercise(String exerciseId) {
    final history = getExerciseHistory(exerciseId);
    return history.isNotEmpty ? history.first : null;
  }

  int getNextWorkoutIndex() {
    if (workoutHistory.isEmpty) {
      return 0;
    }

    final lastWorkoutName = workoutHistory.last.name;
    final lastWorkoutIndex = program.workouts
        .indexWhere((workout) => workout.name == lastWorkoutName);
    if (lastWorkoutIndex == -1) {
      return 0;
    }

    return (lastWorkoutIndex + 1) % program.workouts.length;
  }

  @override
  String toString() {
    return '''
id: $id,
email: $email,
firstName: $firstName,
lastName: $lastName,
''';
  }
}
