// import'package:flutter/material.dart';
// import'package:firebase_auth/firebase_auth.dart';
//
//
// import 'package:fyp_namaste_events/pages/home_page.dart'; // Import the HomePage
// import 'package:fyp_namaste_events/pages/SignUpPage.dart';
// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});
//
//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController _controllerEmail = TextEditingController();
//   final TextEditingController _controllerPassword = TextEditingController();
//   String? errorMessage = '';
//   bool isPasswordVisible = false;
//
//   // Future<void> signInWithEmailAndPassword() async {
//   //   try {
//   //     await Auth().signInWithEmailAndPassword(
//   //       email: _controllerEmail.text,
//   //       password: _controllerPassword.text,
//   //     );
//   //     // Navigate to HomePage on successful login
//   //     Navigator.pushReplacement(
//   //       context,
//   //       MaterialPageRoute(builder: (context) => HomePage()),
//   //     );
//   //   } on FirebaseAuthException catch (e) {
//   //     setState(() {
//   //       errorMessage = e.message;
//   //     });
//   //   }
//   // }
//
//   Widget _entryField(String title, TextEditingController controller,
//       {bool isPassword = false}) {
//     return TextField(
//       controller: controller,
//       obscureText: isPassword && !isPasswordVisible,
//       decoration: InputDecoration(
//         labelText: title,
//         border: const OutlineInputBorder(),
//         suffixIcon: isPassword
//             ? IconButton(
//           icon: Icon(
//             isPasswordVisible ? Icons.visibility : Icons.visibility_off,
//           ),
//           onPressed: () {
//             setState(() {
//               isPasswordVisible = !isPasswordVisible;
//             });
//           },
//         )
//             : null,
//       ),
//     );
//   }
//
//   Widget _registerText() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const Text("Don’t have an account?"),
//         TextButton(
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const SignUpPage()),
//             );
//           },
//           child: const Text(
//             "Join us",
//             style: TextStyle(color: Colors.blue),
//           ),
//         ),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const Text(
//                   "Welcome back",
//                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//                 const Text(
//                   '"Turning Plans into Perfect Moments!"',
//                   style: TextStyle(fontSize: 16, color: Colors.blue),
//                 ),
//                 const SizedBox(height: 32),
//                 _entryField("Email", _controllerEmail),
//                 const SizedBox(height: 16),
//                 _entryField("Password", _controllerPassword, isPassword: true),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: signInWithEmailAndPassword,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.purple,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: const Text(
//                     'Log in',
//                     style: TextStyle(fontSize: 16, color: Colors.white),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 _registerText(),
//                 if (errorMessage != null && errorMessage!.isNotEmpty)
//                   Text(
//                     errorMessage!,
//                     style: const TextStyle(color: Colors.red),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
