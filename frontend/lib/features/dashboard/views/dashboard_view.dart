import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/dashboard_view_model.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});
  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<DashboardViewModel>().load());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    if (vm.loading) return const Center(child: CircularProgressIndicator());
    final d = vm.data;
    if (d == null)
      return Center(child: Text(vm.error ?? 'Indicadores indisponíveis.'));
    final values = {
      'MFA ativo': '${d['mfa_percent']}%',
      'Pendentes': '${d['pending']}',
      'Aprovadas': '${d['approved']}',
      'Negadas': '${d['denied']}',
      'Revogadas': '${d['revoked']}',
      'Tentativas negadas': '${d['denied_attempts']}',
      'Sem aprovação': '${d['grants_without_approval']}',
    };
    return GridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: values.entries
          .map(
            (e) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key),
                    Text(
                      e.value,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
