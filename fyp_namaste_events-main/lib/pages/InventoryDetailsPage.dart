import 'package:flutter/material.dart';

class InventoryDetailsPage extends StatelessWidget {
  final Map<String, dynamic> inventory;

  const InventoryDetailsPage({required this.inventory, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inventory Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              inventory['venueName'] ?? "Unknown Venue",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Text("Address: ${inventory['address'] ?? 'N/A'}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),

            Text("Price: ${inventory['price'] ?? 'N/A'}",
                style: const TextStyle(fontSize: 18, color: Colors.green)),
            const SizedBox(height: 10),

            Text("Status: ${inventory['status'] ?? 'Unknown'}",
                style: TextStyle(fontSize: 18, color: inventory['status'] == 'available' ? Colors.green : Colors.red)),
            const SizedBox(height: 10),

            Text("Description:", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(inventory['description'] ?? 'No description available',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),

            Text("Accommodation Details:", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            inventory['accommodation'] != null && inventory['accommodation'] is List
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (inventory['accommodation'] as List)
                  .map((item) => Text(item.toString(), style: const TextStyle(fontSize: 16)))
                  .toList(),
            )
                : const Text("No accommodation details available",
                style: TextStyle(fontSize: 16)),

            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Go Back"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}