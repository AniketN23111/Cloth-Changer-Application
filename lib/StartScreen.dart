import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker package

import 'CropImage/CropSample.dart';

class StartScreen extends StatefulWidget {

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
              child:  Text('Gallery',style: TextStyle(color: Colors.white,fontSize: 20)),
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
                      builder: (context) => CropSample(image: pickedFile.path),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}