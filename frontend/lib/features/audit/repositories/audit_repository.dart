import '../../../core/services/api_service.dart';
import '../models/audit_event.dart';

class AuditRepository {
  final ApiService api;
  AuditRepository(this.api);
  Future<List<AuditEvent>> list([String q = '']) async =>
      ((await api.request('/api/audit?search=${Uri.encodeQueryComponent(q)}'))
              as List)
          .map((x) => AuditEvent.fromJson(x))
          .toList();
  Future<Map<String, dynamic>> integrity() async =>
      Map<String, dynamic>.from(await api.request('/api/audit/integrity'));
}
