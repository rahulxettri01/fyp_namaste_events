import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fyp_namaste_events/pages/dashboardVenue.dart';
import 'package:fyp_namaste_events/pages/home_page.dart';
import 'package:fyp_namaste_events/pages/SignUpPage.dart';
import 'package:fyp_namaste_events/pages/furtherMore_page.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:fyp_namaste_events/services/Api/api_authentication.dart';
import 'package:fyp_namaste_events/pages/AdminDahboardPage.dart';

import 'otp/VerifyOTPPage.dart';
import 'otp/ForgotPasswordOTPPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  String? errorMessage = '';
  bool isPasswordVisible = false;
  String? selectedRole;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  void _login() {
    setState(() {
      if (selectedRole == null || selectedRole!.isEmpty) {
        errorMessage = "Please select a role.";
      } else if (_controllerEmail.text.isEmpty ||
          _controllerPassword.text.isEmpty) {
        errorMessage = "Please fill in all fields.";
      } else {
        var data = {
          "email": _controllerEmail.text,
          "password": _controllerPassword.text,
          "role": selectedRole,
        };

        if (selectedRole == "Super Admin") {
          Api.loginAdmin(data).then((response) {
            print("responseeee");
            print(response);
            if (response != null) {
              int statusCode = response["status_code"];
              var newToken = response["token"];
              if (statusCode == 200) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Login successful! Welcome."),
                    backgroundColor: Colors.green,
                  ),
                );

                prefs.setString("FrontToken", newToken);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AdminDashboardPage(token: newToken)),
                );
              } else {
                setState(() {
                  errorMessage =
                      response["message"] ?? "Login failed. Try again.";
                });
              }
            }
          });
        } else {
          // Call the API and handle the response
          Api.login(data).then((response) {
            if (response != null) {
              // imp: if email does not exist null is returned
              int statusCode = response["status_code"];
              print("roleeee");
              String role = response["role"];
              var newToken = response["token"];
              print(newToken);
              if (statusCode == 200) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Login successful! Welcome."),
                    backgroundColor: Colors.green,
                  ),
                );

                prefs.setString("FrontToken", newToken);
                if (role == "Admin") {
                  print("adminMa");
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            VerificationPage(token: newToken)),
                  );
                } else if (role == "Super Admin") {
                  print("superAdminMa");
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AdminDashboardPage(token: newToken)),
                  );
                } else {
                  print("useMa");
                  print(response);
                  if (response["status"] == "unverified") {
                    print("verifyOTP red");
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VerifyOTPPage(
                          userId: response['userId'].toString(),
                          email: response['email'],
                          // token: newToken, // Pass the token to VerifyOTPPage
                        ),
                      ),
                    );
                  } else if (response["status"] == "verified") {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  }
                }
              } else {
                setState(() {
                  errorMessage =
                      response["message"] ?? "Login failed. Try again.";
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
      }
    });
  }

  Widget _entryField(String title, TextEditingController controller,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      decoration: InputDecoration(
        labelText: title,
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15.0), // Increased circular radius
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: const BorderSide(color: Colors.black),
        ),
        fillColor: Colors.white, // Full white background
        filled: true,
        prefixIcon: Icon(
          isPassword ? Icons.lock : Icons.email,
          color: Colors.grey,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(isPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
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
      decoration: InputDecoration(
        labelText: 'Select Role',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: const BorderSide(color: Colors.black),
        ),
        fillColor: Colors.white,
        filled: true,
        prefixIcon: const Icon(
          Icons.person_outline,
          color: Colors.grey,
        ),
      ),
      items: ['User', 'Admin', 'Super Admin'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedRole = newValue;
        });
      },
    );
  }

  Widget _registerText() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Don't have an account?",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpPage()),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              ),
              child: const Text(
                "Join us",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        // Forgot Password button
        TextButton(
          onPressed: () {
            _showForgotPasswordDialog();
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          ),
          child: const Text(
            "Forgot Password?",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  // Add forgot password dialog
  void _showForgotPasswordDialog() {
    final TextEditingController emailController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text("Reset Password"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Enter your email address and we'll send you a OTP to reset your password.",
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        Navigator.of(context).pop();
                      },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                ),
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (emailController.text.isNotEmpty) {
                          // Show loading indicator
                          setState(() {
                            isLoading = true;
                          });

                          // Simulate a delay
                          await Future.delayed(const Duration(seconds: 1));

                          // Hide dialog and navigate to OTP verification page
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgotPasswordOTPPage(
                                email: emailController.text,
                                userId: "123", // Placeholder user ID
                              ),
                            ),
                          );
                        } else {
                          // Show error for empty email
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please enter your email address"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.0,
                        ),
                      )
                    : const Text(
                        "Send Reset OTP",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          Image.asset(
            'assets/login.JPG',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.3))),
          Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                "Welcome back",
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
                        _entryField("Email", _controllerEmail),
                        const SizedBox(height: 16),
                        _entryField("Password", _controllerPassword,
                            isPassword: true),
                        const SizedBox(height: 16),
                        _roleDropdown(),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text(
                            'Log in',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        if (errorMessage != null && errorMessage!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        const SizedBox(height: 16),
                        _registerText(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
