import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fyp_namaste_events/pages/login_register_page.dart';
import 'package:fyp_namaste_events/services/Api/api_authentication.dart';

class AddInventoryPage extends StatefulWidget {
  final String token;
  const AddInventoryPage({required this.token, Key? key}) : super(key: key);

  @override
  _AddInventoryPageState createState() => _AddInventoryPageState();
}

class _AddInventoryPageState extends State<AddInventoryPage> {
  late String userStatus;
  late String vendorType;
  late SharedPreferences prefs;
  String? errorMessage = '';
  List<Map<String, String>> accommodations = [];

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    userStatus = jwtDecodedToken['status'];
    vendorType = jwtDecodedToken['category'];
  }

  void _addInventory() {
    setState(() {
      if (_nameController.text.isEmpty || _priceController.text.isEmpty || _addressController.text.isEmpty) {
        errorMessage = "Please fill in all fields.";
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage!)));
      } else {
        var data = {
          "inventoryName": _nameController.text,
          "address": _addressController.text,
          "price": _priceController.text,
          "description": _descriptionController.text,
          "accommodation": accommodations,
        };

        Api.addInventory(data).then((response) {
          if (response != null) {
            int statusCode = response["status_code"];
            if (statusCode == 200) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("The venue is uploaded")));
              Navigator.pop(context, true); // Return true to indicate success
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("The venue upload failed")));
            }
          } else {
            setState(() {
              errorMessage = "Unexpected response from server.";
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage!)));
            });
          }
        });
      }
    });
  }

  void _addAccommodationField() {
    setState(() {
      accommodations.add({"type": "", "details": ""});
    });
  }

  void _updateAccommodation(int index, String field, String value) {
    setState(() {
      accommodations[index][field] = value;
    });
  }

  void _removeAccommodation(int index) {
    setState(() {
      accommodations.removeAt(index);
    });
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String? selectedImagePath;

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        selectedImagePath = result.files.single.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Inventory")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Inventory Name", border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(labelText: "Description", border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Price (\Rs)", border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(labelText: "Address", border: OutlineInputBorder()),
              ),
              SizedBox(height: 20),
              Text("Accommodation", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Column(
                children: accommodations.asMap().entries.map((entry) {
                  int index = entry.key;
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) => _updateAccommodation(index, "type", value),
                          decoration: InputDecoration(labelText: "Type", border: OutlineInputBorder()),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          onChanged: (value) => _updateAccommodation(index, "details", value),
                          decoration: InputDecoration(labelText: "Details", border: OutlineInputBorder()),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => _removeAccommodation(index),
                      )
                    ],
                  );
                }).toList(),
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(Icons.add_circle, color: Colors.blue, size: 30),
                  onPressed: _addAccommodationField,
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: selectedImagePath == null
                      ? Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                      : Image.file(File(selectedImagePath!), fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addInventory,
                  child: Text("Add Inventory", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}