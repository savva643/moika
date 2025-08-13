import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:moika/api/api_service.dart';

import 'home_screen.dart';
import 'main_screen.dart'; // Подключаем ApiService

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  bool _isRegisterMode = false;
  bool _isCodeMode = false;
  String? _authId;
  String? _authCode;
  Timer? _verificationTimer;
  int _remainingTime = 300; // 5 минут в секундах
  final ApiService apiService = ApiService();
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  void _toggleMode() {
    setState(() {
      _isRegisterMode = !_isRegisterMode;
    });
  }

  /// Отправка номера телефона
  void _sendPhone() async {
    String phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showSnackBar('Введите номер телефона');
      return;
    }

    var response = await ApiService.sendPhoneNumber(phone);
    if (response != null && response['code'] != null) {
      setState(() {
        _authCode = response['code'].toString();
        _authId = response['id'].toString();
        _isCodeMode = true;
        _startVerificationCheck();
      });
    } else {
      _showSnackBar('Ошибка при отправке номера');
    }
  }

  /// Отправка данных при регистрации
  void _register() async {
    String phone = _phoneController.text.trim();
    String name = _nameController.text.trim();
    String surname = _surnameController.text.trim();

    if (phone.isEmpty || name.isEmpty || surname.isEmpty) {
      _showSnackBar('Заполните все поля');
      return;
    }

    var response = await ApiService.registerUser(phone, name, surname);
    if (response != null && response['code'] != null) {
      setState(() {
        _authId = response['id'].toString();
        _authCode = response['code'].toString();
        _isCodeMode = true;
        _startVerificationCheck();
      });
    } else {
      _showSnackBar('Ошибка при отправке номера');
    }
  }

  /// Запуск таймера проверки верификации
  void _startVerificationCheck() {
    _verificationTimer?.cancel();
    _remainingTime = 300;

    _verificationTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      if (_remainingTime <= 0) {
        timer.cancel();
        _showSnackBar('Код истёк. Запросите новый.');
        setState(() {
          _isCodeMode = false;
        });
        return;
      }

      if (_authId != null) {
        var response = await ApiService.checkVerificationStatus(_authId!);
        if (response != null && response['verified'] == true) {
          timer.cancel();
          _showSnackBar('Вход выполнен!');
          // TODO: Перенаправление в приложение
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', response['token']);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );

        }
      }

      _remainingTime -= 5;
    });
  }

  /// Открытие Telegram-бота
  void _openTelegramBot() async {
    final botUrl = "https://t.me/mouika_bot"; // Замените на имя бота
    if (await canLaunch(botUrl)) {
      await launch(botUrl);
    } else {
      _showSnackBar('Не удалось открыть Telegram');
    }
  }

  /// Показ сообщений пользователю
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isCodeMode ? 'Подтверждение' : (_isRegisterMode ? 'Регистрация' : 'Вход'),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _isCodeMode ? _buildCodeInput() : _buildAuthForm(),
          ),
        ),
      ),
    );
  }

  /// Виджет формы входа / регистрации
  Widget _buildAuthForm() {
    return Column(
      key: ValueKey<bool>(_isRegisterMode),
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isRegisterMode) ...[
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Имя'),
          ),
          TextField(
            controller: _surnameController,
            decoration: InputDecoration(labelText: 'Фамилия'),
          ),
        ],
        TextField(
          controller: _phoneController,
          decoration: InputDecoration(labelText: 'Номер телефона'),
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: _isRegisterMode ? _register : _sendPhone,
          child: Text(_isRegisterMode ? 'Зарегистрироваться' : 'Войти'),
        ),
        SizedBox(height: 20),
        TextButton(
          onPressed: _toggleMode,
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: Text(_isRegisterMode ? 'Уже есть аккаунт? Войти' : 'Нет аккаунта? Зарегистрироваться'),
        ),
      ],
    );
  }

  /// Виджет для ввода кода
  Widget _buildCodeInput() {
    return Column(
      key: ValueKey<String>('codeInput'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Код',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          _authCode!,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Text(
          'Подтвердить через',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          onPressed: _openTelegramBot,
          child: Text('Подтвердить через Telegram'),
        ),
        SizedBox(height: 20),

        TextButton(
          onPressed: _sendPhone,
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: Text('Получить новый код'),
        ),
      ],
    );
  }
}
