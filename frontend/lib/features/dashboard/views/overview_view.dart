import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../auth/view_models/auth_view_model.dart';

class OverviewView extends StatelessWidget {
  const OverviewView({super.key});
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().user!;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Olá, ${user.name.split(' ').first}',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Cada acesso segue um fluxo governado e deixa uma evidência verificável.',
        ),
        const SizedBox(height: 24),
        ...const [
          (
            LucideIcons.filePenLine,
            'Solicitar',
            'Informe o módulo e a justificativa.',
          ),
          (
            LucideIcons.listChecks,
            'Aprovar',
            'TI avalia com segregação de funções.',
          ),
          (
            LucideIcons.lockOpen,
            'Utilizar',
            'A API libera somente acessos concedidos.',
          ),
          (LucideIcons.history, 'Auditar', 'Ações críticas entram na trilha.'),
        ].map(
          (x) => Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(18),
              leading: Icon(x.$1),
              title: Text(
                x.$2,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(x.$3),
            ),
          ),
        ),
      ],
    );
  }
}
