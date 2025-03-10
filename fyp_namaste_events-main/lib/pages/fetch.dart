import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fyp_namaste_events/model/vendor_venue_model.dart';
import 'package:fyp_namaste_events/services/Api/api_venue_vendor.dart';

class FetchData extends StatelessWidget {
  const FetchData({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
    body: FutureBuilder(
    future: Api.getVenue(),
    builder: (BuildContext context, AsyncSnapshot snapshot) {
    if (!snapshot.hasData) {
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
    trailing: Text(" ${vdata[index].venue_rating}"),
    );
    },
    );
    }
    },
    ),



    );
}
}
