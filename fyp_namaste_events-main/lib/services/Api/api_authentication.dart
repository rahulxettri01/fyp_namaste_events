import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:fyp_namaste_events/utils/costants/api_constants.dart';

class Api {



  // Function to sign up a user
  static Future<Map<String, dynamic>> signup(Map<String, dynamic> udata) async {
    var url = Uri.parse("${APIConstants.baseUrl}/sign_up");
    debugPrint("Request URL: $url");

    try {
      final response = await http.post(
        url,
        headers:<String, String>
        {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode(udata),
      );

      if (response.statusCode == 200 || response.statusCode == 400) {
        // Success: return response JSON

        return jsonDecode(response.body);
      } else {
        // Error response: return JSON with error message

        return {"message": "Server error: ${response.statusCode}"};

      }
    } catch (e) {
      debugPrint("Error: ${e.toString()}");
      return {
        "success": false,
        "message": "Something went wrong. Please try again later."
      };
    }
  }

  static Future<Map<String, dynamic>> login(Map<String, dynamic> udata) async {
    var url = Uri.parse("${APIConstants.baseUrl}/log_in");
    debugPrint("Request URL: $url");

    try {

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(udata),
      );

      if (response.statusCode == 200 || response.statusCode == 400) {
        // Success: return response JSON
        return jsonDecode(response.body);
      } else {
        // Error response: return JSON with error message

        return {"message": "Server error: ${response.statusCode}"};

      }
    } catch (e) {
      debugPrint("Error: ${e.toString()}");
      return {
        "success": false,
        "message": "Something went wrong. Please try again later."
      };
    }
  }
}
