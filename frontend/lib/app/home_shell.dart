import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../features/auth/models/app_user.dart';
import '../features/auth/view_models/auth_view_model.dart';
import '../features/dashboard/views/overview_view.dart';
import '../features/dashboard/views/dashboard_view.dart';
import '../features/access_requests/views/requests_view.dart';
import '../features/financial_resources/views/resources_view.dart';
import '../features/audit/views/audit_view.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final role = auth.user!.role;
    final tabs = switch (role) {
      UserRole.assessor => const [
        ('Visão geral', LucideIcons.house, OverviewView()),
        ('Solicitações', LucideIcons.clipboardList, RequestsView()),
        ('Módulos', LucideIcons.landmark, ResourcesView()),
      ],
      UserRole.gestor => const [
        ('Visão geral', LucideIcons.house, OverviewView()),
        ('Aprovações', LucideIcons.listChecks, RequestsView(manager: true)),
        ('Módulos', LucideIcons.landmark, ResourcesView()),
      ],
      UserRole.compliance => const [
        ('Visão geral', LucideIcons.house, OverviewView()),
        ('Auditoria', LucideIcons.history, AuditView()),
      ],
      UserRole.direcao => const [
        ('Indicadores', LucideIcons.layoutDashboard, DashboardView()),
      ],
    };
    if (index >= tabs.length) index = 0;
    return Scaffold(
      appBar: AppBar(
        title: Text(tabs[index].$1),
        actions: [
          IconButton(
            onPressed: auth.logout,
            tooltip: 'Sair',
            icon: const Icon(LucideIcons.logOut),
          ),
        ],
      ),
      body: tabs[index].$3,
      bottomNavigationBar: tabs.length == 1
          ? null
          : NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (i) => setState(() => index = i),
              destinations: tabs
                  .map(
                    (t) => NavigationDestination(icon: Icon(t.$2), label: t.$1),
                  )
                  .toList(),
            ),
    );
  }
}
