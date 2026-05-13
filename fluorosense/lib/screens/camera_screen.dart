import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluorosense/services/api_service.dart';
import 'package:fluorosense/screens/results_screen.dart';

class ImageSelectionScreen extends StatefulWidget {
  @override
  _ImageSelectionScreenState createState() => _ImageSelectionScreenState();
}

class _ImageSelectionScreenState extends State<ImageSelectionScreen> {
  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _pickImageAndSubmit(ImageSource source, Map<String, String> formData) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _apiService.submitReport(
        image: File(pickedFile.path),
        formData: formData,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              // The image from the server might be different if it was processed,
              // but for now, we show the one we uploaded.
              imageFile: File(pickedFile.path), 
              classification: results['classification'],
              confidence: results['confidence'],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formData = ModalRoute.of(context)!.settings.arguments as Map<String, String>;

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Image for Analysis'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("Uploading and analyzing... Please wait."),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (kIsWeb)
                      ..._buildWebLayout(formData)
                    else
                      ..._buildMobileLayout(formData),
                  ],
                ),
              ),
      ),
    );
  }

  List<Widget> _buildMobileLayout(Map<String, String> formData) {
    return [
      ElevatedButton.icon(
        icon: Icon(Icons.camera_alt),
        label: Text('Take Photo with Camera'),
        onPressed: () => _pickImageAndSubmit(ImageSource.camera, formData),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 20),
        ),
      ),
      SizedBox(height: 30),
      ElevatedButton.icon(
        icon: Icon(Icons.photo_library),
        label: Text('Upload from Gallery'),
        onPressed: () => _pickImageAndSubmit(ImageSource.gallery, formData),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    ];
  }

  List<Widget> _buildWebLayout(Map<String, String> formData) {
    return [
      ElevatedButton.icon(
        icon: Icon(Icons.upload_file),
        label: Text('Upload Image from Computer'),
        onPressed: () => _pickImageAndSubmit(ImageSource.gallery, formData),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    ];
  }
}