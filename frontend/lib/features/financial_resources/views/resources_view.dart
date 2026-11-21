import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../view_models/resource_view_model.dart';

class ResourcesView extends StatefulWidget {
  const ResourcesView({super.key});
  @override
  State<ResourcesView> createState() => _ResourcesViewState();
}

class _ResourcesViewState extends State<ResourcesView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ResourceViewModel>().load());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ResourceViewModel>();
    return vm.loading
        ? const Center(child: CircularProgressIndicator())
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: vm.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final r = vm.items[i];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Icon(
                    r.allowed ? LucideIcons.lockOpen : LucideIcons.lock,
                  ),
                  title: Text(r.name),
                  subtitle: Text(
                    '${r.description}\n${r.allowed ? 'Acesso liberado' : 'Acesso restrito'}',
                  ),
                  isThreeLine: true,
                  onTap: () async {
                    final data = await vm.open(r.code);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          data == null
                              ? (vm.error ?? 'Acesso negado')
                              : data['notice'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
  }
}
