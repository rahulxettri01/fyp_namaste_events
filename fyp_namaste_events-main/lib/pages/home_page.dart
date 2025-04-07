import 'package:flutter/material.dart';
import 'package:fyp_namaste_events/pages/vendor_detail_page.dart';
import 'package:fyp_namaste_events/utils/theme/custom_themes/text_theme.dart';
import 'package:fyp_namaste_events/pages/login_register_page.dart';
import '../components/bottom_nav_bar.dart';
import '../services/Api/vendorService.dart';
import '../utils/costants/api_constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late VendorService vendorService;
  List<dynamic> venues = [];
  List<dynamic> photographers = [];
  List<dynamic> decorations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    vendorService = VendorService(
        APIConstants.baseUrl); // Replace with your vendor's API base URL
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final fetchedInventory = await vendorService.fetchAllInventory();
      print("featched Data");
      print(fetchedInventory);
      if (fetchedInventory['success']) {
        setState(() {
          venues = fetchedInventory['data']['venues'];
          photographers = fetchedInventory['data']['photographers'];
          decorations = fetchedInventory['data']['decorators'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle error
      print('Failed to fetch data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Sign-out function
  void signOut(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).brightness == Brightness.dark
        ? TTextTheme.darkTextTheme
        : TTextTheme.lightTextTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Namaste Events', style: textTheme.headlineSmall),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'signout') {
                signOut(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Sign Out': 'signout'}
                  .entries
                  .map((entry) => PopupMenuItem<String>(
                        value: entry.value,
                        child: Text(entry.key),
                      ))
                  .toList();
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Venues in your city section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Venues in your city',
                            style: textTheme.headlineSmall),
                        TextButton(
                          onPressed: () {
                            // View all venues
                          },
                          child: Text(
                            'View All',
                            style: TextStyle(color: Colors.purple),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Venues Horizontal List
                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: venues.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VendorDetailPage(
                                  vendorData: venues[index],
                                  vendorType: 'venue',
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 180,
                            margin: const EdgeInsets.only(right: 12),
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(10)),
                                      child: venues[index]['images'] != null &&
                                              venues[index]['images'].isNotEmpty
                                          ? Image.network(
                                              venues[index]['images'][0]
                                                      ['fullUrl'] ??
                                                  '',
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey.shade300,
                                                  child: const Icon(
                                                      Icons.image_not_supported,
                                                      size: 40),
                                                );
                                              },
                                            )
                                          : Container(
                                              color: Colors.grey.shade300,
                                              child: const Icon(Icons.home,
                                                  size: 40),
                                            ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          venues[index]['venueName'] ??
                                              'Unknown Venue',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          venues[index]['address'] ??
                                              'Location',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        // Star rating row removed
                                        Text(
                                          'Rs ${venues[index]['price'] ?? '1000'} per plate',
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Photographer for you
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Photographer for you',
                            style: textTheme.headlineSmall),
                        TextButton(
                          onPressed: () {
                            // View all photographers
                          },
                          child: Text(
                            'View All',
                            style: TextStyle(color: Colors.purple),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Photographers Horizontal List
                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: photographers.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VendorDetailPage(
                                  vendorData: photographers[index],
                                  vendorType: 'photographer',
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 180,
                            margin: const EdgeInsets.only(right: 12),
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(10)),
                                      child: photographers[index]['images'] !=
                                                  null &&
                                              photographers[index]['images']
                                                  .isNotEmpty
                                          ? Image.network(
                                              photographers[index]['images'][0]
                                                      ['fullUrl'] ??
                                                  '',
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey.shade300,
                                                  child: const Icon(
                                                      Icons.image_not_supported,
                                                      size: 40),
                                                );
                                              },
                                            )
                                          : Container(
                                              color: Colors.grey.shade300,
                                              child: const Icon(
                                                  Icons.camera_alt,
                                                  size: 40),
                                            ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          photographers[index]
                                                  ['photographyName'] ??
                                              'Unknown',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          photographers[index]['address'] ??
                                              'Location',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          'Rs ${photographers[index]['price'] ?? '50,000'} per Event',
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Decoration for events
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Decoration for events',
                            style: textTheme.headlineSmall),
                        TextButton(
                          onPressed: () {
                            // View all decorations
                          },
                          child: Text(
                            'View All',
                            style: TextStyle(color: Colors.purple),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Decorations Horizontal List
                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: decorations.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VendorDetailPage(
                                  vendorData: decorations[index],
                                  vendorType: 'decorator',
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 180,
                            margin: const EdgeInsets.only(right: 12),
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(10)),
                                      child: decorations[index]['images'] !=
                                                  null &&
                                              decorations[index]['images']
                                                  .isNotEmpty
                                          ? Image.network(
                                              decorations[index]['images'][0]
                                                      ['fullUrl'] ??
                                                  '',
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey.shade300,
                                                  child: const Icon(
                                                      Icons.image_not_supported,
                                                      size: 40),
                                                );
                                              },
                                            )
                                          : Container(
                                              color: Colors.grey.shade300,
                                              child: const Icon(
                                                  Icons.celebration,
                                                  size: 40),
                                            ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          decorations[index]['decoratorName'] ??
                                              'Unknown',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          decorations[index]['address'] ??
                                              'Location',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          'Rs ${decorations[index]['price'] ?? '45,000'} per event',
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}

Widget _buildHorizontalScrollWithButtons(
  BuildContext context,
  List<dynamic> items,
  String Function(dynamic) nameGetter,
  dynamic Function(dynamic) imagesGetter,
  IconData fallbackIcon,
  String vendorType,
) {
  final textTheme = Theme.of(context).brightness == Brightness.dark
      ? TTextTheme.darkTextTheme
      : TTextTheme.lightTextTheme;

  final ScrollController scrollController = ScrollController();

  return SizedBox(
    height: 220,
    child: Stack(
      children: [
        // Main ListView
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: ListView.builder(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // Navigate to vendor detail page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VendorDetailPage(
                        vendorData: items[index],
                        vendorType: vendorType,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 180,
                  margin: const EdgeInsets.only(right: 12),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(10)),
                            child: imagesGetter(items[index]) != null &&
                                    imagesGetter(items[index]).isNotEmpty
                                ? Image.network(
                                    imagesGetter(items[index])[0]['fullUrl'] ??
                                        '',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey.shade300,
                                        child: const Icon(
                                            Icons.image_not_supported,
                                            size: 40),
                                      );
                                    },
                                  )
                                : Container(
                                    color: Colors.grey.shade300,
                                    child: Icon(fallbackIcon, size: 40),
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            nameGetter(items[index]),
                            style: textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Left scroll button
        if (items.isNotEmpty)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor,
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                  ],
                  stops: const [0.0, 1.0],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Center(
                child: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.7),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () {
                      final currentPosition = scrollController.offset;
                      final scrollAmount = currentPosition - 200.0;
                      scrollController.animateTo(
                        scrollAmount < 0 ? 0 : scrollAmount,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

        // Right scroll button
        if (items.isNotEmpty)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                  stops: const [0.0, 1.0],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Center(
                child: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.7),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios,
                        color: Colors.white),
                    onPressed: () {
                      final currentPosition = scrollController.offset;
                      final maxScrollExtent =
                          scrollController.position.maxScrollExtent;
                      final scrollAmount = currentPosition + 200.0;
                      scrollController.animateTo(
                        scrollAmount > maxScrollExtent
                            ? maxScrollExtent
                            : scrollAmount,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
