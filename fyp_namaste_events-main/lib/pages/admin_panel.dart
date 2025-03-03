import 'package:flutter/material.dart';
import 'package:fyp_namaste_events/pages/create.dart';
import 'package:fyp_namaste_events/pages/fetch.dart';
import 'package:fyp_namaste_events/pages/update.dart';
import 'package:fyp_namaste_events/pages/delete.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Panel")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to CreateData page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateData()),
                );
              },
              child: const Text("Create"),
            ),
            ElevatedButton(onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> const FetchData()));
            }, child: const Text("READ")),
            ElevatedButton(onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> const UpdateScreen()));
            }, child: const Text("Update")),
            ElevatedButton(onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> const DeleteScreen()));
            }, child: const Text("Delete")),
          ],
        ),
      ),
    );
  }
}
