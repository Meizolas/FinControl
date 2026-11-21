import 'package:flutter_test/flutter_test.dart';
import 'package:fincontrol/features/access_requests/models/access_request.dart';
import 'package:fincontrol/features/access_requests/repositories/access_repository.dart';
import 'package:fincontrol/features/access_requests/view_models/access_view_model.dart';
import 'package:fincontrol/core/services/api_service.dart';

class FakeAccessRepository implements AccessRepository {
  @override
  ApiService get api => throw UnimplementedError();
  bool shouldFail = false;
  int creates = 0;
  @override
  Future<List<AccessRequestModel>> list() async {
    if (shouldFail) throw Exception('API indisponível');
    return [];
  }

  @override
  Future<void> create(String resourceId, String justification) async {
    creates++;
  }

  @override
  Future<void> decide(String id, bool approve) async {}
  @override
  Future<void> revoke(String id) async {}
}

void main() {
  group('AccessViewModel', () {
    test('valida justificativa antes de enviar', () async {
      final repo = FakeAccessRepository();
      final vm = AccessViewModel(repo);
      expect(await vm.create('id', 'curta'), isFalse);
      expect(repo.creates, 0);
      expect(vm.error, contains('10 caracteres'));
    });
    test('envia solicitação válida e atualiza a lista', () async {
      final repo = FakeAccessRepository();
      final vm = AccessViewModel(repo);
      expect(await vm.create('id', 'Justificativa válida para acesso'), isTrue);
      expect(repo.creates, 1);
    });
    test('expõe erro recebido do repositório', () async {
      final repo = FakeAccessRepository()..shouldFail = true;
      final vm = AccessViewModel(repo);
      await vm.load();
      expect(vm.error, contains('API indisponível'));
      expect(vm.loading, isFalse);
    });
  });
}
