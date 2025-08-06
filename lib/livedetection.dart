import 'dart:developer';
import 'dart:io';

import 'package:facelivenessdetection/facelivenessdetection.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:path/path.dart' as path;

class FaceVerificationWidget extends StatefulWidget {
  @override
  _FaceVerificationWidgetState createState() => _FaceVerificationWidgetState();
}

class _FaceVerificationWidgetState extends State<FaceVerificationWidget> {
  XFile? capturedImage;
  bool _hasCapturedImage = false;
  List<Rulesets> completedRulesets = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Face Liveness Detection")),
      body: SafeArea(
        child: FaceDetectorView(
          ruleset: [Rulesets.blink, Rulesets.smiling],

          onRulesetCompleted: (ruleset) {
            log('Ruleset completed: $ruleset');
            if (!completedRulesets.contains(Rulesets.smiling)) {
              completedRulesets.add(ruleset);
            }
          },

          onValidationDone: (controller) {
            _captureIfSmiled(controller);

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Face Liveness Result"),
                const SizedBox(height: 10),
                if (capturedImage != null) ...[
                  Text("Image Path: ${capturedImage!.path}"),
                  const SizedBox(height: 10),
                  Image.file(
                    File(capturedImage!.path),
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ] else
                  const Text("No image captured"),
              ],
            );
          },

          child: ({required countdown, required state, required hasFace}) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(hasFace ? '✅ Face Found' : '❌ No Face', style: _textStyle),
                const SizedBox(height: 20),
                Text(
                  _rulesetHints[state] ?? '➡️ Follow instructions',
                  style: _textStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _captureIfSmiled(dynamic controller) async {
    try {
      if (_hasCapturedImage) return;

      if (completedRulesets.contains(Rulesets.smiling)) {
        if (controller != null && controller.value.isInitialized) {
          final XFile image = await controller.takePicture();

          log('Captured image after smiling at: ${image.path}');
          final String fileName = path.basename(image.path);
          final String newPath = path.join(Directory.systemTemp.path, fileName);
          await image.saveTo(newPath);
          setState(() {
            capturedImage = image;
            _hasCapturedImage = true;
          });
        } else {
          log("Camera controller not initialized");
        }
      } else {
        log("Smile not detected, skipping capture.");
      }
    } catch (e) {
      log("Error capturing image: $e");
    }
  }
}

/// Text style
const TextStyle _textStyle = TextStyle(
  color: Colors.black,
  fontWeight: FontWeight.w500,
  fontSize: 16,
);

/// Instructions
const Map<Rulesets, String> _rulesetHints = {
  Rulesets.smiling: '😊 Please Smile',
  Rulesets.blink: '👁 Blink',
  Rulesets.tiltUp: '⬆ Look Up',
  Rulesets.tiltDown: '⬇ Look Down',
  Rulesets.toLeft: '⬅ Look Left',
  Rulesets.toRight: '➡ Look Right',
};
