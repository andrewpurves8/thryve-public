import 'package:thryve/src/data_models/exercise.dart';

class Workout {
  String name;
  List<Exercise> exercises;
  DateTime? startTime;
  DateTime? endTime;

  Workout({
    required this.name,
    required this.exercises,
    this.startTime,
    this.endTime,
  });

  factory Workout.fromMap(
    Map<String, dynamic> map,
  ) {
    final startTime = map['startTime'];
    final endTime = map['endTime'];
    return Workout(
      name: map['name'],
      exercises: (map['exercises'] as List)
          .map((exercise) => Exercise.fromMap(exercise as Map<String, dynamic>))
          .toList(),
      startTime: startTime != null && startTime != ''
          ? DateTime.parse(startTime as String)
          : null,
      endTime: endTime != null && endTime != ''
          ? DateTime.parse(endTime as String)
          : null,
    );
  }

  factory Workout.from(Workout workout) {
    return Workout(
      name: workout.name,
      exercises: workout.exercises.map((e) => Exercise.from(e)).toList(),
      startTime: workout.startTime,
      endTime: workout.endTime,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'exercises': exercises,
        'startTime': startTime?.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
      };
}
