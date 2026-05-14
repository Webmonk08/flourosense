import 'dart:io';
import 'dart:typed_data';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:image/image.dart' as img;

class ImageClassificationService {
  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset("assets/model.tflite");
  }

  Future<List?> classifyImage(File imageFile) async {
    var image = img.decodeImage(imageFile.readAsBytesSync())!;
    var resizedImage = img.copyResize(image, width: 224, height: 224);

    var recognitions = await Tflite.runModelOnBinary(
      binary: imageToByteListFloat32(resizedImage, 224, 127.5, 127.5),
      numResults: 4,
    );
    return recognitions;
  }

  Float32List imageToByteListFloat32(
      img.Image image, int inputSize, double mean, double std) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (pixel.r - mean) / std;
        buffer[pixelIndex++] = (pixel.g - mean) / std;
        buffer[pixelIndex++] = (pixel.b - mean) / std;
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  void dispose() {
    Tflite.close();
  }
}

