import '../../../core/services/api_service.dart';

class DashboardRepository {
  final ApiService api;
  DashboardRepository(this.api);
  Future<Map<String, dynamic>> load() async =>
      Map<String, dynamic>.from(await api.request('/api/dashboard'));
}
