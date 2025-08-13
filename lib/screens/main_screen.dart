import 'package:flutter/material.dart';
import 'package:moika/screens/profile_screen.dart';

import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final int userLevel = 1; // Уровень пользователя (например, 2 для мойщика)

  final List<Widget> _screens = [
    HomeScreen(),
    ScheduleScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    if (userLevel >= 2) {
      _screens.add(AdminScreen()); // Добавляем вкладку "Админ" для уровня 2+
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Мойка",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
          if (userLevel >= 2)
            BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Админ'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Расписание'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),

        ],
      ),
    );
  }
}

// Экран Главная


// Экран Расписание
class ScheduleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Расписание (данные с сервера)'));
  }
}



// Экран Админ (доступен только для уровня 2+)
class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton(onPressed: () {}, child: Text('Запись')),
          ElevatedButton(onPressed: () {}, child: Text('Бухгалтерия')),
          ElevatedButton(onPressed: () {}, child: Text('Админ панель')),
        ],
      ),
    );
  }
}