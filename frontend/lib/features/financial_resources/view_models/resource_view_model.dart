import 'package:flutter/foundation.dart';
import '../models/financial_resource.dart';
import '../repositories/resource_repository.dart';

class ResourceViewModel extends ChangeNotifier {
  final ResourceRepository repository;
  ResourceViewModel(this.repository);
  List<FinancialResource> items = [];
  bool loading = false;
  String? error;
  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      items = await repository.list();
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> open(String code) async {
    try {
      return await repository.open(code);
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return null;
    }
  }
}
