import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../api/api_service.dart';

class BookingScreen extends StatefulWidget {
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final ApiService apiService = ApiService();
  final TextEditingController carModelController = TextEditingController();
  final TextEditingController carNumberController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  String? selectedTime;
  String? selectedService;
  String? selectedVehicleType;
  bool rememberCar = false;

  List<String> availableTimes = [];
  List<Map<String, dynamic>> availableServices = [];
  List<String> vehicleTypes = ['A', 'B', 'C', 'D', 'E', 'F', 'кроссовер', 'минивэн', 'внедорожник'];

  @override
  void initState() {
    super.initState();
    _fetchAvailableTimes();
  }

  void _fetchAvailableTimes() async {
    final times = await apiService.fetchAvailableTimes(selectedDate.toString().split(' ')[0]);
    if (times != null) {
      setState(() {
        availableTimes = times;
      });
    }
  }

  void _fetchServices() async {
    if (selectedVehicleType != null) {
      final services = await apiService.fetchServicesByVehicleType(selectedVehicleType!);
      if (services != null) {
        setState(() {
          availableServices = services;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Запись на мойку', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: carModelController,
                decoration: InputDecoration(labelText: 'Марка и модель машины'),
              ),
              TextField(
                controller: carNumberController,
                decoration: InputDecoration(labelText: 'Номер машины'),
              ),
              SizedBox(height: 20),

              // Выбор типа ТС
              Text("Выберите тип транспортного средства:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: selectedVehicleType,
                isExpanded: true,
                hint: Text("Выберите тип ТС"),
                items: vehicleTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedVehicleType = value;
                    _fetchServices();
                  });
                },
              ),

              SizedBox(height: 20),

              // Выбор услуги
              Text("Выберите услугу:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: selectedService,
                isExpanded: true,
                hint: Text("Выберите услугу"),
                items: availableServices.map((service) {
                  return DropdownMenuItem<String>(
                    value: service['name'],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(service['name'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(service['description'], style: TextStyle(fontSize: 14, color: Colors.grey)),
                        Text("Длительность: ${service['duration']} мин", style: TextStyle(fontSize: 14)),
                        Text("Цена: ${service['price']} руб", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedService = value;
                  });
                },
              ),

              SizedBox(height: 20),

              // Выбор даты
              Text("Выберите дату:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TableCalendar(
                focusedDay: selectedDate,
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(Duration(days: 30)),
                selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    selectedDate = selectedDay;
                    selectedTime = null;
                    _fetchAvailableTimes();
                  });
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(color: Colors.red.withOpacity(0.5), shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  todayTextStyle: TextStyle(color: Colors.white),
                  selectedTextStyle: TextStyle(color: Colors.white),
                ),
              ),

              SizedBox(height: 20),

              // Выбор времени
              Text("Выберите время:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableTimes.map((time) {
                  return ChoiceChip(
                    label: Text(
                      time,
                      style: TextStyle(color: selectedTime == time ? Colors.white : Colors.black),
                    ),
                    selected: selectedTime == time,
                    selectedColor: Colors.red,
                    backgroundColor: Colors.grey[200],
                    checkmarkColor: Colors.white,
                    onSelected: (selected) {
                      setState(() {
                        selectedTime = selected ? time : null;
                      });
                    },
                  );
                }).toList(),
              ),

              SizedBox(height: 20),

              // Кнопка записи
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedTime == null || selectedService == null || selectedVehicleType == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Заполните все поля!"))
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Записаться', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
