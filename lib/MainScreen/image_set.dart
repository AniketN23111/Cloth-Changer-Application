import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../SelectBackground/select_background_image.dart';
import '../SelectDress/select_dress.dart';


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

  Future<void> _downloadImage() async {
    try {
      // Get the directory for storing images
      final exteranlDirectory = await getExternalStorageDirectory();
      if (exteranlDirectory != null) {
        final clothChangerDirectory = Directory('${exteranlDirectory.path}/ClothChanger');
        print(exteranlDirectory);
        print(getDownloadsDirectory());
        // Create the 'ClothChanger' directory if it doesn't exist
        if (!await clothChangerDirectory.exists()) {
          await clothChangerDirectory.create(recursive: true);
        }
        final imagePath = '${clothChangerDirectory.path}/composed_image.png';
        final composedImage = await _composeImages();
        File(imagePath).writeAsBytesSync(composedImage);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image downloaded successfully'),
            backgroundColor: Colors.lightGreen,
          ),
        );
      } else {
        throw 'Failed to get documents directory';
      }
    } catch (e) {
      print('Error downloading image: $e');
    }
  }

  Future<Uint8List> _composeImages() async {
    // Get the bytes of background image
    final backgroundBytes = await rootBundle.load(backgroundImageAsset);
    final backgroundUint8List = backgroundBytes.buffer.asUint8List();

    // Get the bytes of dress image
    final dressBytes = await rootBundle.load(dressImageAsset);
    final dressUint8List = dressBytes.buffer.asUint8List();

    // Compose the images
    final background = await decodeImageFromList(backgroundUint8List);
    final dress = await decodeImageFromList(dressUint8List);
    final croppedImage = await decodeImageFromList(widget.croppedImageData!);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final paint = Paint()..filterQuality = FilterQuality.high;

    // Draw the background image
    canvas.drawImage(background, Offset.zero, paint);

    // Draw the dress image overlay
    canvas.drawImage(dress, Offset.zero, paint);

    // Draw the cropped image overlay
    canvas.drawImage(croppedImage, Offset.zero, paint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(
      background.width,
      background.height,
    );
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image SET'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadImage,
          ),
        ],
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
              alignment: Alignment.bottomCenter,
              fit: BoxFit.scaleDown,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          // Cropped image overlay
          if (widget.croppedImageData != null)
            Positioned.fill(
              child: InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(double.infinity),
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
              icon: const Icon(Icons.person_outline),
              onPressed: () {
                // Navigate to SelectDress screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => select_dress(
                      onDressSelected: selectDress,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.image),
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
