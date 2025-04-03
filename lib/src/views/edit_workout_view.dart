import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:thryve/src/components/big_button.dart';
import 'package:thryve/src/components/small_int_text_field.dart';
import 'package:thryve/src/data_models/exercise.dart';
import 'package:thryve/src/data_models/application_state.dart';
import 'package:thryve/src/data_models/user_state.dart';
import 'package:thryve/src/data_models/workout.dart';
import 'package:thryve/src/utilities/constants.dart';
import 'package:thryve/src/utilities/helpers.dart';
import 'package:thryve/src/views/search_exercise_view.dart';

class EditWorkoutView extends StatefulWidget {
  const EditWorkoutView({super.key});

  static const routeName = '/edit_workout';

  @override
  State<EditWorkoutView> createState() => _EditWorkoutViewState();
}

class _EditWorkoutViewState extends State<EditWorkoutView> {
  static const _deleteWorkout = 'Delete workout';

  late final TextEditingController _textController;
  late final Workout _workout;

  @override
  void initState() {
    super.initState();
    final selectedWorkoutIndex =
        GetIt.I<ApplicationState>().selectedWorkoutIndex;
    final user = GetIt.I<UserState>().user;
    if (user == null) {
      print('No user to edit workout');
      return;
    }

    if (selectedWorkoutIndex != null) {
      final selectedWorkout =
          Workout.from(user.program.workouts[selectedWorkoutIndex]);
      _textController = TextEditingController(text: selectedWorkout.name);
      _workout = selectedWorkout;
    } else {
      final initialName = 'Day ${user.program.workouts.length + 1}';
      _textController = TextEditingController(text: initialName);
      _workout = Workout(
        name: initialName,
        exercises: [],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit workout'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addExercise,
            ),
            PopupMenuButton<String>(
              onSelected: (String choice) {
                if (choice == _deleteWorkout) {
                  final selectedWorkoutIndex =
                      GetIt.I<ApplicationState>().selectedWorkoutIndex;
                  if (selectedWorkoutIndex != null) {
                    GetIt.I<UserState>().deleteWorkout(
                      GetIt.I<ApplicationState>().selectedWorkoutIndex!,
                    );
                  }
                  Navigator.of(context).pop();
                }
              },
              itemBuilder: (BuildContext context) {
                return {_deleteWorkout}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: _workout.exercises.isEmpty
            ? Center(
                child: Text('No exercises added'),
              )
            : Column(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.only(left: getHorizontalMargin(context)),
                    child: TextField(
                      controller: _textController,
                      onChanged: (value) => _workout.name = value,
                      style: const TextStyle(fontSize: 20),
                      decoration: InputDecoration(border: InputBorder.none),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Expanded(
                    child: ReorderableListView.builder(
                      itemCount: _workout.exercises.length,
                      itemBuilder: (context, index) => ExerciseTile(
                        key: Key(
                          _workout.exercises[index].name + index.toString(),
                        ),
                        exercise: _workout.exercises[index],
                        setSets: (sets) => setState(() {
                          _workout.exercises[index].setSetCount(sets);
                        }),
                        setReps: (reps) => setState(() {
                          _workout.exercises[index].setSetReps(reps);
                        }),
                        onDelete: () => setState(() {
                          _workout.exercises.removeAt(index);
                        }),
                      ),
                      onReorder: (oldIndex, newIndex) {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final exercise = _workout.exercises.removeAt(oldIndex);
                        _workout.exercises.insert(newIndex, exercise);
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  BigButton(
                    text: 'Save workout',
                    iconTrailing: Icons.save,
                    onPressed: _saveWorkout,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
      ),
    );
  }

  void _addExercise() {
    Navigator.of(context).pushNamed(SearchExerciseView.routeName).then((_) {
      final exerciseId = GetIt.I<ApplicationState>().searchedExerciseId;
      if (exerciseId.isEmpty) {
        return;
      }
      GetIt.I<ApplicationState>().setSearchedExerciseId('');
      setState(() {
        _workout.exercises.add(Exercise.fromId(exerciseId));
      });
    });
  }

  void _saveWorkout() {
    final selectedWorkoutIndex =
        GetIt.I<ApplicationState>().selectedWorkoutIndex;

    if (GetIt.I<UserState>().isWorkoutInProgram(
      _workout.name,
      selectedWorkoutIndex,
    )) {
      showToast('Workout name already exists');
      return;
    }

    if (selectedWorkoutIndex != null) {
      GetIt.I<UserState>().updateWorkout(selectedWorkoutIndex, _workout);
    } else {
      GetIt.I<UserState>().addWorkout(_workout);
    }
    Navigator.of(context).pop();
  }
}

class ExerciseTile extends StatefulWidget {
  const ExerciseTile({
    super.key,
    required this.exercise,
    required this.setSets,
    required this.setReps,
    required this.onDelete,
  });

  final Exercise exercise;
  final void Function(int) setSets;
  final void Function(int) setReps;
  final void Function() onDelete;

  @override
  State<ExerciseTile> createState() => _ExerciseTileState();
}

class _ExerciseTileState extends State<ExerciseTile> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: getHorizontalMargin(context),
        vertical: 5.0,
      ),
      child: GestureDetector(
        onTap: () => setState(() {
          _isEditing = !_isEditing;
        }),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: kDarkGrey,
          ),
          child: ListTile(
            title: Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Text(widget.exercise.name),
            ),
            trailing: _isEditing
                ? Icon(Icons.arrow_drop_up)
                : Icon(Icons.arrow_drop_down),
            leading: _isEditing
                ? IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: widget.onDelete,
                  )
                : null,
            subtitle: _isEditing
                ? Row(
                    children: [
                      SmallIntTextField(
                        initialValue: widget.exercise.sets.length,
                        onChanged: widget.setSets,
                      ),
                      const SizedBox(width: 5),
                      const Text('sets of'),
                      const SizedBox(width: 5),
                      SmallIntTextField(
                        initialValue: widget.exercise.sets[0].reps,
                        onChanged: widget.setReps,
                      ),
                      const SizedBox(width: 5),
                      const Text('reps'),
                    ],
                  )
                : Text(
                    '${widget.exercise.sets.length} sets of ${widget.exercise.sets[0].reps} reps'),
          ),
        ),
      ),
    );
  }
}
