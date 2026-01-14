import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.provider.dart';
import 'screens/login_page.dart';
import 'utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const CabinCheckApp(),
    ),
  );
}

class CabinCheckApp extends StatelessWidget {
  const CabinCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    return MaterialApp(
      title: 'CabinCheck',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: state.themeMode,
      home: const LoginPage(),
    );
  }
}
