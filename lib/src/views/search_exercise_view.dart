import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:thryve/src/components/thryve_search_bar.dart';
import 'package:thryve/src/data_models/exercise.dart';
import 'package:thryve/src/data_models/application_state.dart';

class SearchExerciseView extends StatefulWidget {
  const SearchExerciseView({super.key});

  static const routeName = '/search_exercise';

  @override
  State<SearchExerciseView> createState() => _SearchExerciseViewState();
}

class _SearchExerciseViewState extends State<SearchExerciseView> {
  final _searchController = SearchController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ThryveSearchBar(
          searchController: _searchController,
          hintText: 'Search for an exercise',
          suggestionsBuilder: (_, SearchController controller) async {
            final results = Exercise.search(controller.text);
            final List<Widget> widgets = [];
            for (final exercise in results) {
              widgets.add(
                ListTile(
                  title: Text(exercise.name),
                  subtitle: Text(
                      '${exercise.muscleGroup.toString()} | ${exercise.type.toString()}'),
                  onTap: () async {
                    controller.closeView(controller.text);
                    GetIt.I<ApplicationState>()
                        .setSearchedExerciseId(exercise.id);
                    Navigator.of(context).pop();
                  },
                ),
              );
            }
            return widgets;
          },
        ),
      ),
    );
  }
}
