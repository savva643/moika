import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const String _baseUrl = 'https://moika.keeppixel.store/api.php';

  /// Отправка номера телефона и получение `id` из `auth_codes`
  static Future<Map<String, dynamic>?> sendPhoneNumber(String phone) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'action': 'send_code', 'phone': phone}),
      );

      if (response.statusCode == 200) {
        print(response.body);
        return json.decode(response.body);
      }
    } catch (e) {
      print("Ошибка при отправке номера: $e");
    }
    return null;
  }

  /// Проверка статуса верификации по `id`
  static Future<Map<String, dynamic>?> checkVerificationStatus(String id) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'action': 'check_verification', 'id': id}),
      );

      if (response.statusCode == 200) {
        print(response.body);
        return json.decode(response.body);
      }
    } catch (e) {
      print("Ошибка при проверке верификации: $e");
    }
    return null;
  }

  /// Регистрация пользователя после верификации
  static Future<Map<String, dynamic>?> registerUser(String phone, String name, String surname) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'action': 'register', 'phone': phone, 'name': name, 'surname': surname}),
      );

      if (response.statusCode == 200) {
        print(response.body);
        return json.decode(response.body);
      }
    } catch (e) {
      print("Ошибка при регистрации: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchAvailableDates() async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'action': 'get_available_dates'}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print("Ошибка при получении доступных дат: $e");
    }
    return null;
  }

  /// Получение доступного времени для выбранной даты
  Future<List<String>?> fetchAvailableTimes(String date) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'action': 'get_available_times', 'date': date}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['available_times']);
      }
    } catch (e) {
      print("Ошибка при получении времени: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> setSchedule(
      String date, String openTime, String closeTime, bool closed, List<String> exceptions) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'action': 'set_schedule',
          'date': date,
          'open_time': openTime,
          'close_time': closeTime,
          'closed': closed ? 1 : 0,
          'exceptions': exceptions, // Отправляем исключения
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print("Ошибка при добавлении расписания: $e");
    }
    return null;
  }

  Future<List<Map<String, dynamic>>?> fetchServices() async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'action': 'get_services'}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['services']);
      }
    } catch (e) {
      print("Ошибка при получении сервисов: $e");
    }
    return null;
  }

  Future<List<Map<String, dynamic>>?> fetchServicesByVehicleType(String vehicleType) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"action": "get_services_by_vehicle", "vehicle_type": vehicleType}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey("services")) {
          return List<Map<String, dynamic>>.from(responseData["services"]);
        }
      }
    } catch (e) {
      print("Ошибка при получении услуг: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");
      print(token);
      if (token == null || token.isEmpty) {
        print("Токен отсутствует");
        return null;
      }

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"action": "get_profile", "token": token}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey("profile")) {
          print("token"+responseData.toString());
          return responseData["profile"];
        } else if (responseData.containsKey("error")) {
          print("Ошибка: ${responseData["error"]}");
        }
      }
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");
      print(token);
      print("Ошибка при получении профиля: $e");
    }
    return null;
  }



}
