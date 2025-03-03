import 'package:fyp_namaste_events/services/Api/api_signup.dart';
import 'package:flutter/material.dart';

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
  String? selectedRole ;
  String? errorMessage = '';

  void _signUp() {
    setState(() {

      if (controllerPassword.text != controllerConfirmPassword.text) {
        errorMessage = "Passwords do not match.";
      } else {
        var data={
          "userName": controllerName.text,
          "email": controllerEmail.text,
          "phone": controllerPhone.text,
          "password": controllerPassword.text,
          "role": selectedRole,
        };
        Api.signup(data);      }
    });
  }

  Widget _entryField(String title, TextEditingController controller,
      {bool isPassword = false, bool isConfirmPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: (isPassword && !isPasswordVisible) || (isConfirmPassword && !isConfirmPasswordVisible),
      decoration: InputDecoration(
        labelText: title,
        border: const OutlineInputBorder(),
        suffixIcon: isPassword || isConfirmPassword
            ? IconButton(
          icon: Icon(
            (isPassword && isPasswordVisible) || (isConfirmPassword && isConfirmPasswordVisible)
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
      value: selectedRole != null && selectedRole!.isNotEmpty ? selectedRole : null, // Ensure it's null initially
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
          onPressed: () {},
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
                _termsAndConditions(),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _signUp,
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
                if (errorMessage != null && errorMessage!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
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
                      onPressed: () {},
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(Icons.facebook, size: 40),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _loginText(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



