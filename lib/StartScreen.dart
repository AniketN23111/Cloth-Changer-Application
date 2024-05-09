import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker package

import 'CropImage/crop_sample.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});


  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  String dressImageAsset = 'assets/dress_images/dress1.png'; // Default dress image

  void selectDress(String imagePath) {
    setState(() {
      dressImageAsset = imagePath;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
          textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontStyle: FontStyle.normal),
        ),
              onPressed: () async {
                final picker = ImagePicker();
                final pickedFile = await picker.pickImage(
                    source: ImageSource.gallery);

                if (pickedFile != null) {
                  // Pass selected image to CropSample
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => crop_Sample(image: pickedFile.path),
                    ),
                  );
                }
              },
              child:  const Text('Gallery',style: TextStyle(color: Colors.white,fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}