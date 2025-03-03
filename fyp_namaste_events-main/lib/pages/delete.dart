import 'package:flutter/material.dart';
import 'package:fyp_namaste_events/model/vendor_venue_model.dart';
import 'package:fyp_namaste_events/services/api.dart';


class DeleteScreen extends StatefulWidget {
  const DeleteScreen({super.key});

  @override
  State<DeleteScreen> createState() => _DeleteScreenState();
}

class _DeleteScreenState extends State<DeleteScreen> {
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
            List<venue> vdata = snapshot.data;

            return ListView.builder(
              itemCount: vdata.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: const Icon(Icons.storage),
                  title: Text("${vdata[index].venue_name}"),
                  subtitle: Text("\Rs ${vdata[index].venue_price}"),

                  trailing: IconButton(
                    onPressed: () async{
                      await Api.deleteVenue(vdata[index].id!);
                      vdata.removeAt(index);
                      setState(() {

                      });


                    },
                    icon: const Icon(Icons.delete),
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
