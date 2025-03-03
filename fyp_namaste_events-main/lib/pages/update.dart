import 'package:flutter/material.dart';
import 'package:fyp_namaste_events/model/vendor_venue_model.dart';
import 'package:fyp_namaste_events/services/Api/api.dart';
import 'package:fyp_namaste_events/pages/edit.dart';

class UpdateScreen extends StatelessWidget {
  const UpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Operation"),
      ),
      body: FutureBuilder(
        future: Api.getVenue(), // Fetching venue data
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(!snapshot.hasData){
            return const Center(
              child: CircularProgressIndicator(),
            );

          } else {
            List<venue> vdata = snapshot.data!;

            return ListView.builder(
              itemCount: vdata.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: const Icon(Icons.storage),
                  title: Text("${vdata[index].venue_name}"),
                  subtitle: Text("\Rs ${vdata[index].venue_price}"),
                  trailing: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditScreen(data: vdata[index]),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}


