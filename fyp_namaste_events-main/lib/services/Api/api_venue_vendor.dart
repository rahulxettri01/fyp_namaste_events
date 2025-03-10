import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:fyp_namaste_events/model/vendor_venue_model.dart';
import 'package:http/http.dart' as http;

class Api {
  static const  String baseUrl = "http://192.168.1.72:2000/api/";

  // POST Method - Add Venue
  static Future<void> addVenue(Map<String, dynamic> vdata) async {
    var url = Uri.parse("${baseUrl}add_venue");
    print("Request URL: $url");

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(vdata),
      );

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print("Venue added successfully: $data");
      } else {
        print("Failed to add venue: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("Error: ${e.toString()}");
    }
  }

  // GET Method - Fetch Venues
  static Future<List<venue>> getVenue() async {
    List<venue> venues = [];
    var url = Uri.parse("${baseUrl}get_venue");

    try {
      final res = await http.get(url);

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        for (var value in data['venues']) {
          venues.add(
            venue(
              venue_name: value['venue_name'],
              venue_price: value['venue_price'],
              venue_rating: value['venue_rating'],
              id: value['id'].toString(),
            ),
          );
        }
        return venues;
      } else {
        print("Failed to fetch venues: ${res.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error fetching venues: ${e.toString()}");
      return [];
    }
  }

  // PUT Method - Update Venue
  static Future<void> updateVenue(String id, Map<String, dynamic> body) async {
    var url = Uri.parse("${baseUrl}update/$id");

    try {
      final res = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        print("Venue updated successfully: ${jsonDecode(res.body)}");
      } else {
        print("Failed to update venue: ${res.statusCode}");
      }
    } catch (e) {
      print("Error updating venue: ${e.toString()}");
    }
  }

  // DELETE Method - Delete Venue
  static Future<void> deleteVenue(String id) async {
    var url = Uri.parse("${baseUrl}delete/$id");

    try {
      final res = await http.delete(url);

      if (res.statusCode == 200) {
        print("Venue deleted successfully");
      } else {
        print("Failed to delete venue: ${res.statusCode}");
      }
    } catch (e) {
      print("Error deleting venue: ${e.toString()}");
    }
  }
}
