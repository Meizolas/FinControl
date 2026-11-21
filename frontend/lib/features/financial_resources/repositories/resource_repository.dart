import '../../../core/services/api_service.dart';
import '../models/financial_resource.dart';

class ResourceRepository {
  final ApiService api;
  ResourceRepository(this.api);
  Future<List<FinancialResource>> list() async =>
      ((await api.request('/api/resources')) as List)
          .map((x) => FinancialResource.fromJson(x))
          .toList();
  Future<Map<String, dynamic>> open(String code) async =>
      Map<String, dynamic>.from(await api.request('/api/modules/$code'));
}
