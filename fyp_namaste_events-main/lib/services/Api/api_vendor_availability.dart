import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fyp_namaste_events/utils/costants/api_constants.dart';

class ApiVendorAvailability {
  static Future<List<dynamic>> getAvailableSlots(
      String vendorEmail, String token) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${APIConstants.baseUrl}api/vendorAvailability/available?vendorEmail=$vendorEmail'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print("get the availability slots");
      print(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch availability slots: $e');
    }
  }

  static Future<bool> createSlot(
      String token, Map<String, dynamic> slotData) async {
    try {
      final response = await http.post(
        Uri.parse('${APIConstants.baseUrl}vendorAvailability/create-slot'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(slotData),
      );

      return response.statusCode == 201;
    } catch (e) {
      throw Exception('Failed to create availability slot: $e');
    }
  }
}
