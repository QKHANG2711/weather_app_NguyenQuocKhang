import 'package:flutter/material.dart';
import '../models/hourly_forecast.dart';
import '../services/weather_service.dart';

class HourlyForecastList extends StatelessWidget {
  final List<HourlyForecast> items;

  const HourlyForecastList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final service = WeatherService();

    return SizedBox(
      height: 150, // FIX overflow
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, i) {
          final f = items[i];
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${DateTime.fromMillisecondsSinceEpoch(f.timestamp * 1000).hour}:00",
                  style: TextStyle(fontSize: 12),
                ),

                // FIX: small icon
                Image.network(
                  service.getIconUrl(f.iconCode),
                  width: 40,
                  height: 40,
                ),

                SizedBox(height: 4),

                Text(
                  "${f.temp.toStringAsFixed(0)}°",
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
