import 'package:flutter/foundation.dart';
import '../models/access_request.dart';
import '../repositories/access_repository.dart';

class AccessViewModel extends ChangeNotifier {
  final AccessRepository repository;
  AccessViewModel(this.repository);
  List<AccessRequestModel> items = [];
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

  Future<bool> create(String id, String text) async {
    if (text.trim().length < 10) {
      error = 'A justificativa deve ter ao menos 10 caracteres.';
      notifyListeners();
      return false;
    }
    return _act(() => repository.create(id, text));
  }

  Future<bool> decide(String id, bool approve) =>
      _act(() => repository.decide(id, approve));
  Future<bool> revoke(String id) => _act(() => repository.revoke(id));
  Future<bool> _act(Future<void> Function() fn) async {
    try {
      await fn();
      await load();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
