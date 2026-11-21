import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository repository;
  AuthViewModel(this.repository);
  AppUser? user;
  bool loading = false;
  String? error;
  bool get authenticated => user != null;
  Future<void> restoreSession() async {
    if (await repository.hasSession) await _profile();
  }

  Future<void> login() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await repository.login();
      await _profile();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loginDemo(String email) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await repository.loginDemo(email);
      await _profile();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> _profile() async {
    try {
      user = await repository.profile();
      error = null;
    } catch (e) {
      error = e.toString();
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await repository.logout();
    user = null;
    notifyListeners();
  }
}
