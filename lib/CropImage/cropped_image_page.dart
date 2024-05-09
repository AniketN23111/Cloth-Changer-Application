import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;


import 'package:flutter/material.dart';

import '../MainScreen/image_set.dart';

class CroppedImagePage extends StatefulWidget {
  final Uint8List? croppedImageData;

  CroppedImagePage({required this.croppedImageData});

  @override
  _CroppedImagePageState createState() => _CroppedImagePageState();
}

class _CroppedImagePageState extends State<CroppedImagePage> {
  List<Offset> _points = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Image'),
      ),
      body: Center(
        child: RepaintBoundary(
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _points.add(details.localPosition);
              });
            },
            onPanEnd: (details) {
              setState(() {
                _points.add(const Offset(-1, -1)); // To separate the points
              });
            },
            child: Stack(
              children: [
                Image.memory(
                  widget.croppedImageData ?? Uint8List(0), // Use a placeholder if croppedImageData is null
                ),
                CustomPaint(
                  painter: CropOutlinePainter(points: _points),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Crop the image based on the drawn outline
          _cropImage();
        },
        child: const Icon(Icons.crop),
      ),
    );
  }

  void _cropImage() async {
    if (_points.length < 3) {
      // Need at least 3 points to create a closed polygon
      return;
    }

    // Convert points to a Path
    Path path = Path();
    path.moveTo(_points.first.dx, _points.first.dy);
    for (int i = 1; i < _points.length; i++) {
      if (_points[i] == const Offset(-1, -1)) {
        // End of drawing
        break;
      }
      path.lineTo(_points[i].dx, _points[i].dy);
    }
    path.close();

    // Get image size
    final image = await loadImage(widget.croppedImageData);
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());

    // Create cropped image
    ui.Image croppedImage = await cropImage(image, path, imageSize);

    // Convert ui.Image to Uint8List
    ByteData? byteData = await croppedImage.toByteData(format: ui.ImageByteFormat.png);
    Uint8List? croppedBytes = byteData?.buffer.asUint8List();

    // Display cropped image
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cropped Image'),
        content: Image.memory(croppedBytes!),
        actions: [
          TextButton(
            onPressed: () {
              // Try again
              setState(() {
                _points.clear(); // Clear the points
              });
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Try Again'),
          ),
          TextButton(
            onPressed: () {
              // Done
              Navigator.of(context).pop(); // Close the dialog
              // Navigate to the next screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageSet(croppedImageData: croppedBytes, backgroundImage: 'assets/background_images/image1.jpg',),
                ),
              );
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<ui.Image> loadImage(Uint8List? imageData) async {
    final Completer<ui.Image> completer = Completer();
    final image = MemoryImage(imageData!);
    final listener = ImageStreamListener((info, _) async {
      final ui.Image img = info.image;
      completer.complete(img);
    });
    final ImageStream stream = image.resolve(const ImageConfiguration());
    stream.addListener(listener);
    return completer.future;
  }

  Future<ui.Image> cropImage(ui.Image image, Path path, Size size) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    // Create a paint object for drawing the image
    final paint = Paint()..filterQuality = FilterQuality.high;

    // Draw the path as a mask
    canvas.drawPath(path, Paint()..color = Colors.black);

    // Clip the canvas with the path
    canvas.clipPath(path);

    // Calculate scale factor for downsampling
    final double scaleFactor = min(size.width / image.width, size.height / image.height);

    // Draw the original image on the clipped canvas with downsampling
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );

    // End recording and get the cropped image
    final picture = pictureRecorder.endRecording();
    final croppedImage = await picture.toImage(size.width.toInt(), size.height.toInt());

    return croppedImage;
  }


}
class CropOutlinePainter extends CustomPainter {
  final List<Offset> points;

  CropOutlinePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    // Draw solid lines
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != const Offset(-1, -1) && points[i + 1] != const Offset(-1, -1)) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}