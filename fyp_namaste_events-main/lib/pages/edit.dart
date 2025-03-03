import 'package:flutter/material.dart';
import 'package:fyp_namaste_events/model/vendor_venue_model.dart';
import 'package:fyp_namaste_events/services/api.dart';

class EditScreen extends StatefulWidget {
  final venue data;
  const EditScreen({super.key, required this.data});

  @override
  State<EditScreen> createState() => _EditScreenState();
}
 class _EditScreenState extends State<EditScreen>{

  var nameController = TextEditingController();
  var priceController = TextEditingController();
  var ratingController = TextEditingController();

  @override
  void initState(){
    super.initState();
    nameController.text = widget.data.venue_name.toString();
    priceController.text= widget.data.venue_price.toString();
    ratingController.text= widget.data.venue_rating.toString();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: "Name here",
              ),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                hintText: "price here",
              ),
            ),
            TextField(
              controller: ratingController,
              decoration: const InputDecoration(
                hintText: "rating here",
              ),
            ),
            const SizedBox(
              height:20,
            ),
            ElevatedButton(onPressed: (){

              Api.updateVenue(widget.data.id!,{
                "venue_name": nameController.text,
                "venue_price": priceController.text,
                "venue_rating": ratingController.text,
                "id": widget.data.id,

              });
            }, child: const Text("Update Data"))
          ],
        ),
      ),

    );
  }


 }
