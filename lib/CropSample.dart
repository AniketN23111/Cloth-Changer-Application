import 'dart:io';
import 'dart:typed_data';
import 'package:cloth_changer/CroppedImagePage.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class CropSample extends StatefulWidget {
  final String image;

  CropSample({required this.image});

  @override
  _CropSampleState createState() => _CropSampleState();
}

class _CropSampleState extends State<CropSample> {
  final _cropController = CropController();
  Uint8List? _imageData;

  bool _isCropping = false;
  bool _isCircleUi = false;
  Uint8List? _croppedData;
  String _statusText = '';

  @override
  void initState() {
    super.initState();
    // Load the image data when the widget initializes
    _loadImage();
  }

  // Load the image data from the provided path
  void _loadImage() async {
    final data = await _loadImageData(widget.image);
    setState(() {
      _imageData = data;
    });
  }
  // Load image data from path and resize to 400x600
  Future<Uint8List?> _loadImageData(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final decodedImage = img.decodeImage(bytes);
        final resizedImage = img.copyResize(decodedImage!, width: 800, height: 800);
        return Uint8List.fromList(img.encodePng(resizedImage));
      } else {
        print('File does not exist at the provided path: $path');
        return null;
      }
    } catch (e) {
      print('Error loading image data: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crop Image'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 20),
              if (_imageData != null)
                Expanded(
                  child: Crop(
                    controller: _cropController,
                    image: _imageData!,
                    onCropped: (croppedData) {
                      setState(() {
                        _croppedData = croppedData;
                        _isCropping = false;
                      });

                      // Navigate to the new page with the cropped image
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CroppedImagePage(croppedImageData: croppedData),
                        ),
                      );
                    },
                    withCircleUi: _isCircleUi,
                    onStatusChanged: (status) {
                      setState(() {
                        _statusText = status.toString();
                      });
                    },
                    initialSize: 0.5,
                    cornerDotBuilder: (size, edgeAlignment) =>
                        SizedBox.shrink(),
                    interactive: true,
                    fixCropRect: true,
                    radius: 20,
                  ),
                ),
              SizedBox(height: 20),
              if (_imageData != null && _croppedData == null)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isCropping = true;
                    });
                    _isCircleUi ? _cropController.cropCircle() : _cropController.crop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text('CROP IT!'),
                  ),
                ),
              SizedBox(height: 20),
              Text(_statusText),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
