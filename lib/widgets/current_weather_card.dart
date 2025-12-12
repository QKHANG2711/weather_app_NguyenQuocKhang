import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class CurrentWeatherCard extends StatelessWidget {
  final Weather weather;
  const CurrentWeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final service = WeatherService();
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(weather.cityName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Image.network(service.getIconUrl(weather.iconCode)),
            const SizedBox(height: 8),
            Text('${weather.temperature.toStringAsFixed(0)}°', style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            Text(weather.description),
          ],
        ),
      ),
    );
  }
}
