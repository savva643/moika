import 'package:flutter/material.dart';
import 'package:moika/screens/auth_screen.dart';
import 'package:moika/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'modules/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ThemeMode savedTheme = await ThemeProvider.getSavedTheme();
  runApp(MyApp(savedTheme: savedTheme));
}

class MyApp extends StatelessWidget {
  final ThemeMode savedTheme;

  const MyApp({super.key, required this.savedTheme});

  Future<bool> _checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(initialTheme: savedTheme),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Мойка',
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: FutureBuilder<bool>(
              future: _checkToken(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return snapshot.data == true ? MainScreen() : AuthScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
