import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:samiti_app/core/resusable_widgets/custom_appbar.dart';
import 'package:samiti_app/core/resusable_widgets/custom_text_field.dart';
import 'package:samiti_app/core/resusable_widgets/wide_elevated_button.dart';

import '../../../core/constants/app_colors.dart';
import '../view_model/auth_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();

  late final viewModel = context.read<AuthViewModel>();

  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    // Clear previous state
    setState(() {
      _loading = true;
      _error = null;
    });

    // Call login - returns bool (true/false)
    final success = await viewModel.login(
        login: _loginController.text.trim(),
        password: _passwordController.text.trim()
    );

    // Stop loading
    setState(() => _loading = false);

    if (success && mounted) {
      final token = viewModel.auth?.accessToken;

      if (token != null && token.isNotEmpty) {
        context.goNamed('dashboard');
      } } else if(mounted){
      setState(() => _error = viewModel.error ?? 'Invalid credentials.');
    }
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Login'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(
              controller: _loginController,
              label:'Username',
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _passwordController,
              label:'Password',
              isPassword: true,
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: TextStyle(color: AppColors.error)),
            ],
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : WideElevatedButton(
              onPressed: _login,
              text: 'Login',
            ),
          ],
        ),
      ),
    );
  }
}