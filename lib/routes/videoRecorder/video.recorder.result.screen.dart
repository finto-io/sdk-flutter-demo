import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kyc_demo/components/CustomButton.dart';

class VideoRecorderResultScreen extends StatefulWidget {
  const VideoRecorderResultScreen({super.key, this.result});
  final String? result;
  @override
  State<VideoRecorderResultScreen> createState() => VideoRecorderResultState();
}

class VideoRecorderResultState extends State<VideoRecorderResultScreen> {
  void copy() {
    Clipboard.setData(ClipboardData(text: widget.result)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Link copied to clipboard",
            textAlign: TextAlign.center,
          ),
        ),
      );
    });
  }

  void backToHome() {
    if (mounted) {
      Navigator.popUntil(context, ModalRoute.withName('/'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recording result')),
      body: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 20.0),
        child: SingleChildScrollView(
          child: Container(
              alignment: Alignment.center,
              child: Text(widget.result ?? "Result not available")),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Flexible(
              child: CustomButton(
                label: "Copy link",
                onPressed: copy,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: CustomButton(
                label: "Back to home screen",
                onPressed: backToHome,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
