import 'package:flutter/material.dart';
import 'package:fyp_namaste_events/pages/home_page.dart';
import 'package:fyp_namaste_events/pages/SignUpPage.dart';
import 'package:fyp_namaste_events/services/Api/api_authentication.dart';
import 'package:fyp_namaste_events/pages/furtherMore_page.dart';
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
  String? selectedRole; // New role selection variable

  void _login() {
    setState(() {
      if (selectedRole == null || selectedRole!.isEmpty) {
        errorMessage = "Please select a role.";
      } else if (_controllerEmail.text.isEmpty || _controllerPassword.text.isEmpty) {
        errorMessage = "Please fill in all fields.";
      } else {
        var data = {
          "email": _controllerEmail.text,
          "password": _controllerPassword.text,
          "role": selectedRole,
        };

        // Call the API and handle the response
        Api.login(data).then((response) {
          if (response != null ) { // imp: if email doesnot exit null is returned
            int statusCode = response["status_code"];
            String role = response["role"];
            // String token = response["cookie"];
            print(role);
            if (statusCode == 200) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Login successful! Welcome."),
                  backgroundColor: Colors.green,
                ),
              );



              if (role == "Admin"){
                print("adminMa");

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const VerificationPage()),
                );
              }else{
                print("useMa");
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              }

            } else {
              setState(() {
                errorMessage = response["message"] ?? "Signup failed. Try again.";
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
  Widget _entryField(String title, TextEditingController controller, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      decoration: InputDecoration(
        labelText: title,
        border: const OutlineInputBorder(),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
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
      decoration: const InputDecoration(
        labelText: 'Select Role',
        border: OutlineInputBorder(),
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
        });
      },
    );
  }

  Widget _registerText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don’t have an account?"),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignUpPage()),
            );
          },
          child: const Text(
            "Join us",
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Welcome back",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '"Turning Plans into Perfect Moments!"',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
                const SizedBox(height: 32),
                _entryField("Email", _controllerEmail),
                const SizedBox(height: 16),
                _entryField("Password", _controllerPassword, isPassword: true),
                const SizedBox(height: 16),
                _roleDropdown(), // Added role dropdown here
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
    );
  }
}
