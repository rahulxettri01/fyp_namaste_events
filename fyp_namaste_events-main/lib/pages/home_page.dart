import 'package:flutter/material.dart';
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
        title: Text('Home Page', style: textTheme.headlineSmall),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => signOut(context), // Sign out on button click
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Venues in your city', style: textTheme.headlineSmall),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 220, // Fixed height for the horizontal list
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: venues.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 180, // Fixed width for each card
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
                                      child: venues[index]['images'] != null &&
                                              venues[index]['images'].isNotEmpty
                                          ? Image.network(
                                              venues[index]['images'][0]
                                                      ['fullUrl'] ??
                                                  '',
                                              fit: BoxFit.cover,
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
                                    child: Text(
                                      venues[index]['venueName'],
                                      style: textTheme.bodyMedium,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Photographer for you',
                        style: textTheme.headlineSmall),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 220, // Fixed height for the horizontal list
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: photographers.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 180, // Fixed width for each card
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
                                      child: photographers[index]['images'] !=
                                                  null &&
                                              photographers[index]['images']
                                                  .isNotEmpty
                                          ? Image.network(
                                              photographers[index]['images'][0]
                                                      ['fullUrl'] ??
                                                  '',
                                              fit: BoxFit.cover,
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
                                    child: Text(
                                      photographers[index]['photographyName'],
                                      style: textTheme.bodyMedium,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Decoration for events',
                        style: textTheme.headlineSmall),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 220, // Fixed height for the horizontal list
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: decorations.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 180, // Fixed width for each card
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
                                      child: decorations[index]['images'] !=
                                                  null &&
                                              decorations[index]['images']
                                                  .isNotEmpty
                                          ? Image.network(
                                              decorations[index]['images'][0]
                                                      ['fullUrl'] ??
                                                  '',
                                              fit: BoxFit.cover,
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
                                    child: Text(
                                      decorations[index]['decoratorName'],
                                      style: textTheme.bodyMedium,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
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
              return Container(
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
