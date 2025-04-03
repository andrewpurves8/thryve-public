import 'package:thryve/src/data_models/workout.dart';

class Program {
  final List<Workout> workouts;

  Program({required this.workouts});

  factory Program.fromMap(
    Map<String, dynamic> map,
  ) {
    return Program(
        workouts: (map['workouts'] as List)
            .map((workout) => Workout.fromMap(workout as Map<String, dynamic>))
            .toList());
  }

  Map<String, dynamic> toJson() => {
        'workouts': workouts,
      };
}
