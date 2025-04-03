import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:thryve/src/components/big_button.dart';
import 'package:thryve/src/components/workout_list_tile.dart';
import 'package:thryve/src/data_models/application_state.dart';
import 'package:thryve/src/data_models/user_state.dart';
import 'package:thryve/src/utilities/helpers.dart';
import 'package:thryve/src/views/edit_workout_view.dart';

class EditProgramView extends StatefulWidget {
  const EditProgramView({super.key});

  static const routeName = '/edit_program';

  @override
  State<EditProgramView> createState() => _EditProgramViewState();
}

class _EditProgramViewState extends State<EditProgramView> {
  @override
  void initState() {
    super.initState();
    GetIt.I<UserState>().addListener(_updateState);
  }

  @override
  void dispose() {
    GetIt.I<UserState>().removeListener(_updateState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = GetIt.I<UserState>().user;
    if (user == null) {
      return const SizedBox();
    }

    final workouts = user.program.workouts;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit program'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addWorkout,
            ),
          ],
        ),
        body: workouts.isEmpty
            ? Center(
                child: Text('No workouts added'),
              )
            : Column(
                children: [
                  Expanded(
                    child: ReorderableListView.builder(
                      itemCount: workouts.length,
                      itemBuilder: (context, index) => WorkoutListTile(
                        key: Key(workouts[index].name + index.toString()),
                        workout: workouts[index],
                        onTap: () => _onWorkoutTapped(index),
                      ),
                      onReorder: GetIt.I<UserState>().reorderWorkouts,
                    ),
                  ),
                  const SizedBox(height: 10),
                  BigButton(
                    text: 'Save program',
                    iconTrailing: Icons.save,
                    onPressed: _saveProgram,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
      ),
    );
  }

  void _updateState() => setState(() {});

  void _addWorkout() {
    GetIt.I<ApplicationState>().setSelectedWorkoutIndex(null);
    Navigator.of(context).pushNamed(EditWorkoutView.routeName);
  }

  void _onWorkoutTapped(int index) {
    GetIt.I<ApplicationState>().setSelectedWorkoutIndex(index);
    Navigator.of(context).pushNamed(EditWorkoutView.routeName).then((_) {
      GetIt.I<ApplicationState>().setSelectedWorkoutIndex(null);
    });
  }

  void _saveProgram() async {
    final success = await GetIt.I<UserState>().saveProgram();
    if (!success) {
      showToast('Failed to save program');
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
