import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:roopkatha/UI/pages/artist/artist_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../service/notification_page.dart';
import 'bottomtab.dart';
import 'explore_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CusHomePage extends StatefulWidget {
  const CusHomePage({super.key});

  @override
  _CusHomePageState createState() => _CusHomePageState();
}

class _CusHomePageState extends State<CusHomePage> {
  List<dynamic> artists = [];
  String serviceName = '';
  String customerName = '';
  String customerId = ''; //
  String searchQuery = '';
  int unreadNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    fetchCustomerData();
    fetchArtists();
    fetchUnreadNotificationCount();
  }

  Future<void> fetchUnreadNotificationCount() async {
    try {
      // If you have a token, pass it here. Otherwise, use an empty string.
      final api = NotificationApiService(token: '');
      final count = await api.fetchUnreadCount();
      setState(() {
        unreadNotificationCount = count;
      });
    } catch (e) {
      setState(() {
        unreadNotificationCount = 0;
      });
    }
  }

  Future<void> fetchCustomerData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      customerId = prefs.getString('customerID') ?? '';
      customerName = prefs.getString('customerName') ?? '';
    });
    fetchCustomerName();
  }

  Future<void> fetchCustomerName() async {
    final String baseUrl = 'http://10.0.2.2:8000'; // Adjust the base URL as needed
    final String url = '$baseUrl/customer/name/$customerId'; // Adjust the endpoint as needed

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          customerName = json.decode(response.body)['name'];
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('customerName', customerName);
      } else {
        throw Exception('Failed to load customer name');
      }
    } catch (e) {
      print('Error fetching customer name: $e');
    }
  }

  Future<void> fetchArtists() async {
    final String baseUrl = 'http://10.0.2.2:8000'; // Adjust the base URL as needed
    final String url = '$baseUrl/api/artist/all';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          artists = json.decode(response.body)['artists'];
        });
      } else {
        throw Exception('Failed to load artists');
      }
    } catch (e) {
      print('Error fetching artists: $e');
    }
  }

  Future<List<dynamic>> fetchArtistServices(String artistId) async {
    final String baseUrl = 'http://10.0.2.2:8000'; // Adjust the base URL as needed
    final String url = '$baseUrl/api/service/artist/$artistId';

    try {
      final response = await http.get(Uri.parse(url));

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

  List<dynamic> getFilteredArtists() {
    List<dynamic> filteredArtists = artists;
    if (serviceName.isNotEmpty) {
      filteredArtists = filteredArtists.where((artist) => artist['profession'] == serviceName).toList();
    }
    if (searchQuery.isNotEmpty) {
      filteredArtists = filteredArtists.where((artist) {
        final name = artist['name']?.toLowerCase() ?? '';
        final profession = artist['profession']?.toLowerCase() ?? '';
        return name.contains(searchQuery.toLowerCase()) || profession.contains(searchQuery.toLowerCase());
      }).toList();
    }
    return filteredArtists;
  }

  void navigateToExplorePage() {
    // Replace with your navigation logic to the explore page
    Get.to(() => ExplorePage()); // Assuming you have an ExplorePage widget
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the entire app's background color to white
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 48, // Make the AppBar small, just enough for the icon
        title: null, // No title
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications, color: Color(0xFFFF6FCA)),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationPage(
                        token: '', // Pass the actual token if you have it
                      ),
                    ),
                  );
                  // Refresh the notification count after returning
                  fetchUnreadNotificationCount();
                },
              ),
              if (unreadNotificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2), // Reduced padding
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 14, // Reduced size
                      minHeight: 14,
                    ),
                    child: Center(
                      child: Text(
                        '$unreadNotificationCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9, // Smaller font size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),  // Adjust the value as needed
              child: Text(
                'Hi $customerName,',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0), // Small gap around the container
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFFF6FCA), // Custom hex color FF7DE5
                      borderRadius: BorderRadius.circular(20), // Rounded corners
                    ),
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20), // Inner padding matches the image
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Let\'s find\nyour top Artist!',
                          style: TextStyle(
                            fontSize: 35, // Font size matches the image
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // White text color
                          ),
                        ),
                        SizedBox(height: 30), // Match space between text and search bar
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white, // White background for the search bar
                            borderRadius: BorderRadius.circular(30), // Rounded edges for the search bar
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5), // Padding inside the search bar
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: Colors.grey, // Grey search icon
                                size: 24, // Icon size matches the image
                              ),
                              SizedBox(width: 10), // Space between icon and text field
                              Expanded(
                                child: TextField(
                                  onChanged: (value) {
                                    setState(() {
                                      searchQuery = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Search Top Artists.......', // Placeholder text matches the image
                                    hintStyle: TextStyle(
                                      color: Colors.grey, // Grey hint text
                                      fontSize: 16, // Font size for the hint text
                                    ),
                                    border: InputBorder.none, // Remove default border
                                  ),
                                  style: TextStyle(
                                    color: Colors.black, // Black text color for input
                                    fontSize: 16, // Font size for user input matches the image
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Services',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: serviceIcon(
                      'assets/icons/hair.png',
                      'Hair Style',
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: serviceIcon(
                      'assets/icons/nails.png',
                      'Nails',
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: serviceIcon(
                      'assets/icons/makeup.png',
                      'Makeup',
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: serviceIcon(
                      'assets/icons/bridal.png',
                      'Bridal',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Popular Artists',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  TextButton(
                    onPressed: navigateToExplorePage,
                    child: Text(
                      'See All',
                      style: TextStyle(
                        color: Colors.pink[300],
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (getFilteredArtists().isEmpty)
                    Center(child: Text('No artists available.')),
                  ...getFilteredArtists().map((artist) => FutureBuilder(
                    future: fetchArtistServices(artist['_id']),
                    builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                      return Center(child: Text('Error loading services'));
                  } else {
    final services = snapshot.data ?? [];
    final firstService = services.isNotEmpty ? services[0]['name'] : '';
    return FutureBuilder<Map<String, dynamic>>(
    future: fetchArtistRating(artist['_id']),
    builder: (context, ratingSnapshot) {
    final avgRating = ratingSnapshot.data?['avgRating'] ?? 0.0;
    return Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
    BoxShadow(
    color: const Color(0x143C3C43), // subtle shadow
    blurRadius: 16,
    offset: const Offset(0, 4),
    ),
    ],
    ),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    child: Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
    // Avatar
    ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: artist['profilePictureUrl'] != null
    ? Image.network(
    artist['profilePictureUrl'],
    width: 56,
    height: 56,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) =>
    Icon(Icons.person, size: 40, color: Colors.grey[400]),
    )
        : Container(
    width: 56,
    height: 56,
    color: const Color(0xFFF1F2F4),
    child: Icon(Icons.person, size: 40, color: Colors.grey[400]),
    ),
    ),
    const SizedBox(width: 16),
    // Name and service
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    artist['name'] ?? 'Artist',
    style: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Color(0xFF222B45),
    ),
    ),
    const SizedBox(height: 4),
    Text(
    firstService,
    style: const TextStyle(
    fontSize: 15,
    color: Color(0xFF8F9BB3),
    fontWeight: FontWeight.w500,
    ),
    ),
    const SizedBox(height: 12),
    Row(
    children: [
    Icon(Icons.star, color: Color(0xFFFFC529), size: 22),
    const SizedBox(width: 6),
    Text(
    avgRating.toStringAsFixed(1),
    style: const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: Color(0xFF222B45),
    ),
    ),
    ],
    ),
    ],
    ),
    ),
    // Appointment button
    Container(
    margin: const EdgeInsets.only(left: 8),
    child: Material(
    color: const Color(0xFFF7F7FB),
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: () {
    Get.to(() => ArtistDetails(
    artistName: artist['name'],
    artistId: artist['_id'],
    customerName: customerName,
    customerId: customerId,
    ));
    },
    child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
    child: Text(
    'Appointment',
    style: const TextStyle(
    color: Color(0xFF222B45),
    fontWeight: FontWeight.w600,
    fontSize: 15,
    ),
    ),
    ),
    ),
    ),
    ),
    // Message button
    Container(
    margin: const EdgeInsets.only(left: 8),
    child: Material(
    color: Color(0xFFFF6FCA),
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: () {
    // TODO: Add your message/chat navigation here
    },
    child: Padding(
    padding: const EdgeInsets.all(10),
    child: Icon(
    Icons.message,
    color: Colors.white,
    size: 22,
    ),
    ),
    ),
    ),
    ),
    ]
    )
    );
    }
    );

                  }
                    })

                  )
                ]
              )
            )
          ]
        )
      ),
      bottomNavigationBar: CusBottomTabs(currentIndex: 0),
    );


                      }
                      }



  Widget serviceIcon(String assetPath, String label) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200, width: 2),
          ),
          child: Center(
            child: Image.asset(
              assetPath,
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

// Add this function inside your _CusHomePageState class:
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