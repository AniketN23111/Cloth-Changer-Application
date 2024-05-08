import 'package:flutter/material.dart';

class SelectDress extends StatelessWidget {
  final Function(String) onDressSelected;

  SelectDress({super.key, required this.onDressSelected});

  final List<String> dressImages = [
    'assets/dress_images/dress1.png',
    'assets/dress_images/dress2.png',
    'assets/dress_images/dress3.png',
    'assets/dress_images/dress4.png',
    'assets/dress_images/dress5.png',
    'assets/dress_images/dress7.png',
    'assets/dress_images/dress6.png',
    'assets/dress_images/dress8.png',
    // Add more dress images as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Dress'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: dressImages.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              onDressSelected(dressImages[index]);
              Navigator.pop(context); // Navigate back to NextScreen
            },
            child: Image.asset(
              dressImages[index],
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}
