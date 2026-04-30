import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:samiti_app/core/api/app_providers.dart';
import 'package:samiti_app/core/router/app_router.dart';
import 'package:samiti_app/core/utils/token_storage.dart';
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
  String _token = '';

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async{
    final token= await TokenStorage.getAccessToken();
    setState(() {
      _token=token ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final authRepository=sl<AuthRepository>();
    return MultiProvider(
      providers:[
        ChangeNotifierProvider(
            create: (_)=>AuthViewModel(repository: authRepository)
        )
      ],
      child: AppProviders(
        token: _token,
        child: MaterialApp.router(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.background),
          ),
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
