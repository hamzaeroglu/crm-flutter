import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'firebase_options.dart';
import 'core/services/customer_firestore_service.dart';
import 'data/repo/customer_repository.dart';
import 'presentation/providers/customer_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/user_management_provider.dart';
import 'presentation/providers/audit_provider.dart';
import 'presentation/pages/customer_page.dart';
import 'presentation/pages/login_page.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, CustomerProvider>(
          create: (_) => CustomerProvider(
            CustomerRepositoryImpl(CustomerFirestoreService()),
          ),
          update: (_, authProvider, previous) {
            final provider = previous ?? CustomerProvider(
              CustomerRepositoryImpl(CustomerFirestoreService()),
            );
            if (authProvider.isAuthenticated && previous == null) {
              provider.fetchCustomers();
            }
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserManagementProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuditProvider(),
        ),
      ],
      child: Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, ThemeProvider themeProvider, AuthProvider authProvider, _) {
          return MaterialApp(
            title: 'CRM',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            themeMode: ThemeMode.light, // Tasarım oturana kadar açık mod zorunlu
            routes: {
              '/login': (_) => const LoginPage(),
              '/home': (_) => const CustomerPage(),
            },
            home: authProvider.isAuthenticated && authProvider.isEmailVerified
                ? const CustomerPage()
                : const LoginPage(),
          );
        },
      ),
    );
  }
}
