// import 'package:flutter/material.dart';
//
// import 'package:firebase_core/firebase_core.dart'; // Import Firebase
// import 'package:fyp_namaste_events/splash screen/splashScreen.dart'; // Import the SplashScreen widget
// import 'package:fyp_namaste_events/pages/admin_panel.dart';
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//  await Firebase.initializeApp(); // Initialize Firebase
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const (), // Set SplashScreen as the first screen
//     );
//   }
// }
import 'package:flutter/material.dart';

import 'package:fyp_namaste_events/pages/SignUpPage.dart'; // Import the SignUpPage widget

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SignUpPage(), // Set SignUpPage as the first screen
    );
  }
}
