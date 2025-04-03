import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:thryve/src/data_models/exercise.dart';
import 'package:thryve/src/data_models/user_state.dart';
import 'package:thryve/src/data_models/workout.dart';
import 'package:thryve/src/data_models/workout_metadata.dart';
import 'package:thryve/src/utilities/backend.dart';
import 'package:thryve/src/utilities/shared_prefs.dart';

abstract class ActiveWorkoutState extends ChangeNotifier {
  void startWorkout(Workout activeWorkout);
  void deleteWorkout();
  Future<void> finishWorkout();
  void setWeight(int exerciseIndex, int setIndex, double weight);
  void setReps(int exerciseIndex, int setIndex, int reps);
  void toggleCompleted(int exerciseIndex, int setIndex);
  Future<bool> tryLoadActiveWorkout();
  void reorderExercises(int oldIndex, int newIndex);
  void deleteExercise(int index);
  void addExercise(String exerciseId,
      int? index); // Specify index to replace an existing exercise
  void deleteSet(int exerciseIndex, int setIndex);
  void addSet(int exerciseIndex);

  void setRestDuration(Duration? restDuration);
  void toggleRestPaused();

  void setHistoryExerciseId(String id);

  Workout? get activeWorkout;
  String get historyExerciseId;
  Duration? get restDuration;
  bool get restPaused;
}

class ActiveWorkoutStateImplementation extends ActiveWorkoutState {
  Workout? _activeWorkout;
  String _historyExerciseId = '';
  WorkoutMetadata _workoutMetadata = WorkoutMetadata();

  @override
  Workout? get activeWorkout => _activeWorkout;

  @override
  String get historyExerciseId => _historyExerciseId;

  @override
  Duration? get restDuration => _workoutMetadata.restPaused
      ? _workoutMetadata.restDuration
      : _workoutMetadata.restEndTime?.difference(DateTime.now());

  @override
  bool get restPaused => _workoutMetadata.restPaused;

  @override
  void startWorkout(Workout activeWorkout) {
    final user = GetIt.I<UserState>().user;
    if (user == null) {
      print('No user to start workout');
      return;
    }

    _activeWorkout = Workout.from(activeWorkout);
    _activeWorkout!.startTime = DateTime.now();

    for (final exercise in _activeWorkout!.exercises) {
      final previousExercise =
          GetIt.I<UserState>().user?.getLatestExercise(exercise.id);
      for (int setIndex = 0; setIndex < exercise.sets.length; setIndex++) {
        if (previousExercise != null &&
            setIndex < previousExercise.sets.length) {
          exercise.sets[setIndex] =
              previousExercise.sets[setIndex].copyWith(completed: false);
        }
      }
    }

    _storeActiveWorkout();
    notifyListeners();
  }

  @override
  Future<void> finishWorkout() async {
    final user = GetIt.I<UserState>().user;
    if (user == null) {
      print('No user to log workout');
      return;
    }
    if (_activeWorkout == null) {
      print('No active workout to finish');
      return;
    }
    _activeWorkout!.endTime = DateTime.now();

    for (final exercise in _activeWorkout!.exercises) {
      exercise.sets.removeWhere((exerciseSet) => !exerciseSet.completed);
    }

    await Backend.logWorkout(user.id, _activeWorkout!);

    _activeWorkout = null;
    _storeActiveWorkout();
    notifyListeners();
  }

  @override
  void deleteWorkout() {
    _activeWorkout = null;
    _storeActiveWorkout();
    notifyListeners();
  }

  @override
  void setWeight(int exerciseIndex, int setIndex, double weight) {
    if (_activeWorkout == null ||
        _activeWorkout!.exercises.length <= exerciseIndex ||
        _activeWorkout!.exercises[exerciseIndex].sets.length <= setIndex) {
      return;
    }

    final oldSet = _activeWorkout!.exercises[exerciseIndex].sets[setIndex];
    _activeWorkout!.exercises[exerciseIndex].sets[setIndex] =
        oldSet.copyWith(weight: weight);
    _storeActiveWorkout();
    notifyListeners();
  }

  @override
  void setReps(int exerciseIndex, int setIndex, int reps) {
    if (_activeWorkout == null ||
        _activeWorkout!.exercises.length <= exerciseIndex ||
        _activeWorkout!.exercises[exerciseIndex].sets.length <= setIndex) {
      return;
    }

    final oldSet = _activeWorkout!.exercises[exerciseIndex].sets[setIndex];
    _activeWorkout!.exercises[exerciseIndex].sets[setIndex] =
        oldSet.copyWith(reps: reps);
    _storeActiveWorkout();
    notifyListeners();
  }

  @override
  void toggleCompleted(int exerciseIndex, int setIndex) {
    if (_activeWorkout == null ||
        _activeWorkout!.exercises.length <= exerciseIndex ||
        _activeWorkout!.exercises[exerciseIndex].sets.length <= setIndex) {
      return;
    }

    final oldSet = _activeWorkout!.exercises[exerciseIndex].sets[setIndex];
    _activeWorkout!.exercises[exerciseIndex].sets[setIndex] =
        oldSet.copyWith(toggleCompleted: true);
    _storeActiveWorkout();
    notifyListeners();
  }

  Future<void> _storeActiveWorkout() async {
    await saveActiveWorkoutJson(
        _activeWorkout == null ? '' : jsonEncode(_activeWorkout));

    await saveActiveWorkoutMetadataJson(jsonEncode(_workoutMetadata));
  }

  @override
  Future<bool> tryLoadActiveWorkout() async {
    final activeWorkoutJson = await loadActiveWorkoutJson();
    if (activeWorkoutJson.isEmpty) {
      return false;
    }

    _activeWorkout = Workout.fromMap(jsonDecode(activeWorkoutJson));

    final activeWorkoutMetadataJson = await loadActiveWorkoutMetadataJson();
    if (activeWorkoutMetadataJson.isEmpty) {
      return false;
    }

    _workoutMetadata =
        WorkoutMetadata.fromMap(jsonDecode(activeWorkoutMetadataJson));

    notifyListeners();

    return true;
  }

  @override
  void reorderExercises(int oldIndex, int newIndex) {
    if (_activeWorkout == null ||
        oldIndex >= _activeWorkout!.exercises.length ||
        newIndex >= _activeWorkout!.exercises.length) {
      return;
    }
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final exercise = _activeWorkout!.exercises.removeAt(oldIndex);
    _activeWorkout!.exercises.insert(newIndex, exercise);
    _storeActiveWorkout();
    notifyListeners();
  }

  @override
  void deleteExercise(int index) {
    if (_activeWorkout == null) {
      return;
    }
    _activeWorkout!.exercises.removeAt(index);
    _storeActiveWorkout();
    notifyListeners();
  }

  @override
  void addExercise(String exerciseId, int? index) {
    final exercise = Exercise.fromId(exerciseId);
    final previousExercise =
        GetIt.I<UserState>().user?.getLatestExercise(exercise.id);
    if (previousExercise != null) {
      exercise.sets = previousExercise.sets.map((exerciseSet) {
        return exerciseSet.copyWith(completed: false);
      }).toList();
    }
    if (index != null && index < _activeWorkout!.exercises.length) {
      _activeWorkout!.exercises[index] = exercise;
    } else {
      _activeWorkout!.exercises.add(exercise);
    }
    _storeActiveWorkout();
    notifyListeners();
  }

  @override
  void deleteSet(int exerciseIndex, int setIndex) {
    if (_activeWorkout == null ||
        _activeWorkout!.exercises.length <= exerciseIndex ||
        _activeWorkout!.exercises[exerciseIndex].sets.length <= setIndex) {
      return;
    }

    var sets = _activeWorkout!.exercises[exerciseIndex].sets;
    _activeWorkout!.exercises[exerciseIndex].sets = sets
        .where((exerciseSet) => sets.indexOf(exerciseSet) != setIndex)
        .toList();
    _storeActiveWorkout();
    notifyListeners();
  }

  @override
  void addSet(int exerciseIndex) {
    if (_activeWorkout == null ||
        _activeWorkout!.exercises.length <= exerciseIndex) {
      return;
    }

    final List<ExerciseSet> sets =
        List.from(_activeWorkout!.exercises[exerciseIndex].sets);
    final previousExercise = GetIt.I<UserState>()
        .user
        ?.getLatestExercise(_activeWorkout!.exercises[exerciseIndex].id);

    final newSet =
        previousExercise != null && sets.length < previousExercise.sets.length
            ? previousExercise.sets[sets.length].copyWith(completed: false)
            : ExerciseSet(
                completed: false,
                weight: 5.0,
                reps: 10,
              );
    sets.add(newSet);
    _activeWorkout!.exercises[exerciseIndex].sets = sets;
    _storeActiveWorkout();
    notifyListeners();
  }

  @override
  void setRestDuration(Duration? restDuration) {
    _workoutMetadata.restDuration = restDuration;
    _workoutMetadata.restEndTime =
        restDuration == null ? null : DateTime.now().add(restDuration);
    _workoutMetadata.restPaused = false;
    _storeActiveWorkout();
    notifyListeners();
  }

  @override
  void toggleRestPaused() {
    if (_workoutMetadata.restDuration == null ||
        _workoutMetadata.restEndTime == null) {
      return;
    }

    _workoutMetadata.restPaused = !_workoutMetadata.restPaused;
    if (_workoutMetadata.restPaused) {
      _workoutMetadata.restDuration =
          _workoutMetadata.restEndTime?.difference(DateTime.now());
    } else {
      _workoutMetadata.restEndTime =
          DateTime.now().add(_workoutMetadata.restDuration!);
    }
    _storeActiveWorkout();
    notifyListeners();
  }

  @override
  void setHistoryExerciseId(String id) {
    _historyExerciseId = id;
    notifyListeners();
  }
}
