import 'dart:ui';
import 'package:fyp_namaste_events/services/Api/api_authentication.dart';
import 'package:flutter/material.dart';
import 'package:fyp_namaste_events/pages/login_register_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  var controllerName = TextEditingController();
  var controllerEmail = TextEditingController();
  var controllerPhone = TextEditingController();
  var controllerPassword = TextEditingController();
  var controllerConfirmPassword = TextEditingController();
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isTermsAccepted = false;
  String? selectedRole;
  String? selectedVendorType;
  String? errorMessage = '';

  void _signUp() {
    setState(() {
      errorMessage = '';

      if (controllerPassword.text != controllerConfirmPassword.text) {
        errorMessage = "Passwords do not match.";
      } else if (!isTermsAccepted) {
        errorMessage = "You must accept the Terms of Service.";
      } else if (selectedRole == null || selectedRole!.isEmpty) {
        errorMessage = "Please select a role.";
      } else {
        var data = {
          "userName": controllerName.text,
          "email": controllerEmail.text,
          "phone": controllerPhone.text,
          "password": controllerPassword.text,
          "role": selectedRole,
          "vendorType": selectedRole == "Admin" ? selectedVendorType : null,
        };

        // Call the API and handle the response
        Api.signup(data).then((response) {
          if (response != null) {
            int statusCode = response["status_code"];

            if (statusCode == 200) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Signup successful! Please log in."),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            } else {
              setState(() {
                errorMessage = "Signup failed. Try again.";
              });
            }
          } else {
            setState(() {
              errorMessage = "Unexpected response from server.";
            });
          }
        }).catchError((error) {
          setState(() {
            errorMessage = "Error occurred: ${error.toString()}";
          });
        });
      }
    });
  }

  Widget _entryField(String title, TextEditingController controller,
      {bool isPassword = false, bool isConfirmPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: (isPassword && !isPasswordVisible) ||
          (isConfirmPassword && !isConfirmPasswordVisible),
      decoration: InputDecoration(
        labelText: title,
        border: const OutlineInputBorder(),
        fillColor: Colors.white.withOpacity(0.8),
        filled: true,
        prefixIcon: Icon(
          isPassword || isConfirmPassword ? Icons.lock : 
          title == "Email" ? Icons.email :
          title == "Name" ? Icons.person :
          title == "Phone Number" ? Icons.phone : 
          Icons.text_fields,
          color: Colors.grey,
        ),
        suffixIcon: isPassword || isConfirmPassword
            ? IconButton(
          icon: Icon(
            (isPassword && isPasswordVisible) ||
                (isConfirmPassword && isConfirmPasswordVisible)
                ? Icons.visibility
                : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              if (isPassword) {
                isPasswordVisible = !isPasswordVisible;
              } else {
                isConfirmPasswordVisible = !isConfirmPasswordVisible;
              }
            });
          },
        )
            : null,
      ),
    );
  }

  Widget _roleDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedRole,
      decoration: const InputDecoration(
        labelText: 'Select Role',
        border: OutlineInputBorder(),
        fillColor: Colors.white70,
        filled: true,
      ),
      items: ['User', 'Admin'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedRole = newValue;
          selectedVendorType = null;
        });
      },
    );
  }

  Widget _vendorTypeDropdown() {
    return selectedRole == "Admin"
        ? DropdownButtonFormField<String>(
      value: selectedVendorType,
      decoration: const InputDecoration(
        labelText: 'Select Vendor Type',
        border: OutlineInputBorder(),
        fillColor: Colors.white70,
        filled: true,
        prefixIcon: Icon(
          Icons.business,
          color: Colors.grey,
        ),
      ),
      items: ['Venue', 'Decoration', 'Photography'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedVendorType = newValue;
        });
      },
    )
        : Container();
  }

  Widget _termsAndConditions() {
    return Row(
      children: [
        Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: isTermsAccepted,
            onChanged: (value) {
              setState(() {
                isTermsAccepted = value!;
              });
            },
            activeColor: Colors.black,
            checkColor: Colors.white,
          ),
        ),
        const Flexible(
          child: Text(
            "I agree with the Terms of Service & Privacy Policy",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _loginText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Have an account?"),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
          child: const Text(
            "Log in",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Image.asset(
              'assets/login.JPG',
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
            ),
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.3))
            ),
            Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Join us to start searching",
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '"Turning Plans into Perfect Moments!"',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          _entryField("Name", controllerName),
                          const SizedBox(height: 16),
                          _entryField("Email", controllerEmail),
                          const SizedBox(height: 16),
                          _entryField("Phone Number", controllerPhone),
                          const SizedBox(height: 16),
                          _entryField("Password", controllerPassword, isPassword: true),
                          const SizedBox(height: 16),
                          _entryField("Confirm Password", controllerConfirmPassword, isConfirmPassword: true),
                          const SizedBox(height: 16),
                          _roleDropdown(),
                          const SizedBox(height: 16),
                          _vendorTypeDropdown(),
                          const SizedBox(height: 16),
                          _termsAndConditions(),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Sign up',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _loginText(),
                          if (errorMessage != null && errorMessage!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}