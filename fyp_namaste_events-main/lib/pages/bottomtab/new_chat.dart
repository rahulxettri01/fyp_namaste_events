import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../customer_shared_preferences.dart';
import 'chat_helpers.dart';
import 'chat_screen.dart';

class NewChatPage extends StatefulWidget {
  const NewChatPage({super.key});

  @override
  State<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  bool isLoading = true;
  List<dynamic> artists = [];
  String? customerId;

  @override
  void initState() {
    super.initState();
    _loadArtists();
  }

  Future<void> _loadArtists() async {
    customerId = await CustomerSharedPreferences.getCustomerID();
    setState(() {
      isLoading = true;
    });
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/artists'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        artists = data['artists'] ?? [];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Failed to load artists');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _startChat(String artistId, String artistName, String artistAvatar) async {
    if (customerId == null) {
      _showErrorSnackBar('Customer ID not found');
      return;
    }
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/chat'),
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
      final chatId = chat['_id'];
      Navigator.pop(context, true);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: chatId,
            customerId: customerId!,
            customerModel: 'Customer',
            otherUserName: artistName,
            otherUserAvatar: artistAvatar,
          ),
        ),
      );
    } else {
      _showErrorSnackBar('Failed to start chat');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Artist'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: artists.length,
              itemBuilder: (context, index) {
                final artist = artists[index];
                final artistId = artist['_id'];
                final artistName = artist['name'] ?? 'Artist';
                final artistAvatar = artist['profilePictureUrl'] ?? 'https://via.placeholder.com/100';
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(artistAvatar),
                  ),
                  title: Text(artistName),
                  onTap: () => _startChat(artistId, artistName, artistAvatar),
                );
              },
            ),
    );
  }
}
