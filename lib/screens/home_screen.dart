import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../services/location_service.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/hourly_forecast_list.dart';
import '../widgets/daily_forecast_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadByLocation();
  }

  Future<void> _loadByLocation() async {
    final provider = context.read<WeatherProvider>();
    try {
      final loc = await LocationService().getLocation();
      await provider.fetchWeatherByLocation(loc.latitude, loc.longitude);
    } catch (e) {
      // ignore location errors
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.refreshWeather(),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter a city name',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final text = searchController.text.trim();
                    provider.fetchWeatherByCity(text);
                  },
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildState(provider),
          )
        ],
      ),
    );
  }

  Widget _buildState(WeatherProvider provider) {
    switch (provider.state) {
      case WeatherState.loading:
        return const Center(child: CircularProgressIndicator());
      case WeatherState.error:
        return Center(child: Text(provider.errorMessage ?? 'Unknown error'));
      case WeatherState.loaded:
        final weather = provider.currentWeather!;
        final forecast = provider.forecast!;
        return ListView(
          children: [
            CurrentWeatherCard(weather: weather),
            const SizedBox(height: 20),
            HourlyForecastList(items: forecast.hourly),
            const SizedBox(height: 20),
            ...forecast.daily.map((d) => DailyForecastCard(item: d)),
          ],
        );
      default:
        return const Center(child: Text('Loading...'));
    }
  }
}
