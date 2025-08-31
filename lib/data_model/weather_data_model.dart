import 'dart:convert';

import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> fetchWeather(String city) async {
  final apiKey = "228b0f4b038a5d39bb7ad29c5a22948f";
  final url =
      "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric";

  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception("Failed to load weather data");
  }
}
