import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/weather_model.dart';

class WeatherService {
  /// Fetch weather by CITY NAME (FREE API)
  Future<Weather> getWeather(String city) async {
    final current = await _getCurrentWeather(city);
    final forecast = await _getForecast(city);

    final combined = <String, dynamic>{
      ...Map<String, dynamic>.from(current),
      "hourly": _convertForecastToHourlyList(forecast),
      "daily": _convertForecastToDailyList(forecast),
    };

    return Weather.fromJson(combined);
  }

  /// Fetch weather by COORDINATES (FREE API)
  Future<Weather> getWeatherByLatLon(double lat, double lon) async {
    final currentUrl = Uri.parse(
      "${ApiConfig.baseUrl}/weather?lat=$lat&lon=$lon&appid=${ApiConfig.apiKey}&units=metric",
    );

    final forecastUrl = Uri.parse(
      "${ApiConfig.baseUrl}/forecast?lat=$lat&lon=$lon&appid=${ApiConfig.apiKey}&units=metric",
    );

    final currentRes = await http.get(currentUrl);
    final forecastRes = await http.get(forecastUrl);

    if (currentRes.statusCode != 200) {
      throw Exception("Failed current weather: ${currentRes.body}");
    }
    if (forecastRes.statusCode != 200) {
      throw Exception("Failed forecast: ${forecastRes.body}");
    }

    final currentJson =
    Map<String, dynamic>.from(jsonDecode(currentRes.body));
    final forecastJson =
    Map<String, dynamic>.from(jsonDecode(forecastRes.body));

    final combined = <String, dynamic>{
      ...currentJson,
      "hourly": _convertForecastToHourlyList(forecastJson),
      "daily": _convertForecastToDailyList(forecastJson),
    };

    return Weather.fromJson(combined);
  }

  /// INTERNAL – Get current weather by city
  Future<Map<String, dynamic>> _getCurrentWeather(String city) async {
    final url = Uri.parse(
      "${ApiConfig.baseUrl}/weather?q=${Uri.encodeComponent(city)}&appid=${ApiConfig.apiKey}&units=metric",
    );

    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception("Failed to load current weather: ${res.body}");
    }

    return Map<String, dynamic>.from(jsonDecode(res.body));
  }

  /// INTERNAL – 5-day forecast (3h intervals)
  Future<Map<String, dynamic>> _getForecast(String city) async {
    final url = Uri.parse(
      "${ApiConfig.baseUrl}/forecast?q=${Uri.encodeComponent(city)}&appid=${ApiConfig.apiKey}&units=metric",
    );

    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception("Failed to load forecast: ${res.body}");
    }

    return Map<String, dynamic>.from(jsonDecode(res.body));
  }

  /// Convert forecast → hourly list
  List<Map<String, dynamic>> _convertForecastToHourlyList(
      Map<String, dynamic> forecast) {
    final List rawList = forecast["list"] ?? [];

    return rawList.take(24).map((item) {
      if (item is Map<String, dynamic>) {
        return item;
      }
      return Map<String, dynamic>.from(item);
    }).toList();
  }

  /// Convert forecast → daily summary (min/max + icon)
  List<Map<String, dynamic>> _convertForecastToDailyList(
      Map<String, dynamic> forecast) {
    final List rawList = forecast["list"] ?? [];
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var e in rawList) {
      final entry = (e is Map<String, dynamic>)
          ? e
          : Map<String, dynamic>.from(e);

      final dt = DateTime.fromMillisecondsSinceEpoch(entry["dt"] * 1000);
      final key = "${dt.year}-${dt.month}-${dt.day}";

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(entry);
    }

    return grouped.values.map((entries) {
      final temps =
      entries.map((e) => (e["main"]["temp"] as num).toDouble()).toList();

      final minT = temps.reduce((a, b) => a < b ? a : b);
      final maxT = temps.reduce((a, b) => a > b ? a : b);

      final first = entries.first;

      return {
        "temp": {"min": minT, "max": maxT},
        "weather": first["weather"],
        "dt": first["dt"],
      };
    }).toList();
  }

  /// Icon URL builder
  String getIconUrl(String icon) {
    return "https://openweathermap.org/img/wn/$icon@2x.png";
  }
}
