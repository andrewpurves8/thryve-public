import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:thryve/src/app.dart';
import 'package:thryve/src/data_models/active_workout_state.dart';
import 'package:thryve/src/data_models/exercise.dart';
import 'package:thryve/src/data_models/application_state.dart';
import 'package:thryve/src/data_models/user_state.dart';

void main() {
  GetIt.I.registerSingleton<UserState>(UserStateImplementation());
  GetIt.I.registerSingleton<ApplicationState>(ApplicationStateImplementation());
  GetIt.I.registerSingleton<ActiveWorkoutState>(
      ActiveWorkoutStateImplementation());
  assert(Exercise.checkExerciseUniqueness());
  runApp(const ThryveApp());
}
