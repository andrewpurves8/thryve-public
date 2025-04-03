import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:thryve/src/components/circled_icon_button.dart';
import 'package:thryve/src/components/circled_text.dart';
import 'package:thryve/src/components/small_double_text_field.dart';
import 'package:thryve/src/components/small_int_text_field.dart';
import 'package:thryve/src/data_models/active_workout_state.dart';
import 'package:thryve/src/data_models/exercise.dart';
import 'package:thryve/src/data_models/user_state.dart';
import 'package:thryve/src/utilities/constants.dart';
import 'package:thryve/src/utilities/helpers.dart';

class ExerciseTile extends StatelessWidget {
  ExerciseTile({
    super.key,
    this.exerciseIndex,
    Exercise? exercise,
    Exercise? lastExercise,
    this.setRestDuration,
    this.viewHistory,
    this.popup,
    this.deleteSet,
  }) {
    assert(exerciseIndex != null || exercise != null, 'No exercise provided');

    if (exercise != null) {
      // use given exercise (history view)
      this.exercise = exercise;
      this.lastExercise = lastExercise;
      return;
    }

    // use exercise index and active workout
    final activeWorkout = GetIt.I<ActiveWorkoutState>().activeWorkout;
    assert(
      exerciseIndex != null &&
          activeWorkout != null &&
          exerciseIndex! < activeWorkout.exercises.length,
      'Invalid exercise index',
    );

    this.exercise = activeWorkout!.exercises[exerciseIndex!];
    this.lastExercise =
        GetIt.I<UserState>().user?.getLatestExercise(this.exercise!.id);
  }

  final int? exerciseIndex;
  late final Exercise? exercise;
  late final Exercise? lastExercise;
  final void Function(Duration? restDuration)? setRestDuration;
  final void Function()? viewHistory;
  final Widget? popup;
  final void Function(int)? deleteSet;

  @override
  Widget build(BuildContext context) {
    if (exercise == null) {
      return const SizedBox();
    }

    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: 10.0, horizontal: getHorizontalMargin(context)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: kDarkGrey,
        ),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(vertical: kExerciseTileInnerPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: kExerciseTileInnerPadding),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise!.shortName,
                            style: TextStyle(fontSize: 16.0),
                            overflow: TextOverflow.fade,
                          ),
                          Text(
                            exercise!.date != null
                                ? DateFormat('yyyy-MM-dd - kk:mm')
                                    .format(exercise!.date!)
                                : exercise!.type.toString(),
                            style: const TextStyle(
                                fontSize: 16.0, color: kLightGrey),
                          ),
                        ],
                      ),
                    ),
                    if (viewHistory != null)
                      IconButton(
                        icon: Icon(Icons.history),
                        onPressed: viewHistory,
                      ),
                    if (popup != null) popup!,
                  ],
                ),
              ),
              const SizedBox(height: 5.0),
              for (int setIndex = 0;
                  setIndex < exercise!.sets.length;
                  setIndex++)
                SetRow(
                  setIndex: setIndex,
                  exerciseSet: exercise!.sets[setIndex],
                  lastExerciseSet: lastExercise == null ||
                          setIndex >= lastExercise!.sets.length
                      ? null
                      : lastExercise!.sets[setIndex],
                  setWeight: exerciseIndex == null
                      ? null
                      : (weight) => GetIt.I<ActiveWorkoutState>()
                          .setWeight(exerciseIndex!, setIndex, weight),
                  setReps: exerciseIndex == null
                      ? null
                      : (reps) => GetIt.I<ActiveWorkoutState>()
                          .setReps(exerciseIndex!, setIndex, reps),
                  toggleCompleted:
                      setRestDuration == null || exerciseIndex == null
                          ? null
                          : () {
                              if (exercise!.sets[setIndex].completed) {
                                setRestDuration!(null);
                              } else {
                                setRestDuration!(
                                    Duration(seconds: exercise!.getRestTime()));
                              }
                              GetIt.I<ActiveWorkoutState>()
                                  .toggleCompleted(exerciseIndex!, setIndex);
                            },
                  deleteSet: deleteSet,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SetRow extends StatelessWidget {
  const SetRow({
    super.key,
    required this.setIndex,
    required this.exerciseSet,
    this.lastExerciseSet,
    this.setWeight,
    this.setReps,
    this.toggleCompleted,
    this.deleteSet,
  });

  final int setIndex;
  final ExerciseSet exerciseSet;
  final ExerciseSet? lastExerciseSet;
  final void Function(double)? setWeight;
  final void Function(int)? setReps;
  final void Function()? toggleCompleted;
  final void Function(int)? deleteSet;

  @override
  Widget build(BuildContext context) {
    final setComparison = lastExerciseSet == null
        ? 0
        : compare(calculateOneRepMax(exerciseSet.weight, exerciseSet.reps),
            calculateOneRepMax(lastExerciseSet!.weight, lastExerciseSet!.reps));
    final color = switch (setComparison) {
      -1 => kCompletedRed,
      1 => kCompletedGreen,
      // _ => kLightGrey,
      _ => kCompletedGrey,
    };
    final icon = switch (setComparison) {
      -1 => Icons.arrow_downward,
      1 => Icons.arrow_upward,
      _ => Icons.remove,
    };
    const style = TextStyle(fontSize: 14.0);
    final setRow = Container(
      color: exerciseSet.completed ? color : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 4.0,
          horizontal: kExerciseTileInnerPadding,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircledText(text: (setIndex + 1).toString()),
            Row(
              children: [
                SmallDoubleTextField(
                  initialValue: exerciseSet.weight,
                  onChanged: setWeight,
                ),
                const SizedBox(width: 12.0),
                const Text('kg', style: style),
              ],
            ),
            const Text('×', style: style),
            Row(
              children: [
                SmallIntTextField(
                  initialValue: exerciseSet.reps,
                  onChanged: setReps,
                ),
                const SizedBox(width: 12.0),
                const Text('reps', style: style),
              ],
            ),
            CircledIconButton(
              icon: exerciseSet.completed ? icon : Icons.check,
              onPressed: toggleCompleted,
            ),
          ],
        ),
      ),
    );

    if (deleteSet == null) {
      return setRow;
    }

    return Slidable(
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,

        // A pane can dismiss the Slidable.
        // dismissible: DismissiblePane(onDismissed: () {}),

        children: [
          SlidableAction(
            onPressed: (_) {
              deleteSet!(setIndex);
            },
            backgroundColor: Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: setRow,
    );
  }
}
