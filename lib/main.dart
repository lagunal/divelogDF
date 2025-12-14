import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:divelogtest/screens/main_navigation_screen.dart';
import 'package:divelogtest/theme.dart';
import 'package:divelogtest/services/user_service.dart';
import 'package:divelogtest/providers/dive_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final userService = UserService();
  await userService.initialize();
  await userService.createDefaultUserIfNeeded();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DiveProvider(),
      child: MaterialApp(
        title: 'Registro de Buceo',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        home: const MainNavigationScreen(),
      ),
    );
  }
}
