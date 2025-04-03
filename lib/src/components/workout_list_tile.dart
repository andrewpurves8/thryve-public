import 'package:flutter/material.dart';
import 'package:thryve/src/data_models/workout.dart';
import 'package:thryve/src/utilities/constants.dart';
import 'package:thryve/src/utilities/helpers.dart';

class WorkoutListTile extends StatelessWidget {
  const WorkoutListTile({
    super.key,
    required this.workout,
    this.isNext = false,
    this.onTap,
  });

  final Workout workout;
  final bool isNext;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: getHorizontalMargin(context),
        vertical: 5.0,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(
              color: isNext ? kPrimaryColor : kDarkGrey,
              width: 2.0,
            ),
            color: kDarkGrey,
          ),
          child: ListTile(
            title: Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Text(workout.name, style: const TextStyle(fontSize: 20)),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final exercise in workout.exercises)
                  Text(
                      '${exercise.sets.length} x ${exercise.sets[0].reps} ${exercise.name}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
