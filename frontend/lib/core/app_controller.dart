import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/api_client.dart';
import 'api/api_models.dart';

class AppController extends ChangeNotifier {
  AppController({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient(),
      _session = null;

  static const _sessionStorageKey = 'session';

  final ApiClient _apiClient;

  SharedPreferences? _preferences;
  UserSession? _session;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _session != null;
  UserSession? get session => _session;
  ApiClient get apiClient => _apiClient;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    _preferences = await SharedPreferences.getInstance();
    final rawSession = _preferences?.getString(_sessionStorageKey);
    if (rawSession != null && rawSession.isNotEmpty) {
      try {
        _session = UserSession.fromJson(
          jsonDecode(rawSession) as Map<String, dynamic>,
        );
      } catch (_) {
        await _preferences?.remove(_sessionStorageKey);
      }
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> signIn({required String email, required String password}) async {
    final result = await _apiClient.login(email: email, password: password);
    await _setSession(result);
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    final result = await _apiClient.signUp(
      fullName: fullName,
      email: email,
      password: password,
      phone: phone,
      role: role,
    );
    await _setSession(result);
  }

  Future<void> logout() async {
    _session = null;
    await _preferences?.remove(_sessionStorageKey);
    notifyListeners();
  }

  Future<void> _setSession(AuthResponse result) async {
    _session = UserSession(token: result.token, user: result.user);
    await _preferences?.setString(
      _sessionStorageKey,
      jsonEncode(_session!.toJson()),
    );
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AppController> {
  const AppScope({
    super.key,
    required AppController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!.notifier!;
  }
}
