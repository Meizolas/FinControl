import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/fincontrol_app.dart';
import 'core/services/api_service.dart';
import 'features/auth/services/auth_service.dart';
import 'features/auth/repositories/auth_repository.dart';
import 'features/auth/view_models/auth_view_model.dart';
import 'features/access_requests/repositories/access_repository.dart';
import 'features/access_requests/view_models/access_view_model.dart';
import 'features/financial_resources/repositories/resource_repository.dart';
import 'features/financial_resources/view_models/resource_view_model.dart';
import 'features/audit/repositories/audit_repository.dart';
import 'features/audit/view_models/audit_view_model.dart';
import 'features/dashboard/repositories/dashboard_repository.dart';
import 'features/dashboard/view_models/dashboard_view_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  final api = ApiService(authService);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              AuthViewModel(AuthRepository(authService))..restoreSession(),
        ),
        ChangeNotifierProvider(
          create: (_) => AccessViewModel(AccessRepository(api)),
        ),
        ChangeNotifierProvider(
          create: (_) => ResourceViewModel(ResourceRepository(api)),
        ),
        ChangeNotifierProvider(
          create: (_) => AuditViewModel(AuditRepository(api)),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel(DashboardRepository(api)),
        ),
      ],
      child: const FinControlApp(),
    ),
  );
}
