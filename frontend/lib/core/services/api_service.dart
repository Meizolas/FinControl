import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../errors/app_exception.dart';
import '../../features/auth/services/auth_service.dart';

class ApiService {
  final AuthService auth;
  final http.Client _client;
  ApiService(this.auth, [http.Client? client])
    : _client = client ?? http.Client();
  Future<dynamic> request(
    String path, {
    String method = 'GET',
    Object? body,
  }) async {
    final token = await auth.accessToken;
    final demoUser = await auth.demoUserEmail;
    final req = http.Request(method, Uri.parse('${AppConfig.apiUrl}$path'));
    req.headers.addAll({
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      if (demoUser != null) 'X-Demo-User': demoUser,
    });
    if (body != null) req.body = jsonEncode(body);
    final response = await _client.send(req);
    final text = await response.stream.bytesToString();
    final data = text.isEmpty ? null : jsonDecode(text);
    if (response.statusCode < 200 || response.statusCode >= 300)
      throw AppException(
        data is Map
            ? data['error'] ?? 'Operação não concluída.'
            : 'Operação não concluída.',
      );
    return data;
  }
}
