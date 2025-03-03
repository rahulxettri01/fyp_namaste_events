import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:fyp_namaste_events/model/user_registration_model.dart';
import 'package:http/http.dart' as http;

class Api {
  static const baseUrl = "http://192.168.1.90:2000/auth/";

  // POST Method - Add Venue
  static Future<void> signup(Map<String, dynamic> udata) async {
    var url = Uri.parse("${baseUrl}sign_up");
    print("Request URL: $url");

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(udata),
      );

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print("User registered successfully: $data");
      } else {
        print("User registration failed: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("Error: ${e.toString()}");
    }
  }
}
