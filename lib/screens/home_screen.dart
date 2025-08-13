import 'package:flutter/material.dart';
import '../modules/dictory.dart';
import 'booking_screen.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, String>> bookings = [
    {"car": "Toyota Corolla", "date": "2025-02-17", "color": "blue", "plate": "А123ВВ 77"},
    {"car": "Honda Civic", "date": "2025-02-20", "color": "red", "plate": "М456КС 99"},
    {"car": "BMW X5", "date": "2025-02-25", "color": "black", "plate": "Т789ОР 78"},
  ];



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: CustomButton(
              text: "Записаться на мойку",
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BookingScreen()),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Текущие записи:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Expanded(
            child: bookings.isNotEmpty
                ? ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                return BookingCard(
                  car: bookings[index]['car']!,
                  date: bookings[index]['date']!,
                  color: bookings[index]['color'],
                  plate: bookings[index]['plate'],
                  logo: carLogos[bookings[index]['car']!.split(" ")[0]],
                );
              },
            )
                : Center(child: Text("Нет активных записей")),
          ),
        ],
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  CustomButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text, style: TextStyle(color: Colors.white, fontSize: 16)),
    );
  }
}

class BookingCard extends StatelessWidget {
  final String car;
  final String date;
  final String? color;
  final String? plate;
  final String? logo;

  BookingCard({required this.car, required this.date, this.color, this.plate, this.logo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Машина: $car', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('Дата: $date', style: TextStyle(fontSize: 16)),
            ],),
            Expanded(child: Container()),
            if (plate != null) PlateWidget(plate: plate!),
          ],),

          Row(children: [
            if (logo != null)
              Image.network(logo!, width: 60, height: 60, errorBuilder: (context, error, stackTrace) {
                return Container();
              }),
            if (color != null)
              Icon(Icons.directions_car, size: 60, color: getColor(color!),)
          ],),


        ],
      ),
    );
  }

  Color getColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'gray':
        return Colors.grey;
      default:
        return Colors.transparent;
    }
  }
}



class PlateWidget extends StatelessWidget {
  final String plate;

  PlateWidget({required this.plate});

  @override
  Widget build(BuildContext context) {
    List<String> parts = plate.split(" ");
    if (parts.length < 2 || parts[0].length < 6) return Text(plate); // Фолбэк

    String letterStart = parts[0].substring(0, 1);
    String numbers = parts[0].substring(1, 4);
    String letterEnd = parts[0].substring(4);
    String region = parts[1];

    return Container(
      width: 210,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          // Номерной знак (до полоски)
          Positioned(
            left: 6,
            top: 0,
            bottom: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(letterStart, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                Text(numbers, style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
                Text(letterEnd, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // Полоска разделитель (на 3/4 ширины)
          Positioned(
            left: 140, // Смещение полоски ближе к правому краю (3/4)
            top: 0,
            bottom: 0,
            child: Container(
              width: 3,
              height: 46,
              color: Colors.black,
            ),
          ),

          // Регион и флаг (справа)
          Positioned(
            right: 3,
            top: 2,
            bottom: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: 1.8, // Увеличенный размер региона
                  child: Text(region, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 2), // Отступ вниз
                Row(
                  children: [
                    Text("RUS", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Container(
                      width: 25,
                      height: 14,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 0.8),
                      ),
                      child: Column(
                        children: [
                          Container(height: 4, color: Colors.white),
                          Container(height: 4, color: Colors.blue),
                          Container(height: 4.4, color: Colors.red),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

  }
}

