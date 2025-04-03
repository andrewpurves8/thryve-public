import 'package:flutter/material.dart';
import 'package:thryve/src/data_models/user.dart';
import 'package:thryve/src/data_models/workout.dart';
import 'package:thryve/src/utilities/backend.dart';
import 'package:thryve/src/utilities/shared_prefs.dart';

abstract class UserState extends ChangeNotifier {
  void setUser(User? user);
  Future<void> initUser();
  Future<void> updateUser();
  void addWorkout(Workout workout);
  void updateWorkout(int index, Workout workout);
  void reorderWorkouts(int oldIndex, int newIndex);
  void deleteWorkout(int index);
  Future<bool> saveProgram();
  bool isWorkoutInProgram(String workoutName,
      int? workoutIndexToIgnore); // to ignore the workout being edited

  User? get user;
  bool get userInitialised;
}

class UserStateImplementation extends UserState {
  User? _user;
  bool _userInitialised = false;

  @override
  User? get user => _user;

  @override
  bool get userInitialised => _userInitialised;

  @override
  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  @override
  Future<void> initUser() async {
    final userId = await loadUserId();

    if (userId.isNotEmpty) {
      _user = await Backend.backendGetUser(userId);
    }
    _userInitialised = true;
    notifyListeners();
  }

  @override
  Future<void> updateUser() async {
    if (user == null) {
      return;
    }
    _user = await Backend.backendGetUser(user!.id);
    notifyListeners();
  }

  @override
  void addWorkout(Workout workout) {
    if (_user == null) {
      print('No user to add workout');
      return;
    }
    _user!.program.workouts.add(workout);
    notifyListeners();
  }

  @override
  void updateWorkout(int index, Workout workout) {
    if (_user == null) {
      print('No user to update workout');
      return;
    }
    _user!.program.workouts[index] = workout;
    notifyListeners();
  }

  @override
  void reorderWorkouts(int oldIndex, int newIndex) {
    if (_user == null) {
      print('No user to reorder workouts');
      return;
    }
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final workout = _user!.program.workouts.removeAt(oldIndex);
    _user!.program.workouts.insert(newIndex, workout);
    notifyListeners();
  }

  @override
  void deleteWorkout(int index) {
    if (_user == null) {
      print('No user to delete workout');
      return;
    }
    _user!.program.workouts.removeAt(index);
    notifyListeners();
  }

  @override
  Future<bool> saveProgram() async {
    if (_user == null) {
      print('No user to save program');
      return false;
    }
    return await Backend.saveProgram(_user!.id, _user!.program);
  }

  @override
  bool isWorkoutInProgram(String workoutName, int? workoutIndexToIgnore) {
    if (user == null) {
      return false;
    }

    final foundIndex = user!.program.workouts.indexWhere((workout) =>
        workout.name.toLowerCase().trim() == workoutName.toLowerCase().trim());

    return foundIndex != -1 &&
        (workoutIndexToIgnore == null || foundIndex != workoutIndexToIgnore);
  }
}
