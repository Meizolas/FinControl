import 'package:flutter/foundation.dart';
import '../models/audit_event.dart';
import '../repositories/audit_repository.dart';

class AuditViewModel extends ChangeNotifier {
  final AuditRepository repository;
  AuditViewModel(this.repository);
  List<AuditEvent> items = [];
  Map<String, dynamic>? integrity;
  bool loading = false;
  String? error;
  Future<void> load([String q = '']) async {
    loading = true;
    notifyListeners();
    try {
      items = await repository.list(q);
      integrity = await repository.integrity();
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
