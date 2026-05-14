import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluorosense/services/api_service.dart';
import 'package:fluorosense/screens/results_screen.dart';

class ImageSelectionScreen extends StatefulWidget {
  const ImageSelectionScreen({super.key});

  @override
  State<ImageSelectionScreen> createState() => _ImageSelectionScreenState();
}

class _ImageSelectionScreenState extends State<ImageSelectionScreen> {
  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _pickImageAndSubmit(
    ImageSource source,
    Map<String, String> formData,
  ) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No image selected. Please try again.')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final Uint8List imageBytes = await pickedFile.readAsBytes();
      final String fileName = pickedFile.name;

      final results = await _apiService.submitReport(
        imageBytes: imageBytes,
        fileName: fileName,
        formData: formData,
      );

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(
            imageBytes: imageBytes,
            classification: results['classification'],
            confidence: results['confidence'],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
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
    final args = ModalRoute.of(context)?.settings.arguments;
    final formData = (args is Map<String, String>) ? args : <String, String>{};

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
