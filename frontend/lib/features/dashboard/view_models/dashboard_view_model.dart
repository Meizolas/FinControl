import 'package:flutter/foundation.dart';
import '../repositories/dashboard_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  final DashboardRepository repository;
  DashboardViewModel(this.repository);
  Map<String, dynamic>? data;
  bool loading = false;
  String? error;
  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      data = await repository.load();
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
