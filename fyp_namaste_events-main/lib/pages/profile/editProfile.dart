import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../service/auth_service.dart';
import '../customer_shared_preferences.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isSaving = false;

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  String _customerName = '';
  String _customerEmail = '';
  String _customerPhone = '';
  String _profilePictureUrl = '';
  String? _customerId;
  String? _customerDOB = '';
  String? _customerGender = '';
  String? _authToken = '';

  File? _image;
  String? _imageError;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    _fetchCustomerData();
  }

  Future<void> _fetchCustomerData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _customerName = await CustomerSharedPreferences.getCustomerName() ?? '';
      _customerPhone = await CustomerSharedPreferences.getCustomerNumber() ?? '';
      _profilePictureUrl = await CustomerSharedPreferences.getProfilePictureUrl() ?? '';
      _customerEmail = await CustomerSharedPreferences.getCustomerEmail() ?? '';
      _customerId = await CustomerSharedPreferences.getCustomerID();
      // Fetch DOB from shared preferences
      _customerDOB = await CustomerSharedPreferences.getCustomerDOB() ?? '';
      _customerGender = await CustomerSharedPreferences.getCustomerGender() ?? '';
      _authToken = await CustomerSharedPreferences.getAuthToken() ?? '';

      nameController.text = _customerName;
      emailController.text = _customerEmail;
      phoneController.text = _customerPhone;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load customer data')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final filePath = pickedFile.path;
        final mimeType = lookupMimeType(filePath);

        print('Selected image path: $filePath');
        print('Selected image MIME type: $mimeType');

        // Clear any previous error
        setState(() {
          _imageError = null;
        });

        // Validate mime type
        if (mimeType == null) {
          setState(() {
            _imageError = 'Could not determine file type';
          });
          return;
        }

        if (!(mimeType == 'image/jpeg' || mimeType == 'image/png')) {
          setState(() {
            _imageError = 'Only JPEG and PNG files are allowed';
          });
          return;
        }

        setState(() {
          _image = File(filePath);
        });
      } else {
        print('No image selected');
      }
    } catch (e) {
      print('Error picking image: $e');
      setState(() {
        _imageError = 'Error picking image: $e';
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_customerId == null) {
      print('No customer ID found');
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    if (token == null) {
      print('No auth token found');
      return;
    }

    // Basic validation
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }

    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email cannot be empty')),
      );
      return;
    }

    if (phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number cannot be empty')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final url = Uri.parse('http://10.0.2.2:8000/api/customer/update/$_customerId');
    final request = http.MultipartRequest('PUT', url);

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['name'] = nameController.text.trim();
    request.fields['email'] = emailController.text.trim();
    request.fields['phoneNo'] = phoneController.text.trim();

    if (_image != null) {
      try {
        print('Adding image to request: ${_image!.path}');

        // Get the file extension
        final fileExt = path.extension(_image!.path).toLowerCase();

        // Determine content type based on extension
        String contentType;
        if (fileExt == '.jpg' || fileExt == '.jpeg') {
          contentType = 'image/jpeg';
        } else if (fileExt == '.png') {
          contentType = 'image/png';
        } else {
          // Default to jpeg if we can't determine
          contentType = 'image/jpeg';
        }

        // Create multipart file with explicit content type
        final multipartFile = await http.MultipartFile.fromPath(
          'profilePicture',
          _image!.path,
          contentType: MediaType.parse(contentType),
        );

        request.files.add(multipartFile);
      } catch (e) {
        print('Error adding image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding image: $e')),
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }
    } else {
      print('No image selected for upload');
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final updatedData = jsonDecode(response.body);

        // Get the updated profile picture URL if available
        String newProfilePictureUrl = _profilePictureUrl;
        if (updatedData['customer']['profilePictureUrl'] != null) {
          newProfilePictureUrl = updatedData['customer']['profilePictureUrl'];
        }

        // Instead of individual setters, use the saveCustomerData method
        await CustomerSharedPreferences.saveCustomerData(
          customerID: _customerId!,
          customerName: nameController.text.trim(),
          customerEmail: emailController.text.trim(),
          customerNumber: phoneController.text.trim(),
          authToken: _authToken!,
          customerDOB: _customerDOB!,
          customerGender: _customerGender!,
          profilePictureUrl: newProfilePictureUrl,
        );

        // Update the state
        setState(() {
          _customerName = nameController.text.trim();
          _customerEmail = emailController.text.trim();
          _customerPhone = phoneController.text.trim();
          _profilePictureUrl = newProfilePictureUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context); // Navigate back after update
        await _showSuccessDialog();
      } else {
        // Parse error response
        String errorMessage = 'Failed to update profile';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['error'] != null) {
            errorMessage = errorData['error'];
          }
        } catch (_) {}

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Widget _buildProfilePicture() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: _image != null
                ? FileImage(_image!)
                : (_profilePictureUrl.isNotEmpty
                    ? NetworkImage(_profilePictureUrl)
                    : const AssetImage('assets/images/default_profile.png')) as ImageProvider,
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: Color(0xFF23242C),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDOB() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _customerDOB != null && _customerDOB!.isNotEmpty
          ? DateFormat('yyyy-MM-dd').parse(_customerDOB!)
          : DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFFFF6FCA),
              onPrimary: Colors.white,
              onSurface: Color(0xFF23242C),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _customerDOB = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectGender() async {
    String? selected = await showModalBottomSheet<String>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Male'),
              onTap: () => Navigator.pop(context, 'Male'),
            ),
            ListTile(
              title: Text('Female'),
              onTap: () => Navigator.pop(context, 'Female'),
            ),
            ListTile(
              title: Text('Other'),
              onTap: () => Navigator.pop(context, 'Other'),
            ),
          ],
        );
      },
    );
    if (selected != null) {
      setState(() {
        _customerGender = selected;
      });
    }
  }

  Widget _buildProfileField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE5E5EA)),
      ),
      child: ListTile(
        title: Text(
          label,
          style: TextStyle(
            color: Color(0xFF8D8D8D),
            fontWeight: FontWeight.w400,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          value.isNotEmpty ? value : label,
          style: TextStyle(
            color: value.isNotEmpty ? Color(0xFF23242C) : Color(0xFFBDBDBD),
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Color(0xFFD1D1D6)),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 2),
      ),
    );
  }

  Future<void> _updateProfileField({String? name, String? email, String? phone, String? dob, String? gender}) async {
    if (_customerId == null) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    if (token == null) return;

    final url = Uri.parse('http://10.0.2.2:8000/api/customer/update/$_customerId');
    final request = http.MultipartRequest('PUT', url);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['name'] = name ?? _customerName;
    request.fields['email'] = email ?? _customerEmail;
    request.fields['phoneNo'] = phone ?? _customerPhone;
    request.fields['dob'] = dob ?? _customerDOB ?? '';
    request.fields['gender'] = gender ?? _customerGender ?? '';

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final updatedData = jsonDecode(response.body);
        String newProfilePictureUrl = _profilePictureUrl;
        if (updatedData['customer']['profilePictureUrl'] != null) {
          newProfilePictureUrl = updatedData['customer']['profilePictureUrl'];
        }
        await CustomerSharedPreferences.saveCustomerData(
          customerID: _customerId!,
          customerName: name ?? _customerName,
          customerEmail: email ?? _customerEmail,
          customerNumber: phone ?? _customerPhone,
          authToken: _authToken!,
          customerDOB: dob ?? _customerDOB ?? '',
          customerGender: gender ?? _customerGender ?? '',
          profilePictureUrl: newProfilePictureUrl,
        );
        setState(() {
          if (name != null) _customerName = name;
          if (email != null) _customerEmail = email;
          if (phone != null) _customerPhone = phone;
          if (dob != null) _customerDOB = dob;
          if (gender != null) _customerGender = gender;
          _profilePictureUrl = newProfilePictureUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Profile updated successfully')),
        );
       Navigator.pop(context); // Navigate back after update
       await _showSuccessDialog();
      } else {
        String errorMessage = 'Failed to update profile';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['error'] != null) {
            errorMessage = errorData['error'];
          }
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  Future<void> _showSuccessDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Color(0xFFFF6FCA),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: Color(0xFF23242C),
                        size: 32,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Profile Update Successful',
                  style: TextStyle(
                    color: Color(0xFF23242C),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 120,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF6FCA),
                      shape: StadiumBorder(),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Ok',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
        leading: BackButton(color: Color(0xFF23242C)),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Color(0xFF23242C),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _buildProfilePicture(),
                  const SizedBox(height: 24),
                  _buildProfileField(
                    label: 'Name',
                    value: _customerName,
                    onTap: () async {
                      final result = await showDialog<String>(
                        context: context,
                        builder: (context) {
                          final controller = TextEditingController(text: _customerName);
                          return AlertDialog(
                            title: Text('Edit Name'),
                            content: TextField(
                              controller: controller,
                              decoration: InputDecoration(hintText: 'Enter your name'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFFF6FCA),
                                ),
                                onPressed: () => Navigator.pop(context, controller.text),
                                child: Text(
                                  'Save',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                      if (result != null && result.trim().isNotEmpty) {
                        await _updateProfileField(name: result.trim());
                      }
                    },
                  ),
                  _buildProfileField(
                    label: 'Email',
                    value: _customerEmail,
                    onTap: () async {
                      final result = await showDialog<String>(
                        context: context,
                        builder: (context) {
                          final controller = TextEditingController(text: _customerEmail);
                          return AlertDialog(
                            title: Text('Edit Email'),
                            content: TextField(
                              controller: controller,
                              decoration: InputDecoration(hintText: 'Enter your email'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFFF6FCA),
                                ),
                                onPressed: () => Navigator.pop(context, controller.text),
                                child: Text('Save'),
                              ),
                            ],
                          );
                        },
                      );
                      if (result != null && result.trim().isNotEmpty) {
                        await _updateProfileField(email: result.trim());
                      }
                    },
                  ),
                  _buildProfileField(
                    label: 'Phone Number',
                    value: _customerPhone,
                    onTap: () async {
                      final result = await showDialog<String>(
                        context: context,
                        builder: (context) {
                          final controller = TextEditingController(text: _customerPhone);
                          return AlertDialog(
                            title: Text('Edit Phone Number'),
                            content: TextField(
                              controller: controller,
                              decoration: InputDecoration(hintText: 'Enter your phone number'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFFF6FCA),
                                ),
                                onPressed: () => Navigator.pop(context, controller.text),
                                child: Text('Save'),
                              ),
                            ],
                          );
                        },
                      );
                      if (result != null && result.trim().isNotEmpty) {
                        await _updateProfileField(phone: result.trim());
                      }
                    },
                  ),
                  _buildProfileField(
                    label: 'Date of Birth',
                    value: _customerDOB ?? '',
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _customerDOB != null && _customerDOB!.isNotEmpty
                            ? DateFormat('yyyy-MM-dd').parse(_customerDOB!)
                            : DateTime(2000, 1, 1),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: Color(0xFFFF6FCA),
                                onPrimary: Colors.white,
                                onSurface: Color(0xFF23242C),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        String dobStr = DateFormat('yyyy-MM-dd').format(picked);
                        await _updateProfileField(dob: dobStr);
                      }
                    },
                  ),
                  _buildProfileField(
                    label: 'Gender',
                    value: _customerGender ?? '',
                    onTap: () async {
                      String? selected = await showModalBottomSheet<String>(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (context) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: Text('Male'),
                                onTap: () => Navigator.pop(context, 'Male'),
                              ),
                              ListTile(
                                title: Text('Female'),
                                onTap: () => Navigator.pop(context, 'Female'),
                              ),
                              ListTile(
                                title: Text('Other'),
                                onTap: () => Navigator.pop(context, 'Other'),
                              ),
                            ],
                          );
                        },
                      );
                      if (selected != null) {
                        await _updateProfileField(gender: selected);
                      }
                    },
                  ),
                  // Removed the Update Profile button here
                ],
              ),
            ),
    );
  }
}