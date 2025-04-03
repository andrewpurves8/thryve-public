import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:thryve/src/components/big_button.dart';
import 'package:thryve/src/components/rounded_button.dart';
import 'package:thryve/src/components/workout_list_tile.dart';
import 'package:thryve/src/data_models/active_workout_state.dart';
import 'package:thryve/src/data_models/user_state.dart';
import 'package:thryve/src/utilities/constants.dart';
import 'package:thryve/src/views/active_workout_view.dart';
import 'package:thryve/src/views/edit_program_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  static const routeName = '/home';

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    GetIt.I<UserState>().addListener(_updateState);
    GetIt.I<ActiveWorkoutState>().addListener(_updateState);
    GetIt.I<ActiveWorkoutState>().tryLoadActiveWorkout().then((success) {
      if (success && mounted) {
        Navigator.pushNamed(context, ActiveWorkoutView.routeName);
      }
    });
  }

  @override
  void dispose() {
    GetIt.I<UserState>().removeListener(_updateState);
    GetIt.I<ActiveWorkoutState>().removeListener(_updateState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = GetIt.I<UserState>().user;
    if (user == null) {
      return const Scaffold(body: SizedBox());
    }

    final workouts = user.program.workouts;
    final nextWorkoutIndex = user.getNextWorkoutIndex();

    return SafeArea(
      child: Scaffold(
        appBar: workouts.isEmpty
            ? null
            : AppBar(
                title: const Text('Your program'),
                actions: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: _editProgram,
                  )
                ],
              ),
        body: workouts.isEmpty
            ? Center(
                child: BigButton(
                  text: 'Create program',
                  onPressed: _editProgram,
                  iconTrailing: Icons.fitness_center_rounded,
                ),
              )
            : Column(
                children: [
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: workouts.length,
                      itemBuilder: (context, index) {
                        return WorkoutListTile(
                          workout: workouts[index],
                          isNext: index == nextWorkoutIndex,
                          onTap: () {
                            GetIt.I<ActiveWorkoutState>()
                                .startWorkout(workouts[index]);
                            Navigator.of(context)
                                .pushNamed(ActiveWorkoutView.routeName);
                          },
                        );
                      },
                    ),
                  ),
                  if (GetIt.I<ActiveWorkoutState>().activeWorkout != null)
                    RoundedButton(
                      text: 'Continue workout',
                      onPressed: () => Navigator.of(context)
                          .pushNamed(ActiveWorkoutView.routeName),
                      color: kPrimaryColor,
                      textColor: kWhite,
                    ),
                  const SizedBox(height: 10),
                ],
              ),
      ),
    );
  }

  void _updateState() => setState(() {});

  void _editProgram() {
    Navigator.of(context).pushNamed(EditProgramView.routeName);
  }
}
