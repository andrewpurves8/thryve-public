import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:thryve/src/components/exercise_tile.dart';
import 'package:thryve/src/data_models/active_workout_state.dart';
import 'package:thryve/src/data_models/exercise.dart';
import 'package:thryve/src/data_models/user_state.dart';
import 'package:thryve/src/utilities/constants.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  static const routeName = '/history';

  @override
  Widget build(BuildContext context) {
    final historyExerciseId = GetIt.I<ActiveWorkoutState>().historyExerciseId;
    final user = GetIt.I<UserState>().user;
    if (historyExerciseId.isEmpty || user == null) {
      return const SizedBox();
    }

    final exerciseHistory = user.getExerciseHistory(historyExerciseId);
    final exerciseName = Exercise.fromId(historyExerciseId).name;

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('History', style: const TextStyle(fontSize: 28)),
            Text(
              exerciseName,
              style: const TextStyle(fontSize: 14, color: kLightGrey),
            ),
          ],
        ),
      ),
      body: exerciseHistory.isEmpty
          ? Center(
              child: Text('Exercise not yet performed'),
            )
          : ListView.builder(
              itemCount: exerciseHistory.length,
              itemBuilder: (context, index) {
                final exercise = exerciseHistory[index];
                final lastExercise = index >= exerciseHistory.length - 1
                    ? null
                    : exerciseHistory[index + 1];
                return ExerciseTile(
                  exercise: exercise,
                  lastExercise: lastExercise,
                );
              },
            ),
    ));
  }
}
