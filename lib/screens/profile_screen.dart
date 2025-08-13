import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:moika/screens/auth_screen.dart';
import 'package:moika/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../api/api_service.dart';
import '../parts/buttons.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "Загрузка...";
  String phone = "";
  String? imgUrl;

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }
  final ApiService apiService = ApiService();

  void loadUserProfile() async {
    var profile = await apiService.fetchUserProfile();

    if (profile != null) {
      setState(() {
        name = profile["name"];
        phone = profile["phone"];
        imgUrl = profile["img"];
      });
    } else {
      print("Не удалось загрузить профиль");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: imgUrl != null && imgUrl!.isNotEmpty
                    ? NetworkImage(imgUrl!) as ImageProvider
                    : const AssetImage('assets/default_avatar.png'),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(phone, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          CustomButton(
            title: "Мои машины",
            subtitle: "Добавьте или удалите автомобили",
            icon: Icons.directions_car,
            onPressed: () {
              // TODO: Навигация к экрану "Мои машины"
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
          const SizedBox(height: 12),
          CustomButton(
            title: "Настройки",
            subtitle: "Персонализация и безопасность",
            icon: Icons.settings,
            onPressed: () {
              // TODO: Навигация к экрану "Настройки"
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
          const Spacer(),
          CustomButton(
            title: "Выйти",
            subtitle: "Завершение сеанса",
            icon: Icons.exit_to_app,
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove("token"); // Очистка токена
              // TODO: Перенаправить на экран входа
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AuthScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
