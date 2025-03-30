import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fyp_namaste_events/utils/costants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:fyp_namaste_events/services/Api/api_authentication.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class InventoryDetailsPage extends StatefulWidget {
  final String token;
  final Map<String, dynamic> inventory;

  const InventoryDetailsPage(
      {required this.inventory, required this.token, Key? key})
      : super(key: key);

  @override
  _InventoryDetailsPageState createState() => _InventoryDetailsPageState();
}

class _InventoryDetailsPageState extends State<InventoryDetailsPage> {
  Map<String, dynamic> inventoryData = {};
  Map<String, dynamic> inventory = {};
  List<dynamic> images = [];
  bool isLoading = true;
  String errorMessage = '';
  var email = '';
  @override
  void initState() {
    super.initState();
    inventory = widget.inventory;
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    email = jwtDecodedToken['email'];
    fetchImages();
    // fetchInventoryData();
  }

  Future<void> fetchInventoryData() async {
    try {
      // First fetch the inventory data using the token
      final response = await http.get(
        Uri.parse('${APIConstants.baseUrl}api/get_inventory'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer ${widget.token}',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Response body: ${response.body}");
        print("Parsed data: $data");

        // Check data structure and handle different formats
        if (data != null && data.containsKey('data')) {
          var inventoryInfo = data['data'];
          print("Data['data'] type: ${inventoryInfo.runtimeType}");

          if (inventoryInfo is List && inventoryInfo.isNotEmpty) {
            // If data is a list, take the first item
            setState(() {
              inventoryData = Map<String, dynamic>.from(inventoryInfo[0]);
              print("Set inventoryData from list: $inventoryData");
            });
          } else if (inventoryInfo is Map) {
            // If data is already a map
            setState(() {
              inventoryData = Map<String, dynamic>.from(inventoryInfo);
              print("Set inventoryData from map: $inventoryData");
            });
          } else {
            print("Unexpected data format: $inventoryInfo");
            setState(() {
              isLoading = false;
              errorMessage = 'Invalid data format received';
            });
            return;
          }
        } else {
          // If no 'data' key, try using the whole response
          setState(() {
            if (data is Map) {
              inventoryData = Map<String, dynamic>.from(data);
            } else {
              errorMessage = 'Invalid response format';
              isLoading = false;
              return;
            }
          });
        }

        // Now fetch the images
        fetchImages();
      } else {
        setState(() {
          isLoading = false;
          errorMessage =
              'Failed to load inventory details: ${response.statusCode}';
        });
      }
    } catch (e) {
      print("Error in fetchInventoryData: $e");
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> getImageFiles(folderName) async {
    try {
      final response = await http.post(
        Uri.parse('${APIConstants.baseUrl}vendor/get_inventory_files'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode(
            {'email': email, 'type': "inventory", "folderName": "$folderName"}),
      );
      print("ResponseForImagesFromFolder: ${response.body}");
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> fetchImages() async {
    try {
      // Determine the email from the inventory data
      print("Inventoreeeeey: $inventory");
      print("email: $email");
      if (email.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = 'No email found for this inventory';
        });
        return;
      }

      // Determine the type based on inventory category
      String type = 'photography'; // Default type
      if (inventoryData['venueName'] != null) {
        type = 'venue';
      } else if (inventoryData['decoratorName'] != null) {
        type = 'decoration';
      } else if (inventoryData['photographyName'] != null) {
        type = 'photography';
      }

      print("email: $email");
      print("type: $type");
      final response = await http.post(
        Uri.parse('${APIConstants.baseUrl}vendor/get_verification_images'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          'email': email,
          'type': "inventory",
        }),
      );
      // print("Response: ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Response aayo lol: ${data['data']}");
        // getImageFiles(data['data']['filePath']);

        print("imgeUrl: ${data['data'][0]['fullUrl']}");
        setState(() {
          images = data['data'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load images: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the name field based on inventory type
    String inventoryName = inventory['venueName'] ??
        inventory['decoratorName'] ??
        inventory['photographyName'] ??
        "Unknown Inventory";
    print("in photo each");
    print(inventory);
    print(widget.token);
    print("in photo each");
    return Scaffold(
      appBar: AppBar(title: Text("$inventoryName Details")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inventoryName,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),
                    Text("Address: ${inventory['address'] ?? 'N/A'}",
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    Text("Price: ${inventory['price'] ?? 'N/A'}",
                        style:
                            const TextStyle(fontSize: 18, color: Colors.green)),
                    const SizedBox(height: 10),
                    Text("Status: ${inventory['status'] ?? 'Unknown'}",
                        style: TextStyle(
                            fontSize: 18,
                            color: inventory['status'] == 'available'
                                ? Colors.green
                                : Colors.red)),
                    const SizedBox(height: 20),
                    Text("Images:",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    if (images.isNotEmpty)
                      Column(
                        children: images.map((image) {
                          return Image.network(
                            '${image['fullUrl']}',
                            height: 300,
                            fit: BoxFit.contain,
                          );
                        }).toList(),
                      )
                    // Rest of the UI remains similar but using inventoryData instead of widget.inventory
                    // ...
                  ],
                ),
              ),
            ),
    );
  }
}
