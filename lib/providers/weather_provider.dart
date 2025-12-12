import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

enum WeatherState { initial, loading, loaded, error }

class WeatherProvider extends ChangeNotifier {
  final WeatherService _service = WeatherService();

  Weather? _currentWeather;
  Weather? _forecast;
  WeatherState _state = WeatherState.initial;
  String? _errorMessage;

  Weather? get currentWeather => _currentWeather;
  Weather? get forecast => _forecast;
  WeatherState get state => _state;
  String? get errorMessage => _errorMessage;

  /// Fetch weather by city name
  Future<void> fetchWeatherByCity(String city) async {
    _state = WeatherState.loading;
    notifyListeners();

    try {
      final result = await _service.getWeather(city);
      _currentWeather = result;
      _forecast = result;
      _state = WeatherState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = WeatherState.error;
    }

    notifyListeners();
  }

  /// Fetch weather using coordinates (FREE API)
  Future<void> fetchWeatherByLocation(double lat, double lon) async {
    _state = WeatherState.loading;
    notifyListeners();

    try {
      final result = await _service.getWeatherByLatLon(lat, lon);
      _currentWeather = result;
      _forecast = result;
      _state = WeatherState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = WeatherState.error;
    }

    notifyListeners();
  }

  /// Refresh weather using last searched city
  Future<void> refreshWeather() async {
    if (_currentWeather == null) return;
    await fetchWeatherByCity(_currentWeather!.cityName);
  }
}
