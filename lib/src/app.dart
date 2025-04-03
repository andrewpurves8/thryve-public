import 'package:flutter/material.dart';
import 'package:thryve/src/utilities/constants.dart';
import 'package:thryve/src/views/active_workout_view.dart';
import 'package:thryve/src/views/history_view.dart';
import 'package:thryve/src/views/search_exercise_view.dart';
import 'package:thryve/src/views/edit_workout_view.dart';
import 'package:thryve/src/views/edit_program_view.dart';
import 'package:thryve/src/views/home_view.dart';
import 'package:thryve/src/views/login_view.dart';
import 'package:thryve/src/views/register_view.dart';

class ThryveApp extends StatefulWidget {
  const ThryveApp({super.key});

  @override
  State<ThryveApp> createState() => _ThryveAppState();
}

class _ThryveAppState extends State<ThryveApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'THRYVE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          // seedColor: kSeedColor,
          primary: kPrimaryColor,
          onPrimary: kWhite,
          secondary: kBlack,
          onSecondary: kLightGrey,
          error: Colors.red,
          onError: kWhite,
          surface: kBlack,
          onSurface: kWhite,
        ),
        fontFamily: 'Instrument Sans',
        useMaterial3: true,
        scaffoldBackgroundColor: kBlack,
        appBarTheme: const AppBarTheme(
          backgroundColor: kBlack,
          surfaceTintColor: kBlack,
        ),
      ),
      themeMode: ThemeMode.dark,
      initialRoute: LoginView.routeName,
      onGenerateRoute: (RouteSettings routeSettings) {
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (BuildContext context) {
            switch (routeSettings.name) {
              case LoginView.routeName:
                return const LoginView();
              case RegisterView.routeName:
                return const RegisterView();
              case EditProgramView.routeName:
                return const EditProgramView();
              case EditWorkoutView.routeName:
                return const EditWorkoutView();
              case SearchExerciseView.routeName:
                return const SearchExerciseView();
              case ActiveWorkoutView.routeName:
                return const ActiveWorkoutView();
              case HistoryView.routeName:
                return const HistoryView();
              case HomeView.routeName:
              default:
                return const HomeView();
            }
          },
        );
      },
    );
  }
}
