import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../modules/theme_provider.dart';
import '../parts/buttons.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkTheme = false;
  bool notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkTheme = prefs.getBool('isDarkMode') ?? false;
      notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });
  }



  void _toggleTheme(bool value) {
    setState(() {
      Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
    });
  }

  void _toggleNotifications(bool value) {
    setState(() {
      notificationsEnabled = value;
    });
  }

  void _openAboutPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AboutPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Настройки', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomSwitch(
              title: 'Тёмная тема',
              subtitle: 'Изменяет цветовую схему приложения',
              value: isDarkTheme,
              onChanged: _toggleTheme,
            ),
            SizedBox(height: 16),
            CustomSwitch(
              title: 'Уведомления',
              subtitle: 'Включает или отключает уведомления',
              value: notificationsEnabled,
              onChanged: _toggleNotifications,
            ),
            SizedBox(height: 16),
            CustomButton(
              title: 'О приложении',
              subtitle: 'Информация о версии и разработчике',
              icon: Icons.info_outline,
              onPressed: _openAboutPage,
            ),
          ],
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('О приложении', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.local_car_wash, size: 80, color: Colors.red),
              SizedBox(height: 20),
              Text("Запись на мойку", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text("Версия: 1.0.0", style: TextStyle(fontSize: 16, color: Colors.grey)),
              SizedBox(height: 10),
              Text("Разработчик: [ТВОЁ ИМЯ]", style: TextStyle(fontSize: 16)),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Закрыть', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


