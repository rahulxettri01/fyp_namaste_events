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
import 'package:fyp_namaste_events/pages/AddInventory.dart';

import 'package:fyp_namaste_events/pages/SignUpPage.dart';
import 'package:fyp_namaste_events/pages/login_register_page.dart';
import 'package:fyp_namaste_events/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import the SignUpPage widget

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => UserProvider()),
    ],
    child:  MyApp(token: prefs.getString('FrontToken'),),
  ),
  );
}

class MyApp extends StatelessWidget {
  final token;
  const MyApp({@required this.token,Key? key}) : super( key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(), // Set SignUpPage as the first screen
    );
  }
}
