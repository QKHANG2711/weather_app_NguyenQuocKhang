import 'hourly_forecast.dart';
import 'daily_forecast.dart';

class Weather {
  final String cityName;

  final double temperature;
  final String description;
  final String iconCode;

  final double humidity;
  final double windSpeed;
  final double pressure;

  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.hourly,
    required this.daily,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    // Determine city name robustly:
    // 1) prefer top-level 'name' (from /weather)
    // 2) then try nested 'city.name' (from /forecast)
    // 3) then fallback to 'timezone' (may be string like "Asia/..." or int offset) -> convert to string
    String resolvedName = '';

    if (json.containsKey('name') && json['name'] != null) {
      // /weather returns "name" as String
      final n = json['name'];
      if (n is String) {
        resolvedName = n;
      } else {
        resolvedName = n.toString();
      }
    } else if (json.containsKey('city') && json['city'] is Map) {
      final city = Map<String, dynamic>.from(json['city']);
      final cn = city['name'];
      if (cn is String) {
        resolvedName = cn;
      } else if (cn != null) {
        resolvedName = cn.toString();
      }
    } else if (json.containsKey('timezone') && json['timezone'] != null) {
      // timezone might be string or int (seconds offset). Convert to string to avoid type errors.
      resolvedName = json['timezone'].toString();
    } else {
      resolvedName = '';
    }

    // Support both OneCall-style ("current") and combined /weather fallback
    if (json.containsKey('current')) {
      final current = json['current'] ?? {};
      final weatherList = (current['weather'] is List) ? current['weather'] as List : [];
      final icon = (weatherList.isNotEmpty && weatherList[0] is Map) ? (weatherList[0]['icon'] ?? '') : '';
      final desc = (weatherList.isNotEmpty && weatherList[0] is Map) ? (weatherList[0]['description'] ?? '') : '';

      final hourlyJson = (json['hourly'] is List) ? List<Map<String, dynamic>>.from(json['hourly']) : <Map<String, dynamic>>[];
      final dailyJson = (json['daily'] is List) ? List<Map<String, dynamic>>.from(json['daily']) : <Map<String, dynamic>>[];

      return Weather(
        cityName: resolvedName,
        temperature: ((current['temp'] ?? 0) as num).toDouble(),
        description: desc is String ? desc : desc.toString(),
        iconCode: icon is String ? icon : icon.toString(),
        humidity: ((current['humidity'] ?? 0) as num).toDouble(),
        windSpeed: ((current['wind_speed'] ?? 0) as num).toDouble(),
        pressure: ((current['pressure'] ?? 0) as num).toDouble(),
        hourly: hourlyJson.map((e) => HourlyForecast.fromJson(Map<String, dynamic>.from(e))).toList(),
        daily: dailyJson.map((e) => DailyForecast.fromJson(Map<String, dynamic>.from(e))).toList(),
      );
    } else {
      // fallback for /weather + forecast combined shape
      final main = (json['main'] is Map) ? Map<String, dynamic>.from(json['main']) : <String, dynamic>{};
      final wind = (json['wind'] is Map) ? Map<String, dynamic>.from(json['wind']) : <String, dynamic>{};
      final weatherList = (json['weather'] is List) ? json['weather'] as List : [];
      final icon = (weatherList.isNotEmpty && weatherList[0] is Map) ? (weatherList[0]['icon'] ?? '') : '';
      final desc = (weatherList.isNotEmpty && weatherList[0] is Map) ? (weatherList[0]['description'] ?? '') : '';

      // hourly/daily might be attached by WeatherService as List<Map<String,dynamic>>
      final hourlyJson = (json['hourly'] is List) ? List<Map<String, dynamic>>.from(json['hourly']) : <Map<String, dynamic>>[];
      final dailyJson = (json['daily'] is List) ? List<Map<String, dynamic>>.from(json['daily']) : <Map<String, dynamic>>[];

      return Weather(
        cityName: resolvedName,
        temperature: ((main['temp'] ?? 0) as num).toDouble(),
        description: desc is String ? desc : desc.toString(),
        iconCode: icon is String ? icon : icon.toString(),
        humidity: ((main['humidity'] ?? 0) as num).toDouble(),
        windSpeed: ((wind['speed'] ?? 0) as num).toDouble(),
        pressure: ((main['pressure'] ?? 0) as num).toDouble(),
        hourly: hourlyJson.map((e) => HourlyForecast.fromJson(Map<String, dynamic>.from(e))).toList(),
        daily: dailyJson.map((e) => DailyForecast.fromJson(Map<String, dynamic>.from(e))).toList(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "name": cityName,
      "main": {
        "temp": temperature,
        "humidity": humidity,
        "pressure": pressure,
      },
      "wind": {"speed": windSpeed},
      "weather": [
        {"description": description, "icon": iconCode}
      ],
      "hourly": hourly.map((e) => e.toJson()).toList(),
      "daily": daily.map((e) => e.toJson()).toList(),
    };
  }
}