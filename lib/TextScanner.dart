
// ignore_for_file: use_build_context_synchronously, file_names

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project3/ResultScreen.dart';
import 'package:easy_localization/easy_localization.dart';

class TextScanner extends StatefulWidget {
  final String? imagePath;

  const TextScanner({Key? key, this.imagePath}) : super(key: key);

  @override
  State<TextScanner> createState() => _TextScannerState();
}

class _TextScannerState extends State<TextScanner> with WidgetsBindingObserver {
  bool isPermissionGranted = false;
  late final Future<void> future;

  // Pour contrôler la caméra
  CameraController? cameraController;
  final textRecogniser = TextRecognizer();

  @override
  void initState() {
    super.initState();
    // Pour afficher le flux de la caméra, nous devons ajouter WidgetsBindingObserver.
    WidgetsBinding.instance.addObserver(this);
    future = requestCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    stopCamera();
    textRecogniser.close();
    super.dispose();
  }

  // Il vérifiera si l'application est au premier plan ou en arrière-plan
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      stopCamera();
    } else if (state == AppLifecycleState.resumed &&
        cameraController != null &&
        cameraController!.value.isInitialized) {
      startCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        return Stack(
          children: [
            // Afficher le contenu de la caméra 
            if (isPermissionGranted)
              FutureBuilder<List<CameraDescription>>(
                future: availableCameras(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    initCameraController(snapshot.data!);
                    return Center(
                      child: CameraPreview(cameraController!),
                    );
                  } else {
                    return const LinearProgressIndicator();
                  }
                },
              ),
            Scaffold(
              appBar: AppBar(
                title: const Text('Reconnaissance du texte').tr(),
              ),
              backgroundColor:
                  isPermissionGranted ? Colors.transparent : null,
              body: isPermissionGranted
                  ? Column(
                      children: [
                        Expanded(child: Container()),
                        Container(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: ElevatedButton(
                            onPressed: () {
                              scanImage();
                            },
                            child: const Text('Scanner le texte').tr(),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Container(
                        padding:
                            const EdgeInsets.only(left: 24.0, right: 24.0),
                        child: const Text(
                          'Autorisation de caméra refusée',
                          textAlign: TextAlign.center,
                        ).tr(),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Future<void> requestCameraPermission() async {
    final status = await Permission.camera.request();
    isPermissionGranted = status == PermissionStatus.granted;
  }

  // Il est utilisé pour initialiser le contrôleur de la caméra
  // Il vérifie également les caméras disponibles sur votre appareil
  // Il vérifie également si le contrôleur de la caméra est initialisé ou non.
  void initCameraController(List<CameraDescription> cameras) {
    if (cameraController != null) {
      return;
    }
    // Sélectionner la première caméra arrière
    CameraDescription? camera;
    for (var a = 0; a < cameras.length; a++) {
      final CameraDescription current = cameras[a];
      if (current.lensDirection == CameraLensDirection.back) {
        camera = current;
        break;
      }
    }
    if (camera != null) {
      cameraSelected(camera);
    }
  }

  Future<void> cameraSelected(CameraDescription camera) async {
    cameraController =
        CameraController(camera, ResolutionPreset.max, enableAudio: false);
    await cameraController?.initialize();
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  // Démarrer la caméra
  void startCamera() {
    if (cameraController != null) {
      cameraSelected(cameraController!.description);
    }
  }

  // Arrêter la caméra
  void stopCamera() {
    if (cameraController != null) {
      cameraController?.dispose();
    }
  }

  // Il prend en charge la numérisation du texte à partir de l'image
  Future<void> scanImage() async {
    String imagePath;

    if (widget.imagePath != null) {
      imagePath = widget.imagePath!;
    } else {
      if (cameraController == null) {
        return;
      }

      try {
        final pictureFile = await cameraController!.takePicture();
        imagePath = pictureFile.path;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erreur lors du scan').tr(),
          ),
        );
        return;
      }
    }

    final navigator = Navigator.of(context);
    try {
      final file = File(imagePath);
      final inputImage = InputImage.fromFile(file);
      final recognizerText = await textRecogniser.processImage(inputImage);

      await navigator.push(
        MaterialPageRoute(
          builder: (context) => ResultScreen(text: recognizerText.text),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erreur lors du scan').tr(),
        ),
      );
    }
  }
}
