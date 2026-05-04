import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:samiti_app/core/api/app_providers.dart';
import 'package:samiti_app/core/router/app_router.dart';
import 'package:samiti_app/features/auth/repository/auth_repository.dart';
import 'package:samiti_app/features/auth/view_model/auth_view_model.dart';


import 'core/constants/app_colors.dart';
import 'core/di/service_locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize GetIt
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthViewModel _authViewModel;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authViewModel = AuthViewModel(repository: sl<AuthRepository>());
    _router = AppRouter.createRouter(_authViewModel);
  }


  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers:[
        ChangeNotifierProvider.value(value: _authViewModel),
      ],
      child: AppProviders(
        child: MaterialApp.router(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.background),
          ),
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
