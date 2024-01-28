// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:share/share.dart';

class ResultScreen extends StatelessWidget {
  final String text;

  const ResultScreen({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconnaissance de texte'),
      ),
      body: Container(
        padding: const EdgeInsets.all(30.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Texte d\'origine :'),
              Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _partagerTexte(text);
                },
                child: const Text('Envoyer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _partagerTexte(String text) {
    Share.share(text, subject: 'Résultat de la reconnaissance de texte');
  }
}
