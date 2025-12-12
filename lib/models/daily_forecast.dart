class DailyForecast {
  final double minTemp;
  final double maxTemp;
  final String iconCode;
  final int timestamp;

  DailyForecast({
    required this.minTemp,
    required this.maxTemp,
    required this.iconCode,
    required this.timestamp,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    final temp = json['temp'];
    double min = 0;
    double max = 0;
    if (temp is Map) {
      min = ((temp['min'] ?? 0) as num).toDouble();
      max = ((temp['max'] ?? 0) as num).toDouble();
    }
    final icon = (json['weather'] is List && (json['weather'] as List).isNotEmpty)
        ? (json['weather'][0]['icon'] ?? '') as String
        : '';

    return DailyForecast(
      minTemp: min,
      maxTemp: max,
      iconCode: icon,
      timestamp: (json['dt'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temp': {'min': minTemp, 'max': maxTemp},
      'weather': [
        {'icon': iconCode}
      ],
      'dt': timestamp,
    };
  }
}
