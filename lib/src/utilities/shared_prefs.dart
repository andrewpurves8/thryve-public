import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveUserJwt(String jwt) async {
  SharedPreferences.getInstance()
      .then((prefs) => prefs.setString('userJwt', jwt));
}

Future<String> loadUserJwt() async {
  return (await SharedPreferences.getInstance()).getString('userJwt') ?? '';
}

Future<void> saveUserId(String id) async {
  SharedPreferences.getInstance()
      .then((prefs) => prefs.setString('userId', id));
}

Future<String> loadUserId() async {
  return (await SharedPreferences.getInstance()).getString('userId') ?? '';
}

// Future<void> saveAuthState(bool state) async {
//   SharedPreferences.getInstance()
//       .then((prefs) => prefs.setBool('authState', state));
// }

// Future<bool> loadAuthState() async {
//   return (await SharedPreferences.getInstance()).getBool('authState') ?? false;
// }

Future<void> saveActiveWorkoutJson(String activeWorkoutJson) async {
  SharedPreferences.getInstance()
      .then((prefs) => prefs.setString('activeWorkoutJson', activeWorkoutJson));
}

Future<String> loadActiveWorkoutJson() async {
  return (await SharedPreferences.getInstance())
          .getString('activeWorkoutJson') ??
      '';
}

Future<void> saveActiveWorkoutMetadataJson(
    String activeWorkoutMetadataJson) async {
  SharedPreferences.getInstance().then((prefs) =>
      prefs.setString('activeWorkoutMetadataJson', activeWorkoutMetadataJson));
}

Future<String> loadActiveWorkoutMetadataJson() async {
  return (await SharedPreferences.getInstance())
          .getString('activeWorkoutMetadataJson') ??
      '';
}
