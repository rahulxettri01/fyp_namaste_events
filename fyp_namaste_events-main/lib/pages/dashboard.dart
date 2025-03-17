import 'package:flutter/material.dart';
import 'package:fyp_namaste_events/pages/login_register_page.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class VendorDashboard extends StatefulWidget {
  final token;
  const VendorDashboard({@required this.token, super.key});

  @override
 _VendorDashboardState createState() =>  _VendorDashboardState();
}
class _VendorDashboardState extends State<VendorDashboard>{
  late String userStatus;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Map<String,dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    userStatus = jwtDecodedToken['status'];
  }

  @override
  Widget build(BuildContext context) {
    if (userStatus == "unverified"){


    return Scaffold(
      appBar: AppBar(
        title: const Text("Vendor Dashboard"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome to the Vendor Dashboard",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Your details are being verified. Please wait for confirmation.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Handle any further actions if needed
              },
              child: const Text("Check Verification Status"),
            ),
          ],
        ),
      ),
    );
    }else{
      return Scaffold(
        appBar: AppBar(
          title: const Text("Vendor Dashboard"),
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () {
                // Implement log out functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Logged out successfully!")),
                );
                // Delay to allow UI update before navigating
                Future.delayed(const Duration(milliseconds: 500), () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                        (route) => false, // Clear navigation stack
                  );
                });
                // You can navigate back to login screen or home page
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome to the Vendor Dashboard",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Vendor Name: ",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                "Venue Name: ",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                "Venue Price: ",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Navigate to a screen to manage the venue
                  // Example: Navigate to edit venue screen
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => const VenueManagementScreen(),
                  //   ),
                  // );
                },
                child: const Text("Manage Venue"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Example: View the booking history of the venue
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => const BookingHistoryScreen(),
                  //   ),
                  // );
                },
                child: const Text("View Booking History"),
              ),
            ],
          ),
        ),
      );
    }
  }
}