import 'dart:convert';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:thryve/src/data_models/program.dart';
import 'package:thryve/src/data_models/user.dart';
import 'package:thryve/src/data_models/user_state.dart';
import 'package:thryve/src/data_models/workout.dart';
import 'package:thryve/src/utilities/constants.dart';
import 'package:thryve/src/utilities/shared_prefs.dart';

class Backend {
  static Future<bool> checkAuth() async {
    final userId = await loadUserId();
    if (userId.isEmpty) {
      return false;
    }

    final res = await _backendGetAuth('$kUserEndpoint$userId');
    if (_isResponseInvalid(res)) {
      return false;
    }

    final userMap = _mapFromJsonString(res.body);
    final user = User.fromMap(userMap);
    GetIt.I<UserState>().setUser(user);

    return true;
  }

  static Future<User?> backendGetUser(String userId) async {
    final res = await _backendGetAuth('$kUserEndpoint$userId');

    if (_isResponseInvalid(res)) {
      _printBackendError(res);
      return null;
    }

    final userMap = _mapFromJsonString(res.body);
    return User.fromMap(userMap);
  }

  static Future<bool> login(String email, String password) async {
    final data = <String, String>{
      'email': email,
      'password': password,
    };

    final res = await _backendPost(kLoginEndpoint, data);
    if (_isResponseInvalid(res)) {
      _printBackendError(res);
      return false;
    }

    final resData = _mapFromJsonString(res.body);
    final userMap = resData['user']!;
    final user = User.fromMap(userMap);

    GetIt.I<UserState>().setUser(user);
    await saveUserId(user.id);
    await saveUserJwt(resData['jwt']!);

    return true;
  }

  static Future<bool> register(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    final data = <String, String>{
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
    };

    final res = await _backendPost(kRegisterEndpoint, data);
    if (_isResponseInvalid(res)) {
      _printBackendError(res);
      return false;
    }

    final resData = _mapFromJsonString(res.body);
    final userData = resData['user']!;
    final user = User.fromMap(userData);
    GetIt.I<UserState>().setUser(user);

    await saveUserId(user.id);
    await saveUserJwt(resData['jwt']!);

    return true;
  }

  static Future<bool> saveProgram(String userId, Program program) async {
    final data = <String, dynamic>{
      'program': program,
    };

    final res =
        await _backendPostAuth('$kUserEndpoint$userId', data, put: true);
    if (_isResponseInvalid(res)) {
      _printBackendError(res);
      return false;
    }

    return true;
  }

  // assumes that the workout is already in the active workout state
  static Future<bool> logWorkout(String userId, Workout workout) async {
    final data = <String, dynamic>{
      'workout': workout,
    };

    final res =
        await _backendPostAuth('$kUserEndpoint$userId$kLogWorkoutSuffix', data);
    if (_isResponseInvalid(res)) {
      _printBackendError(res);
      return false;
    }

    return true;
  }

  static Future<http.Response> _backendGet(
    String endPoint, {
    Map<String, String> query = const {},
    Map<String, String> headers = const {},
  }) {
    return _backendGetHeaders(endPoint, query, headers);
  }

  static Future<http.Response> _backendGetAuth(
    String endPoint, {
    Map<String, String> query = const {},
    Map<String, String> headers = const {},
  }) async {
    Map<String, String> mergedHeaders = {};
    mergedHeaders.addAll(headers);
    mergedHeaders.addAll(await _createAuthHeader());
    return _backendGetHeaders(endPoint, query, mergedHeaders);
  }

  static Future<http.Response> _backendGetHeaders(
    String endPoint,
    Map<String, String> query,
    Map<String, String> headers,
  ) async {
    final queryString = _createQueryString(query);
    final res = await http.get(
      Uri.parse('$kBackendAddress$endPoint$queryString'),
      headers: headers,
    );
    return res;
  }

  static Future<http.Response> _backendPost(
    String endPoint,
    Map<String, dynamic> data, {
    Map<String, String> query = const {},
    Map<String, String> headers = const {},
    bool put = false,
  }) {
    return _backendPostHeaders(endPoint, data, query, headers, put);
  }

  static Future<http.Response> _backendPostAuth(
    String endPoint,
    Map<String, dynamic> data, {
    Map<String, String> query = const {},
    Map<String, String> headers = const {},
    bool put = false,
  }) async {
    Map<String, String> mergedHeaders = {};
    mergedHeaders.addAll(headers);
    mergedHeaders.addAll(await _createAuthHeader());
    return _backendPostHeaders(endPoint, data, query, mergedHeaders, put);
  }

  static Future<http.Response> _backendPostHeaders(
      String endPoint,
      Map<String, dynamic> data,
      Map<String, String> query,
      Map<String, String> headers,
      bool put) async {
    final queryString = _createQueryString(query);
    final method = put ? http.put : http.post;
    final res = await method(
      Uri.parse('$kBackendAddress$endPoint$queryString'),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        ...headers
      },
      body: jsonEncode(data),
    );
    return res;
  }

  static Map<String, dynamic> _mapFromJsonString(String json) {
    return jsonDecode(json) as Map<String, dynamic>;
  }

  static List<Map<String, dynamic>> _listOfMapsFromJsonString(String json) {
    final List<Map<String, dynamic>> result = [];
    try {
      final jsonList = jsonDecode(json) as List;
      for (final entry in jsonList) {
        result.add(entry as Map<String, dynamic>);
      }
    } catch (e) {
      print('Failed to convert JSON string to list of maps: $json');
    }
    return result;
  }

  static String _getTokenFromCookie(http.Response res) {
    final cookie = res.headers['set-cookie']!;
    return cookie.substring(cookie.indexOf('jwt=') + 4, cookie.indexOf(';'));
  }

  static bool _isResponseInvalid(http.Response res) {
    return res.statusCode > 299;
  }

  static void _printBackendError(http.Response res) {
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    print(
        'Failed to ${res.request!.method} ${res.request!.url} (${res.statusCode}): ${body['message'] ?? 'Unknown error'}');
  }

  static Future<Map<String, String>> _createAuthHeader() async {
    String jwt = await loadUserJwt();
    return <String, String>{
      HttpHeaders.authorizationHeader: 'Basic $jwt',
    };
  }

  static String _createQueryString(Map<String, String> query) {
    if (query.entries.isEmpty) {
      return '';
    }
    String queryString = '?';
    for (final entry in query.entries) {
      queryString += '${entry.key}=${entry.value}&';
    }
    return queryString.substring(0, queryString.length - 1);
  }
}
