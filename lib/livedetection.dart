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
  XFile? capturedImage;
  Rulesets? lastCompletedRuleset;
  bool _hasCapturedImage = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FaceDetectorView(
        // onSuccessValidation: (validated) {
        //   log('Face verification is completed', name: 'Validation');
        // },
        onRulesetCompleted: (ruleset) {
          log('Ruleset completed: $ruleset');
          if (!_completedRuleset.contains(ruleset)) {
            setState(() {
              _completedRuleset.add(ruleset);
              lastCompletedRuleset = ruleset;
            });
          }
        },

        onValidationDone: (controller) {
          log(
            'onValidationDone called, lastCompletedRuleset: $lastCompletedRuleset, hasCaptured: $_hasCapturedImage',
          );

          if (lastCompletedRuleset == Rulesets.smiling &&
              !_hasCapturedImage &&
              controller != null &&
              controller.value.isInitialized) {
            _hasCapturedImage = true;
            log('Taking picture now...');
            controller
                .takePicture()
                .then((file) {
                  log('Picture taken: ${file.path}');
                  if (mounted) {
                    setState(() {
                      capturedImage = file;
                    });
                  }
                })
                .catchError((e) {
                  log('Capture error: $e');
                  _hasCapturedImage = false;
                });
          }

          return Column(
            children: [
              Text(
                capturedImage != null
                    ? "Face Verification: ${capturedImage!.path}"
                    : "No image captured yet",
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: capturedImage != null
                    ? Image.file(
                        File(capturedImage!.path),
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          );
        },

        child: ({required countdown, required state, required hasFace}) {
          return SafeArea(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 150),
                      child: Text(
                        hasFace ? 'User face found' : 'User face not found',
                        style: _textStyle,
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
          );
        },
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
