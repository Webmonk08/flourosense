import 'dart:io';
import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  final File imageFile;
  final String classification;
  final double confidence;

  const ResultsScreen({
    Key? key,
    required this.imageFile,
    required this.classification,
    required this.confidence,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analysis Results'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.file(imageFile, width: 250, height: 250, fit: BoxFit.cover),
            SizedBox(height: 20),
            Text(
              'Classification: $classification',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Confidence: ${(confidence * 100).toStringAsFixed(2)}%',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}


