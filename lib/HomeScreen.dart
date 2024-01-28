// ignore_for_file: use_build_context_synchronously, file_names

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:project3/TextScanner.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showInstructions = false;
  Color backgroundColor = Colors.grey[200]!;
  Color textColor = Colors.black;
  String? imagePath; // Variable pour stocker le chemin de l'image

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TextScanner(imagePath: imagePath),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Welcolme in ScanTextBy Osk',
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  color: backgroundColor == Colors.black
                      ? Colors.white
                      : textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showInstructions = !showInstructions;
                      });
                    },
                    child: Icon(showInstructions ? Icons.remove : Icons.add),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    'Comment utiliser l\'application',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: backgroundColor == Colors.black
                          ? Colors.white
                          : textColor,
                    ),
                  ),
                ],
              ),
              if (showInstructions)
                Column(
                  children: [
                    const SizedBox(height: 12.0),
                    Text(
                      '1-Ouvrir la caméra et Scanner le texte',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                        color: showInstructions
                            ? const Color.fromARGB(209, 0, 17, 255)
                            : textColor,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      '2-Importer une photo depuis la gallerie',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                        color: showInstructions
                            ? const Color.fromARGB(209, 0, 17, 255)
                            : textColor,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TextScanner(),
                    ),
                  );
                },
                child: const Text('Ouverture de la caméra'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _showColorPicker,
                child: const Text('Background-color'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _pickImageFromGallery,
                child: const Text('Galerie'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showColorPicker() async {
    final List<Color> allowedColors = [
      Colors.yellow,
      Colors.red,
      Colors.green,
      Colors.black
    ];

    final selectedColor = await showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sélectionner un arrière-plan'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: backgroundColor,
              onColorChanged: (Color color) {
                Navigator.of(context).pop(color);
              },
              availableColors: allowedColors,
            ),
          ),
        );
      },
    );

    if (selectedColor != null && allowedColors.contains(selectedColor)) {
      setState(() {
        backgroundColor = selectedColor;
        textColor =
            backgroundColor == Colors.black ? Colors.white : Colors.black;
      });
    }
  }
}
