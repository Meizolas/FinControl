import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../../../core/config/app_config.dart';

class AuthService {
  final _appAuth = const FlutterAppAuth();
  final _storage = const FlutterSecureStorage();
  String? _webDemoUser;

  Future<String?> get accessToken async =>
      kIsWeb ? null : _storage.read(key: 'access_token');
  Future<String?> get demoUserEmail async =>
      kIsWeb ? _webDemoUser : _storage.read(key: 'demo_user');
  Future<bool> get hasSession async =>
      (await accessToken) != null || (await demoUserEmail) != null;

  Future<void> loginDemo(String email) async {
    if (kIsWeb) {
      _webDemoUser = email;
      return;
    }
    await _storage.delete(key: 'access_token');
    await _storage.write(key: 'demo_user', value: email);
  }

  Future<void> login() async {
    if (kIsWeb) {
      throw UnsupportedError(
        'Use o modo demonstração no Chrome. Keycloak + MFA está disponível no Android.',
      );
    }
    await _storage.delete(key: 'demo_user');
    final r = await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        AppConfig.clientId,
        AppConfig.redirectUrl,
        discoveryUrl: '${AppConfig.issuer}/.well-known/openid-configuration',
        scopes: const ['openid', 'profile', 'email'],
        promptValues: const ['login'],
        additionalParameters: const {'ui_locales': 'pt-BR'},
        allowInsecureConnections: kDebugMode,
      ),
    );
    if (r.accessToken == null) {
      throw Exception('O provedor não devolveu um token válido.');
    }
    await _storage.write(key: 'access_token', value: r.accessToken);
  }

  Future<void> logout() async {
    if (kIsWeb) {
      _webDemoUser = null;
      return;
    }
    await _storage.deleteAll();
  }
}
