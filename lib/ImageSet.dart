import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'SelectBackgroundImage.dart';
import 'SelectDress.dart';

class ImageSet extends StatefulWidget {
  final Uint8List? croppedImageData;
  final String backgroundImage;

  ImageSet({required this.backgroundImage, required this.croppedImageData});

  @override
  _ImageSetState createState() => _ImageSetState();
}

class _ImageSetState extends State<ImageSet> {
  String backgroundImageAsset =
      'assets/background_images/image1.jpg'; // Default background image
  String dressImageAsset = 'assets/dress_images/dress1.png'; // Default dress image

  void changeBackgroundImage(String imagePath) {
    setState(() {
      backgroundImageAsset = imagePath;
    });
  }

  void selectDress(String imagePath) {
    setState(() {
      dressImageAsset = imagePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image SET'),
      ),
      body: Stack(
        children: [
          // Background image
          Image.asset(
            backgroundImageAsset,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Dress image overlay
          Positioned.fill(
            child: Image.asset(
              dressImageAsset,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          // Cropped image overlay
          if (widget.croppedImageData != null)
            Positioned.fill(
              child: InteractiveViewer(
                boundaryMargin: EdgeInsets.all(double.infinity),
                minScale: 0.1,
                maxScale: 4.0,
                child: Image.memory(widget.croppedImageData!),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.person_outline),
              onPressed: () {
                // Navigate to SelectDress screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectDress(
                      onDressSelected: selectDress,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.image),
              onPressed: () {
                // Navigate to SelectBackgroundImage screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectBackgroundImage(
                      onImageSelected: changeBackgroundImage,
                    ),
                  ),
                );
              },
            ),
            // Add other buttons as needed
          ],
        ),
      ),
    );
  }
}
