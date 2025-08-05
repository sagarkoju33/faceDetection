import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'package:path/path.dart' as p;

class FaceValidationScreen extends StatefulWidget {
  const FaceValidationScreen({super.key});

  @override
  State<FaceValidationScreen> createState() => _FaceValidationScreenState();
}

class _FaceValidationScreenState extends State<FaceValidationScreen> {
  CameraController? _cameraController;
  bool _isDetecting = false;
  String _message = "Initializing camera...";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCam = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    _cameraController = CameraController(frontCam, ResolutionPreset.high);
    await _cameraController!.initialize();

    setState(() {
      _message = "Please blink once to confirm you're real.";
    });

    _cameraController!.startImageStream(_processCameraImage);
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isDetecting) return;
    _isDetecting = true;

    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }

      final inputImage = InputImage.fromBytes(
        bytes: image.planes[0].bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation0deg, // Adjust if needed
          format: InputImageFormat.nv21, // Common format for Android
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );

      final faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableClassification: true,
          performanceMode: FaceDetectorMode.accurate,
          enableLandmarks: true,
        ),
      );

      final faces = await faceDetector.processImage(inputImage);
      if (faces.length != 1) {
        setState(() {
          _message = "Make sure only one real person is visible.";
        });
        _isDetecting = false;
        return;
      }

      final face = faces.first;

      // Basic liveness check: blink detection
      final leftEye = face.leftEyeOpenProbability ?? 1.0;
      final rightEye = face.rightEyeOpenProbability ?? 1.0;

      if (leftEye < 0.5 && rightEye < 0.5) {
        _cameraController!.stopImageStream();
        _captureAndCropImage();
      } else {
        setState(() {
          _message = "Please blink once.";
        });
      }
    } catch (e) {
      setState(() {
        _message = "Error: $e";
      });
    } finally {
      _isDetecting = false;
    }
  }

  Future<void> _captureAndCropImage() async {
    try {
      final file = await _cameraController!.takePicture();

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: file.path,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Your Face',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
          ),
          IOSUiSettings(title: 'Crop Your Face'),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _message = "? Valid photo taken!";
        });
        // Save to local or send to server
      } else {
        setState(() {
          _message = "Cropping cancelled.";
        });
      }
    } catch (e) {
      setState(() {
        _message = "Capture failed: $e";
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Face Validation")),
      body: _cameraController == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                AspectRatio(
                  aspectRatio: _cameraController!.value.aspectRatio,
                  child: CameraPreview(_cameraController!),
                ),
                const SizedBox(height: 20),
                Text(
                  _message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
    );
  }
}
