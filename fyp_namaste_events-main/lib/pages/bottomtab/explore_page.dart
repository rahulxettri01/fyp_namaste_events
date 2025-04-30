import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../artist/artist_details.dart';
import '../customer_shared_preferences.dart';
import 'bottomtab.dart';
import 'chat_helpers.dart';
import 'chat_screen.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  List<dynamic> artists = [];
  List<dynamic> filteredArtists = [];
  final String baseUrl = 'http://10.0.2.2:8000';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchArtists();
  }

  Future<void> fetchArtists() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/artist/all'));
      if (response.statusCode == 200) {
        setState(() {
          artists = json.decode(response.body)['artists'];
          filteredArtists = artists;
        });
      } else {
        throw Exception('Failed to load artists');
      }
    } catch (e) {
      print('Error fetching artists: $e');
    }
  }

  Future<List<dynamic>> fetchArtistServices(String artistId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/service/artist/$artistId'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load artist services');
      }
    } catch (e) {
      print('Error fetching artist services: $e');
      return [];
    }
  }

  void filterSearchResults(String query) {
    if (query.isNotEmpty) {
      final results = artists.where((item) {
        final name = item['name'].toString().toLowerCase();
        final profession = item['profession'].toString().toLowerCase();
        return name.contains(query.toLowerCase()) || profession.contains(query.toLowerCase());
      }).toList();

      setState(() {
        filteredArtists = results;
      });
    } else {
      setState(() {
        filteredArtists = artists;
      });
    }
  }

  // Add this helper function inside _ExplorePageState
  Future<void> _startChatWithArtist(dynamic artist) async {
    final customerId = await CustomerSharedPreferences.getCustomerID();
    if (customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer not found')),
      );
      return;
    }
    final chatId = await createChat(customerId, artist['_id']);
    if (chatId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: chatId,
            customerId: customerId,
            customerModel: 'Customer',
            otherUserName: artist['name'] ?? 'Artist',
            otherUserAvatar: artist['profilePictureUrl'] ?? 'https://via.placeholder.com/100',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to start chat')),
      );
    }
  }

  Widget buildArtistCard(artist, List<dynamic> services) {
    final bio = artist['bio'] ?? 'No bio available';
    final firstService = services.isNotEmpty ? services[0]['name'] : 'No services available';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              artist['profilePictureUrl'] ?? 'https://via.placeholder.com/150',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artist['name'] ?? 'Artist',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  bio.length > 30 ? '${bio.substring(0, 30)}...' : bio,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  firstService,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF8F9BB3),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Get.to(() => ArtistDetails(
                          artistName: artist['name'],
                          artistId: artist['_id'],
                          customerName: 'Customer', customerId: '',
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F2F4),
                        elevation: 0,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text("Appointment"),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _startChatWithArtist(artist),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD1F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.chat_bubble_outline, color: Colors.pink, size: 20),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'Top Artist',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
              ),
            ),
            Container(height: 1, color: Colors.grey[300]),
            const SizedBox(height: 16),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: searchController,
                onChanged: filterSearchResults,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search Artist by name or profession...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // const Text('Popular Artists', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  if (filteredArtists.isEmpty)
                    const Center(child: Text('No artists available.')),
                  ...filteredArtists.map((artist) => FutureBuilder(
                    future: fetchArtistServices(artist['_id']),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('Error loading services'));
                      } else {
                        final services = snapshot.data ?? [];
                        return buildArtistCard(artist, services);
                      }
                    },
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CusBottomTabs(currentIndex: 1),
    );
  }
}
