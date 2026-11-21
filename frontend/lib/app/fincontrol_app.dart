import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/view_models/auth_view_model.dart';
import '../features/auth/views/login_view.dart';
import 'home_shell.dart';

class FinControlApp extends StatelessWidget {
  const FinControlApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'FinControl',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: Consumer<AuthViewModel>(
      builder: (_, auth, __) =>
          auth.authenticated ? const HomeShell() : const LoginView(),
    ),
  );
}
