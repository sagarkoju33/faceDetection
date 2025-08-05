import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CameraCaptureScreen extends StatefulWidget {
  final CameraController controller;
  const CameraCaptureScreen({super.key, required this.controller});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  late CameraController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  Future<void> _takePicture() async {
    try {
      final XFile file = await _controller.takePicture();
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath = path.join(tempDir.path, '${DateTime.now()}.jpg');
      final savedImage = await File(file.path).copy(filePath);
      if (mounted) Navigator.pop(context, savedImage);
    } catch (e) {
      debugPrint('Error capturing: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Capture Photo")),
      body: Column(
        children: [
          Expanded(child: CameraPreview(_controller)),
          ElevatedButton.icon(
            onPressed: _takePicture,
            icon: const Icon(Icons.camera),
            label: const Text("Capture"),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
