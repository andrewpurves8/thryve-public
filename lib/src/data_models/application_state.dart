import 'package:flutter/material.dart';

abstract class ApplicationState extends ChangeNotifier {
  void setSearchedExerciseId(String searchedExerciseId);
  void setSelectedWorkoutIndex(int? selectedWorkoutIndex);

  String get searchedExerciseId;
  int? get selectedWorkoutIndex;
}

class ApplicationStateImplementation extends ApplicationState {
  String _searchedExerciseId = '';
  int? _selectedWorkoutIndex;

  @override
  String get searchedExerciseId => _searchedExerciseId;

  @override
  int? get selectedWorkoutIndex => _selectedWorkoutIndex;

  @override
  void setSearchedExerciseId(String searchedExerciseId) {
    _searchedExerciseId = searchedExerciseId;
    notifyListeners();
  }

  @override
  void setSelectedWorkoutIndex(int? selectedWorkoutIndex) {
    _selectedWorkoutIndex = selectedWorkoutIndex;
    notifyListeners();
  }
}
