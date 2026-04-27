import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:samiti_app/features/auth/repository/auth_repository.dart';
import 'package:samiti_app/features/auth/view_model/auth_view_model.dart';


import 'core/constants/app_colors.dart';
import 'core/di/service_locator.dart';
import 'features/auth/view/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize GetIt
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository=sl<AuthRepository>();
    return MultiProvider(
      providers:[
        ChangeNotifierProvider(
            create: (_)=>AuthViewModel(repository: authRepository)
        )
      ],
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.background),
        ),
        home: const LoginScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
