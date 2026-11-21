import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../view_models/audit_view_model.dart';

class AuditView extends StatefulWidget {
  const AuditView({super.key});
  @override
  State<AuditView> createState() => _AuditViewState();
}

class _AuditViewState extends State<AuditView> {
  final search = TextEditingController();
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AuditViewModel>().load());
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuditViewModel>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: ListTile(
            leading: const Icon(LucideIcons.badgeCheck),
            title: Text(
              vm.integrity?['valid'] == true
                  ? 'Cadeia íntegra'
                  : 'Verificando integridade',
            ),
            subtitle: Text(
              '${vm.integrity?['records'] ?? 0} registros verificados',
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: search,
          onSubmitted: vm.load,
          decoration: InputDecoration(
            labelText: 'Buscar evento',
            suffixIcon: IconButton(
              onPressed: () => vm.load(search.text),
              icon: const Icon(LucideIcons.search),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (vm.loading)
          const Center(child: CircularProgressIndicator())
        else if (vm.items.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Text('Nenhum evento encontrado.'),
            ),
          )
        else
          ...vm.items.map(
            (e) => Card(
              child: ListTile(
                title: Text(e.action.replaceAll('_', ' ')),
                subtitle: Text(
                  '${e.actorName ?? 'Sistema'} · ${e.resource}\nHash ${e.hash.substring(0, 10)}…',
                ),
                trailing: Chip(label: Text(e.result)),
              ),
            ),
          ),
      ],
    );
  }
}
