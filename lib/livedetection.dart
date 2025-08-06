import 'dart:developer';
import 'dart:io';

import 'package:facelivenessdetection/facelivenessdetection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class FaceVerificationWidget extends StatefulWidget {
  @override
  _FaceVerificationWidgetState createState() => _FaceVerificationWidgetState();
}

class _FaceVerificationWidgetState extends State<FaceVerificationWidget> {
  final List<Rulesets> _completedRuleset = [];
  File? capturedImage;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: FaceDetectorView(
          onSuccessValidation: (validated) {
            log('Face verification is completed', name: 'Validation');
          },

          onValidationDone: (controller) {
            // Capture image in background (async), don't call setState immediately
            Future.microtask(() async {
              if (controller != null && controller.value.isInitialized) {
                try {
                  final XFile file = await controller.takePicture();
                  if (mounted) {
                    setState(() {
                      capturedImage = File(file.path);
                    });
                  }
                } catch (e) {
                  print("Capture error: $e");
                }
              }
            });

            // Return UI placeholder while image is being captured
            return CircleAvatar(
              radius: 100,
              backgroundColor: Colors.grey[200],
              child: capturedImage != null
                  ? ClipOval(
                      child: Image.file(capturedImage!, fit: BoxFit.cover),
                    )
                  : const Icon(Icons.person, size: 80),
            );
          },

          child: ({required countdown, required state, required hasFace}) {
            return SafeArea(
              child: Center(
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Flexible(
                          child: AnimatedSize(
                            duration: const Duration(milliseconds: 150),
                            child: Text(
                              hasFace
                                  ? 'User face found'
                                  : 'User face not found',
                              style: _textStyle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _rulesetHints[state] ?? 'Please follow instructions',
                      style: _textStyle.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          onRulesetCompleted: (ruleset) {
            if (!_completedRuleset.contains(ruleset)) {
              setState(() => _completedRuleset.add(ruleset));
            }
          },
        ),
      ),
    );
  }
}

/// Text style for UI consistency
const TextStyle _textStyle = TextStyle(
  color: Colors.black,
  fontWeight: FontWeight.w400,
  fontSize: 12,
);

/// Ruleset hints for better performance (eliminating switch-case)
const Map<Rulesets, String> _rulesetHints = {
  Rulesets.smiling: 'Please Smile',
  Rulesets.blink: 'Please Blink',
  Rulesets.tiltUp: 'Please Look Up',
  Rulesets.tiltDown: 'Please Look Down',
  Rulesets.toLeft: 'Please Look Left',
  Rulesets.toRight: 'Please Look Right',
};
