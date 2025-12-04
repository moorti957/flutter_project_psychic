import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://psychics.mapps.site/api";

  // ---------------------------------------------
  // ⭐ Fetch All Psychics (Recommended)
  // ---------------------------------------------
  static Future<List<dynamic>> getPsychics() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/psychics"));

      if (response.statusCode == 200) {
        return jsonDecode(response.body)["data"] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ---------------------------------------------
  // ⭐ Fetch Unique Categories from Psychics
  // ---------------------------------------------
  static Future<List<String>> getCategories() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/psychics"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)["data"] ?? [];

        Set<String> unique = {};

        for (var psychic in data) {
          if (psychic["categories"] != null) {
            for (var c in psychic["categories"]) {
              unique.add(c["name"].toString());
            }
          }
        }

        return unique.toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }
}
