import '../../../core/services/api_service.dart';
import '../models/access_request.dart';

class AccessRepository {
  final ApiService api;
  AccessRepository(this.api);
  Future<List<AccessRequestModel>> list() async =>
      ((await api.request('/api/requests')) as List)
          .map((x) => AccessRequestModel.fromJson(x))
          .toList();
  Future<void> create(String resourceId, String justification) => api.request(
    '/api/requests',
    method: 'POST',
    body: {'resourceId': resourceId, 'justification': justification},
  );
  Future<void> decide(String id, bool approve) => api.request(
    '/api/requests/$id/decision',
    method: 'POST',
    body: {'decision': approve ? 'aprovar' : 'negar'},
  );
  Future<void> revoke(String id) =>
      api.request('/api/requests/$id/revoke', method: 'POST');
}
