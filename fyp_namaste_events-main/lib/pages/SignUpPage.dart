import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_namaste_events/auth/auth.dart';
import 'package:fyp_namaste_events/pages/login_register_page.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  bool isPasswordVisible = false;
  bool isTermsAccepted = false;
  String? errorMessage = '';
  String? selectedRole;

  Future<void> createUserWithEmailAndPassword() async {
    if (!isTermsAccepted) {
      setState(() {
        errorMessage = "Please accept the terms and conditions.";
      });
      return;
    }
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
      // Redirect to LoginPage after successful sign-up
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _entryField(String title, TextEditingController controller,
      {bool isPassword = false}) {
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
      items: <String>['User', 'Admin', 'Guest'].map((String value) {
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

  Widget _termsAndConditions() {
    return Row(
      children: [
        Checkbox(
          value: isTermsAccepted,
          onChanged: (value) {
            setState(() {
              isTermsAccepted = value!;
            });
          },
        ),
        const Flexible(
          child: Text(
            "I agree with the Terms of Service & Privacy Policy",
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
                  "Join us to start searching",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '"Turning Plans into Perfect Moments!"',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
                const SizedBox(height: 16),
                _entryField("Name", _controllerName),
                const SizedBox(height: 16),
                _entryField("Email", _controllerEmail),
                const SizedBox(height: 16),
                _entryField("Password", _controllerPassword, isPassword: true),
                const SizedBox(height: 16),
                _roleDropdown(),
                const SizedBox(height: 16),
                _termsAndConditions(),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: createUserWithEmailAndPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
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
                const Text("Or sign up with"),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.g_mobiledata, size: 40),
                      onPressed: () {
                        // Handle Google sign-up
                      },
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(Icons.facebook, size: 40),
                      onPressed: () {
                        // Handle Facebook sign-up
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _loginText(),
                if (errorMessage != null && errorMessage!.isNotEmpty)
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}