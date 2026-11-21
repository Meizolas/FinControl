import '../../../core/services/api_service.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService service;
  AuthRepository(this.service);
  Future<void> login() => service.login();
  Future<void> loginDemo(String email) => service.loginDemo(email);
  Future<void> logout() => service.logout();
  Future<bool> get hasSession => service.hasSession;
  Future<AppUser> profile() async =>
      AppUser.fromJson(await ApiService(service).request('/api/me'));
}
