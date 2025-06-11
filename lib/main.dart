import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:greengrow_app/data/repositories/auth_repository.dart';
import 'package:greengrow_app/data/repositories/auth_repository_impl.dart';
import 'package:greengrow_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:greengrow_app/presentation/pages/auth/login_screen.dart';
import 'package:greengrow_app/presentation/pages/auth/register_screen.dart';
import 'package:greengrow_app/presentation/pages/dashboard/admin_dashboard_screen.dart';
import 'package:greengrow_app/presentation/pages/dashboard/farmer_dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<Dio>(
          create: (context) => Dio(),
        ),
        RepositoryProvider<FlutterSecureStorage>(
          create: (context) => const FlutterSecureStorage(),
        ),
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(
            dio: context.read<Dio>(),
            secureStorage: context.read<FlutterSecureStorage>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'GreenGrow',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4CAF50),
            ),
            useMaterial3: true,
          ),
          initialRoute: '/login',
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/admin-dashboard': (context) => const AdminDashboardScreen(),
            '/farmer-dashboard': (context) => const FarmerDashboardScreen(),
          },
        ),
      ),
    );
  }
}
