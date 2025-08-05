// import 'dart:io';
// import 'package:camera/camera.dart';
// import 'package:facedetection/front_camera.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:path/path.dart' as path;

// class FaceValidationScreen extends StatefulWidget {
//   const FaceValidationScreen({super.key});

//   @override
//   State<FaceValidationScreen> createState() => _FaceValidationScreenState();
// }

// class _FaceValidationScreenState extends State<FaceValidationScreen> {
//   File? _imageFile;
//   String _resultText = 'No image yet.';

//   @override
//   void initState() {
//     super.initState();
//     _startCameraFlow();
//   }

//   Future<void> _startCameraFlow() async {
//     final cameras = await availableCameras();
//     final frontCamera = cameras.firstWhere(
//       (camera) => camera.lensDirection == CameraLensDirection.front,
//     );

//     final controller = CameraController(
//       frontCamera,
//       ResolutionPreset.medium,
//       enableAudio: false,
//     );

//     await controller.initialize();

//     final image = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => CameraCaptureScreen(controller: controller),
//       ),
//     );

//     if (image != null && image is File) {
//       await _cropAndValidate(image);
//     }
//   }

//   Future<void> _cropAndValidate(File image) async {
//     final cropped = await ImageCropper().cropImage(
//       sourcePath: image.path,
//       compressQuality: 90,
//       uiSettings: [
//         AndroidUiSettings(
//           toolbarTitle: 'Crop Image',
//           toolbarColor: Colors.deepOrange,
//           toolbarWidgetColor: Colors.white,
//           lockAspectRatio: false,
//         ),
//         IOSUiSettings(title: 'Crop Image'),
//       ],
//     );

//     if (cropped == null) {
//       setState(() {
//         _resultText = '? Cropping cancelled.';
//         _imageFile = null;
//       });
//       return;
//     }

//     final File finalImage = File(cropped.path);
//     setState(() {
//       _imageFile = finalImage;
//       _resultText = '?? Detecting face...';
//     });

//     final bool isValid = await _detectFace(finalImage.path);
//     setState(() {
//       _resultText = isValid
//           ? '? Valid profile photo with clear face.'
//           : '? Invalid. Face not detected properly.';
//     });
//   }

//   Future<bool> _detectFace(String path) async {
//     final inputImage = InputImage.fromFilePath(path);
//     final faceDetector = FaceDetector(
//       options: FaceDetectorOptions(
//         enableClassification: true, // for smile & eye open probs
//         enableLandmarks: true,
//         enableContours: true,
//         performanceMode: FaceDetectorMode.fast,
//         minFaceSize: 1, // minimum face size to detect
//       ),
//     );

//     final faces = await faceDetector.processImage(inputImage);
//     await faceDetector.close();

//     if (faces.isEmpty) return false;
//     if (faces.length > 1) {
//       setState(
//         () => _resultText =
//             '? Multiple faces detected. Please take a photo alone.',
//       );
//       return false;
//     }

//     for (Face face in faces) {
//       final rotX = face.headEulerAngleX ?? 0;
//       final rotY = face.headEulerAngleY ?? 0;
//       final rotZ = face.headEulerAngleZ ?? 0;

//       final smile = face.smilingProbability ?? 0;
//       final leftEyeOpen = face.leftEyeOpenProbability ?? 0;
//       final rightEyeOpen = face.rightEyeOpenProbability ?? 0;

//       final leftEye = face.landmarks[FaceLandmarkType.leftEye];
//       final rightEye = face.landmarks[FaceLandmarkType.rightEye];
//       final leftEar = face.landmarks[FaceLandmarkType.leftEar];
//       final rightEar = face.landmarks[FaceLandmarkType.rightEar];

//       bool isValid =
//           rotX.abs() < 15 &&
//           rotY.abs() < 15 &&
//           rotZ.abs() < 15 &&
//           smile < 0.7 &&
//           leftEyeOpen > 0.6 && // Eyes must be clearly open
//           rightEyeOpen > 0.6 &&
//           leftEye != null &&
//           rightEye != null &&
//           leftEar != null &&
//           rightEar != null;

//       if (isValid) return true;
//     }

//     return false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Face Validation")),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               if (_imageFile != null)
//                 Image.file(_imageFile!, height: 300, fit: BoxFit.cover),
//               const SizedBox(height: 20),
//               Text(
//                 _resultText,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: _resultText.contains('?') ? Colors.green : Colors.red,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _startCameraFlow,
//                 child: const Text("Retake Photo"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
