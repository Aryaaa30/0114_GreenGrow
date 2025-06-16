import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:greengrow_app/core/providers/auth_provider.dart';
import 'package:greengrow_app/core/providers/notification_provider.dart';
import 'package:greengrow_app/data/repositories/auth_repository.dart';
import 'package:greengrow_app/data/repositories/auth_repository_impl.dart';
import 'package:greengrow_app/data/repositories/location_repository.dart';
import 'package:greengrow_app/data/repositories/notification_repository.dart';
import 'package:greengrow_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:greengrow_app/presentation/blocs/location/location_bloc.dart';
import 'package:greengrow_app/presentation/pages/auth/login_screen.dart';
import 'package:greengrow_app/presentation/pages/auth/register_screen.dart';
import 'package:greengrow_app/presentation/pages/dashboard/admin_dashboard_screen.dart';
import 'package:greengrow_app/presentation/pages/dashboard/farmer_dashboard_screen.dart';
import 'package:greengrow_app/presentation/pages/map/greenhouse_map_screen.dart';
import 'package:greengrow_app/presentation/pages/activity/activity_history_screen.dart';
import 'package:greengrow_app/presentation/pages/activity/upload_activity_screen.dart';
import 'package:greengrow_app/presentation/pages/notification/notification_screen.dart';
import 'package:greengrow_app/welcome.dart'; // Import welcome page

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => NotificationProvider(
            NotificationRepository(
              Dio(),
              const FlutterSecureStorage(),
            ),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
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
        RepositoryProvider<LocationRepository>(
          create: (context) => LocationRepository(
            context.read<Dio>(),
            context.read<FlutterSecureStorage>(),
          ),
        ),
        RepositoryProvider<NotificationRepository>(
          create: (context) => NotificationRepository(
            context.read<Dio>(),
            context.read<FlutterSecureStorage>(),
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
          BlocProvider<LocationBloc>(
            create: (context) => LocationBloc(
              context.read<LocationRepository>(),
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
          initialRoute: '/welcome', // Change initial route to welcome page
          routes: {
            '/welcome': (context) => const WelcomePage(), // Add welcome route
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/admin-dashboard': (context) => const AdminDashboardScreen(),
            '/farmer-dashboard': (context) => const FarmerDashboardScreen(),
            '/greenhouse-map': (context) => const GreenhouseMapScreen(),
            '/activity-history': (context) => const ActivityHistoryScreen(
                  greenhouseId: 1, // Ganti dengan ID greenhouse yang sesuai
                ),
            '/upload-activity': (context) => const UploadActivityScreen(
                  greenhouseId: 1, // Ganti dengan ID greenhouse yang sesuai
                ),
            '/notifications': (context) => const NotificationScreen(),
          },
        ),
      ),
    );
  }
}
