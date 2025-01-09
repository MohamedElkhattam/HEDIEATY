import 'package:flutter/material.dart';

class GiftImage extends StatefulWidget {
  const GiftImage({super.key, required this.onImageSelected});

  // Callback to return the selected image path
  final Function(String imagePath) onImageSelected;

  @override
  State<GiftImage> createState() => _GiftImageState();
}

class _GiftImageState extends State<GiftImage> {
  String? selectedImagePath;

  final List<String> _imagePaths = [
    'assets/images/iphone.png',
    'assets/images/redbull.png',
    'assets/images/laptop.jpg'
  ];
  // final List<String> _iconPaths = [
  //   'assets/images/female-avatar.png',
  //   'assets/images/male-avatar.png',
  // ];

  void _showImagePicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose an Image'),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _imagePaths.length,
              itemBuilder: (context, index) {
                final imagePath = _imagePaths[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedImagePath = imagePath;
                    });
                    widget.onImageSelected(imagePath);
                    Navigator.pop(context);
                  },
                  child: Image.asset(imagePath, fit: BoxFit.cover),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _showImagePicker,
          icon: const Icon(Icons.add_photo_alternate),
          label: const Text('Add Photo'),
        ),
      ],
    );
  }
}
