import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceValidationScreen extends StatefulWidget {
  const FaceValidationScreen({super.key});

  @override
  _FaceValidationScreenState createState() => _FaceValidationScreenState();
}

class _FaceValidationScreenState extends State<FaceValidationScreen> {
  File? _imageFile;
  String _resultText = '';

  Future<void> captureCropAndDetectFace() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) {
      setState(() => _resultText = '❌ No image selected.');
      return;
    }

    final CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: image.path,
      compressQuality: 90,

      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Crop Image'),
      ],
    );

    if (croppedImage == null) {
      setState(() => _resultText = '❌ Cropping cancelled.');
      return;
    }

    final File finalImage = File(croppedImage.path);
    setState(() {
      _imageFile = finalImage;
      _resultText = '🔍 Detecting face...';
    });

    final bool isValid = await detectFace(finalImage.path);
    setState(() {
      _resultText = isValid
          ? '✅ Face detected. Valid profile photo.'
          : '❌ No face detected. Try again.';
    });
  }

  Future<bool> detectFace(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: false,
        enableClassification: true,
      ),
    );

    final List<Face> faces = await faceDetector.processImage(inputImage);
    await faceDetector.close();

    return faces.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Face Validation")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: captureCropAndDetectFace,
              child: Text('Capture and Validate Face'),
            ),
            SizedBox(height: 20),
            if (_imageFile != null) Image.file(_imageFile!, height: 300),
            SizedBox(height: 20),
            Text(
              _resultText,
              style: TextStyle(
                fontSize: 16,
                color: _resultText.contains('✅') ? Colors.green : Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
