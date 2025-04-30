import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String?> createChat(String customerId, String artistId) async {
  final String baseUrl = 'http://10.0.2.2:8000';
  final response = await http.post(
    Uri.parse('$baseUrl/api/chat'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "participants": [
        {"participantId": customerId, "participantModel": "Customer"},
        {"participantId": artistId, "participantModel": "Artist"}
      ]
    }),
  );
  if (response.statusCode == 200) {
    final chat = jsonDecode(response.body)['chat'];
    return chat['_id'];
  } else {
    return null;
  }
}