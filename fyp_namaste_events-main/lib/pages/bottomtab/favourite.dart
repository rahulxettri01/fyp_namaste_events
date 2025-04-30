import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roopkatha/UI/pages/artist/artist_details.dart';

class Favourite extends StatefulWidget {
  const Favourite({super.key});

  @override
  State<Favourite> createState() => _FavouriteState();
}

class _FavouriteState extends State<Favourite> {
  List<dynamic> favouriteArtists = [];
  String customerID = '';

  @override
  void initState() {
    super.initState();
    loadCustomerIDAndFetchFavourites();
  }

  Future<void> loadCustomerIDAndFetchFavourites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    customerID = prefs.getString('customerID') ?? '';
    if (customerID.isNotEmpty) {
      await fetchFavourites();
    }
  }

  Future<void> fetchFavourites() async {
    final url = Uri.parse('http://10.0.2.2:8000/api/favorites/$customerID');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          favouriteArtists = data['favorites'] ?? [];
        });
      } else {
        debugPrint('Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching favourites: $e');
    }
  }

  // Fetch artist's services
  Future<List<dynamic>> fetchArtistServices(String artistId) async {
    final url = 'http://10.0.2.2:8000/api/service/artist/$artistId';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load artist services');
      }
    } catch (e) {
      debugPrint('Error fetching artist services: $e');
      return [];
    }
  }

  // Fetch artist's average rating
  Future<Map<String, dynamic>> fetchArtistRating(String artistId) async {
    final url = "http://10.0.2.2:8000/api/reviews/artist/average/$artistId";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'avgRating': (data['avgRating'] ?? 0).toDouble(),
        'count': data['count'] ?? 0,
      };
    } else {
      return {'avgRating': 0.0, 'count': 0};
    }
  }

  Widget buildArtistCard(Map<String, dynamic> artist) {
    final artistId = artist['_id'] ?? artist['id'] ?? '';
    return FutureBuilder<List<dynamic>>(
      future: fetchArtistServices(artistId),
      builder: (context, serviceSnapshot) {
        final services = serviceSnapshot.data ?? [];
        final firstService = services.isNotEmpty ? services[0]['name'] : 'Service';
  
        return FutureBuilder<Map<String, dynamic>>(
          future: fetchArtistRating(artistId),
          builder: (context, ratingSnapshot) {
            final avgRating = ratingSnapshot.data?['avgRating'] ?? 0.0;
  
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArtistDetails(
                      artistName: artist['name'] ?? '',
                      customerName: '', // Pass customer name if available
                      artistId: artistId,
                      customerId: customerID,
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade100,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(
                            artist['profilePictureUrl'] ?? 'https://via.placeholder.com/150',
                            width: 55,
                            height: 55,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            artist['name'] ?? 'Unknown',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF1B1B38),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            firstService,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            artist['bio'] ?? 'Bio.............',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        Text(
                          avgRating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 14),
                        ),
                        // --- Heart icon for favourite toggle ---
                        IconButton(
                          icon: Icon(Icons.favorite, color: Colors.pink),
                          tooltip: 'Remove from favourites',
                          onPressed: () async {
                            final shouldRemove = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Remove Favourite'),
                                content: Text('Do you want to remove this favourite?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: Text('No'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: Text('Yes'),
                                  ),
                                ],
                              ),
                            );
                            if (shouldRemove == true) {
                              await removeFavourite(artistId);
                            }
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Favourites',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B1B38),
          ),
        ),
        centerTitle: true,
      ),
      body: customerID.isEmpty
          ? const Center(child: Text('No customer ID found'))
          : favouriteArtists.isEmpty
              ? const Center(child: Text('No favourites found'))
              : ListView.builder(
                  itemCount: favouriteArtists.length,
                  itemBuilder: (context, index) {
                    return buildArtistCard(favouriteArtists[index]);
                  },
                ),
    );
  }


Future<void> removeFavourite(String artistId) async {
  final url = Uri.parse('http://10.0.2.2:8000/api/favorites/remove');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'customerID': customerID, 'artistID': artistId}),
    );
    if (response.statusCode == 200) {
      setState(() {
        favouriteArtists.removeWhere((artist) =>
          (artist['_id'] ?? artist['id']) == artistId
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed from favourites'))
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove favourite'))
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error removing favourite: $e'))
    );
  }
}
}