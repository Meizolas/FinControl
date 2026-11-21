import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/widgets/brand_logo.dart';
import '../view_models/auth_view_model.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  static const _demoProfiles = <(String, String, IconData)>[
    ('Ana · Assessora', 'ana.assessora@fincontrol.demo', LucideIcons.user),
    ('Carlos · Gestor de TI', 'gestor.ti@fincontrol.demo', LucideIcons.userCog),
    (
      'Marina · Compliance',
      'compliance@fincontrol.demo',
      LucideIcons.scanSearch,
    ),
    (
      'Rafael · Direção',
      'diretor@fincontrol.demo',
      LucideIcons.chartNoAxesCombined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 48,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const BrandLogo(),
                    const Spacer(),
                    Text(
                      'Acesso certo.\nPessoa certa.\nEvidência sempre.',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Governança de acessos financeiros com autenticação multifator.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (vm.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          vm.error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    const SizedBox(height: 28),
                    Card(
                      child: ExpansionTile(
                        leading: const Icon(LucideIcons.flaskConical),
                        title: const Text('Entrar no modo demonstração'),
                        subtitle: const Text(
                          'Sem Chrome · somente ambiente local',
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          16,
                        ),
                        children: [
                          const Text(
                            'Escolha um perfil para apresentar o fluxo completo do MVP.',
                          ),
                          const SizedBox(height: 12),
                          for (final profile in _demoProfiles)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: OutlinedButton.icon(
                                onPressed: vm.loading
                                    ? null
                                    : () => vm.loginDemo(profile.$2),
                                icon: Icon(profile.$3),
                                label: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Text(profile.$1),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: vm.loading || kIsWeb ? null : vm.login,
                      icon: vm.loading
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(LucideIcons.shieldCheck),
                      label: const Padding(
                        padding: EdgeInsets.all(14),
                        child: Text(
                          kIsWeb
                              ? 'Keycloak + MFA disponível no Android'
                              : 'Entrar com Keycloak + MFA',
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'O modo demonstração não substitui o MFA real e é bloqueado em produção.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
