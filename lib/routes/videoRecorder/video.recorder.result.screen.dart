import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kyc_demo/components/customButton.dart';
import 'dart:io' show Platform;

class VideoRecorderResultScreen extends StatefulWidget {
  const VideoRecorderResultScreen({Key? key, this.result}) : super(key: key);
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
    double bottomOffset = Platform.isAndroid ? 20.0 : 0.0;
    return Scaffold(
      appBar: AppBar(title: const Text('Recording result')),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: Container(
        margin: EdgeInsets.fromLTRB(16.0, 0, 16.0, bottomOffset),
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
      body: SafeArea(
        minimum: const EdgeInsets.all(16.0),
        child: Container(
            alignment: Alignment.center,
            child: Text(widget.result ?? "Result not available")),
      ),
    );
  }
}
