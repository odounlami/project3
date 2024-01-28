// ignore_for_file: unused_element

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'HomeScreen.dart';
late List<CameraDescription> _cameras;
void main() async{
    WidgetsFlutterBinding.ensureInitialized();

    _cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ScanTextByOsk',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen()
    );
  }
}

