import'package:flutter/material.dart';
import 'package:fyp_namaste_events/services/api.dart';


class CreateData extends StatefulWidget {
  const CreateData({super.key});

  @override
  State<CreateData> createState() => _CreateDataState();
}

class _CreateDataState extends State<CreateData> {

  var venue_name_controller = TextEditingController();
  var venue_price_controller = TextEditingController();
  var venue_image_controller = TextEditingController();
  var venue_rating_controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: venue_name_controller,
              decoration: const InputDecoration(
                hintText: "venue name",
              ),
            ),
            TextField(
              controller: venue_price_controller,
              decoration: const InputDecoration(
                hintText: "venue price",
              ),
            ),

            TextField(
              controller: venue_rating_controller,
              decoration: const InputDecoration(
                hintText: "venue rating",
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(onPressed: (){
              var data={
                "venue_name": venue_name_controller.text,
                "venue_price": venue_price_controller.text,

                "venue_rating": venue_rating_controller.text
              };
              Api.addVenue(data);
            },
                child: Text("Create Data"))
          ],
        )
      ),
    );
  }
}
