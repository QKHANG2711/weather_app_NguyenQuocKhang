class HourlyForecast {
  final double temp;
  final String iconCode;
  final int timestamp;

  HourlyForecast({
    required this.temp,
    required this.iconCode,
    required this.timestamp,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      temp: ((json['temp'] ?? 0) as num).toDouble(),
      iconCode: (json['weather'] is List && (json['weather'] as List).isNotEmpty)
        ? (json['weather'][0]['icon'] ?? '') as String
        : '',
      timestamp: (json['dt'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temp': temp,
      'iconCode': iconCode,
      'timestamp': timestamp,
    };
  }
}
