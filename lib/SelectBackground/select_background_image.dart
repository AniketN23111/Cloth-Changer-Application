import 'package:flutter/material.dart';

class SelectBackgroundImage extends StatelessWidget {
  final Function(String) onImageSelected;

  SelectBackgroundImage({super.key, required this.onImageSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Background Image'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Change the cross axis count as needed
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
        ),
        itemCount: 15, // Replace with the actual number of images
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Pass the selected image path back to the previous screen
              String imagePath = 'assets/background_images/image${index + 1}.jpg';
              onImageSelected(imagePath);
              Navigator.pop(context);
            },
            child: Card(
              child: Image.asset(
                'assets/background_images/image${index + 1}.jpg',
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}
