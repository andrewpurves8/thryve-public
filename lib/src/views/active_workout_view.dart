import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:thryve/src/components/circled_icon_button.dart';
import 'package:thryve/src/components/exercise_tile.dart';
import 'package:thryve/src/components/rounded_button.dart';
import 'package:thryve/src/data_models/active_workout_state.dart';
import 'package:thryve/src/data_models/application_state.dart';
import 'package:thryve/src/data_models/user.dart';
import 'package:thryve/src/data_models/user_state.dart';
import 'package:thryve/src/utilities/constants.dart';
import 'package:thryve/src/utilities/helpers.dart';
import 'package:thryve/src/views/history_view.dart';
import 'package:thryve/src/views/search_exercise_view.dart';

class ActiveWorkoutView extends StatefulWidget {
  const ActiveWorkoutView({super.key});

  static const routeName = '/active_workout';

  @override
  State<ActiveWorkoutView> createState() => _ActiveWorkoutViewState();
}

class _ActiveWorkoutViewState extends State<ActiveWorkoutView> {
  static const kDeleteWorkout = 'Delete workout';
  static const kAddExercise = 'Add exercise';
  static const kAddSet = 'Add set';
  static const kSwitchExercise = 'Switch exercise';
  static const kDeleteExercise = 'Delete exercise';
  late final Timer _oneSecTimer;
  Duration _workoutDuration = const Duration();

  @override
  void initState() {
    super.initState();
    GetIt.I<ActiveWorkoutState>().addListener(_updateState);
    _oneSecTimer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    GetIt.I<ActiveWorkoutState>().removeListener(_updateState);
    _oneSecTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeWorkout = GetIt.I<ActiveWorkoutState>().activeWorkout;
    if (activeWorkout == null) {
      return const SizedBox();
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(activeWorkout.name, style: const TextStyle(fontSize: 28)),
              Text(
                durationToString(_workoutDuration),
                style: const TextStyle(fontSize: 14, color: kLightGrey),
              ),
            ],
          ),
          actions: [
            RoundedButton(
              text: 'Finish',
              onPressed: () async {
                await GetIt.I<ActiveWorkoutState>().finishWorkout();
                await GetIt.I<UserState>().updateUser();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              color: kPrimaryColor,
              textColor: kWhite,
            ),
            PopupMenuButton<String>(
              onSelected: (String choice) {
                if (choice == kDeleteWorkout) {
                  GetIt.I<ActiveWorkoutState>().deleteWorkout();
                  Navigator.of(context).pop();
                } else if (choice == kAddExercise) {
                  Navigator.of(context)
                      .pushNamed(SearchExerciseView.routeName)
                      .then((_) {
                    final exerciseId =
                        GetIt.I<ApplicationState>().searchedExerciseId;
                    if (exerciseId.isEmpty) {
                      return;
                    }
                    GetIt.I<ApplicationState>().setSearchedExerciseId('');
                    GetIt.I<ActiveWorkoutState>().addExercise(exerciseId, null);
                  });
                }
              },
              itemBuilder: (BuildContext context) {
                return {kDeleteWorkout, kAddExercise}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 20.0),
                Expanded(
                  child: ReorderableListView.builder(
                    itemCount: activeWorkout.exercises.length + 1,
                    onReorder: GetIt.I<ActiveWorkoutState>().reorderExercises,
                    itemBuilder: (context, index) {
                      if (index == activeWorkout.exercises.length) {
                        return const SizedBox(
                          key: Key('BottomSpacer'),
                          height: 80.0,
                        );
                      }
                      return ExerciseTile(
                        key: Key(activeWorkout.exercises[index].name +
                            index.toString()),
                        exerciseIndex: index,
                        setRestDuration: (Duration? restDuration) {
                          GetIt.I<ActiveWorkoutState>()
                              .setRestDuration(restDuration);
                          _tick();
                        },
                        viewHistory: () {
                          GetIt.I<ActiveWorkoutState>().setHistoryExerciseId(
                              activeWorkout.exercises[index].id);
                          Navigator.of(context)
                              .pushNamed(HistoryView.routeName);
                        },
                        popup: PopupMenuButton<String>(
                          onSelected: (String choice) {
                            if (choice == kAddSet) {
                              GetIt.I<ActiveWorkoutState>().addSet(index);
                            } else if (choice == kDeleteExercise) {
                              GetIt.I<ActiveWorkoutState>()
                                  .deleteExercise(index);
                            } else if (choice == kSwitchExercise) {
                              Navigator.of(context)
                                  .pushNamed(SearchExerciseView.routeName)
                                  .then((_) {
                                final exerciseId = GetIt.I<ApplicationState>()
                                    .searchedExerciseId;
                                if (exerciseId.isEmpty) {
                                  return;
                                }
                                GetIt.I<ApplicationState>()
                                    .setSearchedExerciseId('');
                                GetIt.I<ActiveWorkoutState>()
                                    .addExercise(exerciseId, index);
                              });
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return {kAddSet, kSwitchExercise, kDeleteExercise}
                                .map((String choice) {
                              return PopupMenuItem<String>(
                                value: choice,
                                child: Text(choice),
                              );
                            }).toList();
                          },
                        ),
                        deleteSet: (setIndex) {
                          GetIt.I<ActiveWorkoutState>()
                              .deleteSet(index, setIndex);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            if (GetIt.I<ActiveWorkoutState>().restDuration != null)
              RestTimer(
                restDuration: GetIt.I<ActiveWorkoutState>().restDuration!,
                restPaused: GetIt.I<ActiveWorkoutState>().restPaused,
                toggleRestPause: GetIt.I<ActiveWorkoutState>().toggleRestPaused,
              ),
          ],
        ),
      ),
    );
  }

  void _updateState() => setState(() {});

  void _tick() {
    final activeWorkout = GetIt.I<ActiveWorkoutState>().activeWorkout;
    if (activeWorkout == null) {
      return;
    }
    setState(() {
      _workoutDuration = DateTime.now().difference(activeWorkout.startTime!);
    });
  }
}

class RestTimer extends StatelessWidget {
  const RestTimer({
    super.key,
    required this.restDuration,
    required this.restPaused,
    required this.toggleRestPause,
  });

  final Duration restDuration;
  final bool restPaused;
  final void Function() toggleRestPause;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: kDarkGrey,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15.0,
              vertical: 10.0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...(restDuration.isNegative
                    ? [
                        Text(
                          'Overtime ',
                          style:
                              const TextStyle(fontSize: 16, color: kLightGrey),
                        ),
                        Text(
                          durationToString(restDuration.abs()),
                          style:
                              const TextStyle(fontSize: 16, color: Colors.red),
                        ),
                      ]
                    : [
                        Text(
                          'Rest for ',
                          style:
                              const TextStyle(fontSize: 16, color: kLightGrey),
                        ),
                        Text(
                          durationToString(restDuration),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ]),
                const SizedBox(width: 15.0),
                CircledIconButton(
                  icon: restPaused ? Icons.play_arrow : Icons.pause,
                  onPressed: toggleRestPause,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
