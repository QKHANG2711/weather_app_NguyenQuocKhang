import 'package:flutter/material.dart';
import '../models/daily_forecast.dart';
import '../services/weather_service.dart';

class DailyForecastCard extends StatelessWidget {
  final DailyForecast item;

  const DailyForecastCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final service = WeatherService();
    final date = DateTime.fromMillisecondsSinceEpoch(item.timestamp * 1000);
    return Card(
      child: ListTile(
        leading: Image.network(service.getIconUrl(item.iconCode)),
        title: Text('${date.day}/${date.month}/${date.year}'),
        subtitle: Text('Min: ${item.minTemp.toStringAsFixed(0)}°  •  Max: ${item.maxTemp.toStringAsFixed(0)}°'),
      ),
    );
  }
}
