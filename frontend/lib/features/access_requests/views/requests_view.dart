import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../view_models/access_view_model.dart';
import '../../financial_resources/view_models/resource_view_model.dart';

class RequestsView extends StatefulWidget {
  final bool manager;
  const RequestsView({super.key, this.manager = false});
  @override
  State<RequestsView> createState() => _RequestsViewState();
}

class _RequestsViewState extends State<RequestsView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AccessViewModel>().load());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AccessViewModel>();
    return Scaffold(
      floatingActionButton: widget.manager
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _create(context),
              icon: const Icon(LucideIcons.plus),
              label: const Text('Solicitar'),
            ),
      body: RefreshIndicator(
        onRefresh: vm.load,
        child: vm.loading
            ? const Center(child: CircularProgressIndicator())
            : vm.items.isEmpty
            ? ListView(
                children: const [
                  Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Text('Nenhuma solicitação encontrada.'),
                    ),
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: vm.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final r = vm.items[i];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.resourceName,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (r.requesterName != null) Text(r.requesterName!),
                          const SizedBox(height: 8),
                          Text(r.justification),
                          const SizedBox(height: 12),
                          Chip(label: Text(r.status)),
                          if (widget.manager && r.status == 'pendente')
                            Row(
                              children: [
                                FilledButton(
                                  onPressed: () => vm.decide(r.id, true),
                                  child: const Text('Aprovar'),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: () => vm.decide(r.id, false),
                                  child: const Text('Negar'),
                                ),
                              ],
                            ),
                          if (widget.manager && r.status == 'aprovada')
                            OutlinedButton.icon(
                              onPressed: () => vm.revoke(r.id),
                              icon: const Icon(LucideIcons.ban),
                              label: const Text('Revogar'),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _create(BuildContext context) async {
    final resources = context.read<ResourceViewModel>();
    final access = context.read<AccessViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    await resources.load();
    if (!context.mounted) return;
    if (resources.items.isEmpty) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            resources.error ?? 'Nenhum módulo disponível para solicitação.',
          ),
        ),
      );
      return;
    }
    String? selected = resources.items.isEmpty
        ? null
        : resources.items.first.id;
    final controller = TextEditingController();
    String? formError;
    var submitting = false;
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheet) => SafeArea(
        child: StatefulBuilder(
          builder: (sheetContext, setSheetState) => SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Nova solicitação',
                  style: Theme.of(sheetContext).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selected,
                  items: resources.items
                      .map(
                        (r) =>
                            DropdownMenuItem(value: r.id, child: Text(r.name)),
                      )
                      .toList(),
                  onChanged: submitting
                      ? null
                      : (value) => setSheetState(() {
                          selected = value;
                          formError = null;
                        }),
                  decoration: const InputDecoration(labelText: 'Módulo'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  enabled: !submitting,
                  maxLines: 3,
                  maxLength: 500,
                  onChanged: (_) => setSheetState(() => formError = null),
                  decoration: const InputDecoration(
                    labelText: 'Justificativa',
                    helperText: 'Informe pelo menos 10 caracteres.',
                  ),
                ),
                if (formError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      formError!,
                      style: TextStyle(
                        color: Theme.of(sheetContext).colorScheme.error,
                      ),
                    ),
                  ),
                FilledButton(
                  onPressed: selected == null || submitting
                      ? null
                      : () async {
                          final justification = controller.text.trim();
                          if (justification.length < 10) {
                            setSheetState(
                              () => formError =
                                  'A justificativa deve ter ao menos 10 caracteres.',
                            );
                            return;
                          }
                          setSheetState(() {
                            submitting = true;
                            formError = null;
                          });
                          final ok = await access.create(
                            selected!,
                            justification,
                          );
                          if (!sheetContext.mounted) return;
                          if (ok) {
                            Navigator.pop(sheetContext, true);
                          } else {
                            setSheetState(() {
                              submitting = false;
                              formError =
                                  access.error ??
                                  'Não foi possível enviar a solicitação.';
                            });
                          }
                        },
                  child: submitting
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Enviar solicitação'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    controller.dispose();
    if (created == true && context.mounted) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Solicitação enviada com sucesso.')),
      );
    }
  }
}
