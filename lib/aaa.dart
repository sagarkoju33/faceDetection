import 'package:facelivenessdetection/facelivenessdetection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class FaceVerificationWidget extends StatefulWidget {
  @override
  _FaceVerificationWidgetState createState() => _FaceVerificationWidgetState();
}

class _FaceVerificationWidgetState extends State<FaceVerificationWidget> {
  final List<Rulesets> _completedRuleset = [];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FaceDetectorView(
        onSuccessValidation: (validated) {
          if (validated && mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Verification Successful"),
                    content: const Text(
                      "Image has been verified successfully.",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // dismiss dialog
                          Navigator.of(context).pop(); // go back
                        },
                        child: const Text("OK"),
                      ),
                    ],
                  );
                },
              );
            });
          }
        },

        onValidationDone: (controller) {
          // if (mounted) {
          //   Navigator.pop(context, controller);
          // }
          return SizedBox(height: 0, width: 0);
        },
        child: ({required countdown, required state, required hasFace}) {
          return Column(
            children: [
              const SizedBox(height: 80),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Image.asset(
                  //   'assets/face_verification_icon.png',
                  //   height: 30,
                  //   width: 30,
                  // ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 150),
                      child: Text(
                        hasFace ? 'User face found' : 'User face not found',
                        style: _textStyle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                _rulesetHints[state] ?? 'Please follow instructions',
                style: _textStyle.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        },
        onRulesetCompleted: (ruleset) {
          if (!_completedRuleset.contains(ruleset)) {
            setState(() => _completedRuleset.add(ruleset));
          }
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
