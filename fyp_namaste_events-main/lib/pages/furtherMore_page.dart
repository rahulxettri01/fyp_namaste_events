import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fyp_namaste_events/pages/admin_panel.dart';
import 'package:fyp_namaste_events/pages/login_register_page.dart';
import 'package:http/http.dart' as http;

class VerificationPage extends StatefulWidget {
  const VerificationPage({Key? key}) : super(key: key);

  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  bool isChecked = false;
  List<File> selectedFiles = [];
  List<String> selectedFileNames = [];

  // Function to pick multiple files
  Future<void> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      setState(() {
        selectedFiles = result.files.map((file) => File(file.path!)).toList();
        selectedFileNames = result.files.map((file) => file.name).toList();
      });
    }
  }

  // Function to upload multiple files
  Future<void> uploadFiles() async {
    if (selectedFiles.isNotEmpty) {
      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://192.168.1.72:2000/vendor/upload'), // Replace with your actual API URL
        );

        // Add multiple files to the request
        for (var file in selectedFiles) {
          request.files.add(await http.MultipartFile.fromPath('files', file.path));
        }

        var response = await request.send();

        if (response.statusCode == 200) {
          var responseBody = await response.stream.bytesToString();
          print('Files uploaded successfully: $responseBody');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Files uploaded successfully!")),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminPanel()),
          );
        } else {
          print('Failed to upload files: ${response.reasonPhrase}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to upload files")),
          );
        }
      } catch (e) {
        print('Error uploading files: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An error occurred while uploading")),
        );
      }
    } else {
      print("Please select files before uploading.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select files before uploading")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFE3F2FD)],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Furthermore details",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              '"Turning Plans into Perfect Moments!"',
              style: TextStyle(fontSize: 14, color: Colors.blueAccent),
            ),
            const SizedBox(height: 30),

            filePickerButton(), // File Picker Button
            const SizedBox(height: 20),

            // Checkbox for agreeing to Terms & Conditions
            Row(
              children: [
                Checkbox(
                  value: isChecked,
                  activeColor: Colors.purple,
                  onChanged: (value) {
                    setState(() {
                      isChecked = value!;
                    });
                  },
                ),
                const Text("I agree with the "),
                const Text(
                  "Terms of Service & Privacy Policy",
                  style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Upload Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isChecked ? uploadFiles : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "For verification",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Navigate to Login Page
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text(
                "Have an account? Log in",
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // File Picker UI
  Widget filePickerButton() {
    return GestureDetector(
      onTap: pickFiles,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 5)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Files", style: TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 5),
            // Display selected file names
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: selectedFileNames
                  .map((fileName) => Text(fileName, style: const TextStyle(fontSize: 14, color: Colors.black87)))
                  .toList(),
            ),
            const Icon(Icons.upload_file, color: Colors.purple),
          ],
        ),
      ),
    );
  }
}
