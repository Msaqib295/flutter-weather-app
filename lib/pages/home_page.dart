import 'package:flutter/material.dart';
import 'package:weather_app/data_model/weather_data_model.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String city = '';
  String weatherDes = '';
  String temperature = '';
  String feelsLike = '';
  String humidity = '';
  String windSpeed = '';
  String icon = '';
  String sunrise = '';
  String sunset = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Fetch location & weather automatically
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check for permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Convert lat/lon → city name
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      setState(() {
        city = placemarks.first.locality ?? '';
      });
      getWeather(); // Fetch weather for detected city
    }
  }

  void getWeather() async {
    try {
      final weatherData = await fetchWeather(city);
      setState(() {
        weatherDes = weatherData['weather'][0]['description'];
        icon = weatherData['weather'][0]['icon'];
        temperature = weatherData['main']['temp'].round().toString();
        feelsLike = weatherData['main']['feels_like'].round().toString();
        humidity = weatherData['main']['humidity'].toString();
        windSpeed = weatherData['wind']['speed'].toString();

        int sunriseTs = weatherData['sys']['sunrise'];
        int sunsetTs = weatherData['sys']['sunset'];

        DateTime sunriseTime = DateTime.fromMillisecondsSinceEpoch(
          sunriseTs * 1000,
        );
        DateTime sunsetTime = DateTime.fromMillisecondsSinceEpoch(
          sunsetTs * 1000,
        );

        sunrise = DateFormat('hh:mm a').format(sunriseTime);
        sunset = DateFormat('hh:mm a').format(sunsetTime);
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo[500],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade300, Colors.blue.shade900],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: TextField(
                onChanged: (value) {
                  city = value;
                },
                onSubmitted: (value) {
                  city = value;
                  getWeather();
                  FocusScope.of(context).unfocus();
                },
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Enter City Name',
                  hintStyle: const TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),
            city.isEmpty
                ? const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  )
                : Text(
                    city,
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
            const SizedBox(height: 10),
            if (temperature.isNotEmpty) ...[
              Image.network(
                "https://openweathermap.org/img/wn/$icon@2x.png",
                height: 100,
                width: 100,
              ),
              const SizedBox(height: 10),
              Text(
                weatherDes,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                '$temperature°C',
                style: const TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Feels Like: $feelsLike°C',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                'Humidity: $humidity%',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                'Wind Speed: $windSpeed km/h',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                'Sunrise: $sunrise',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                'Sunset: $sunset',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
