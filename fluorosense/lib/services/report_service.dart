import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class ReportService {
  Future<File> generateReport({
    required String name,
    required String age,
    required String gender,
    required String waterSource,
    required String toothpasteType,
    required String classification,
    required double confidence,
    required String recommendations,
    required File imageFile,
  }) async {
    final pdf = pw.Document();
    final image = pw.MemoryImage(imageFile.readAsBytesSync());

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('FluoroSense Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Patient Details:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text('Name: $name'),
              pw.Text('Age: $age'),
              pw.Text('Gender: $gender'),
              pw.Text('Water Source: $waterSource'),
              pw.Text('Toothpaste: $toothpasteType'),
              pw.SizedBox(height: 20),
              pw.Text('Analysis Results:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text('Classification: $classification'),
              pw.Text('Confidence: ${(confidence * 100).toStringAsFixed(2)}%'),
              pw.SizedBox(height: 20),
              pw.Text('Captured Image:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Image(image, width: 200, height: 200),
              pw.SizedBox(height: 20),
              pw.Text('Recommendations:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text(recommendations),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/fluorosense_report.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
