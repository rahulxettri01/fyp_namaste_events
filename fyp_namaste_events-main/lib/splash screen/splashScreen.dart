// import 'package:flutter/material.dart';
// import 'package:fyp_namaste_events/pages/login_register_page.dart'; // Import your LoginPage widget
// import 'package:fyp_namaste_events/pages/home_page.dart'; // Import your HomePage widget
// import 'package:firebase_auth/firebase_auth.dart';  // Import Firebase Auth
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({Key? key}) : super(key: key);
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _checkAuthStatus();
//   }
//
//   // Check the user's authentication status after a brief delay (for splash screen effect)
//   Future<void> _checkAuthStatus() async {
//     await Future.delayed(const Duration(seconds: 3)); // Show splash screen for 3 seconds
//
//     // Check if the user is logged in
//     if (FirebaseAuth.instance.currentUser != null) {
//       // If the user is logged in, navigate to the HomePage
//       Navigator.pushReplacement(context,
//         MaterialPageRoute(builder: (context) => const HomePage()),
//       );
//     } else {
//       // If the user is not logged in, navigate to the LoginPage
//       Navigator.pushReplacement(context,
//         MaterialPageRoute(builder: (context) => const LoginPage()),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.blue, // You can change the background color as per your choice
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: const [
//             Icon(
//               Icons.event, // You can use any icon or image for the splash screen
//               size: 100,
//               color: Colors.white,
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Welcome to Namaste Events',
//               style: TextStyle(
//                 fontSize: 24,
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
