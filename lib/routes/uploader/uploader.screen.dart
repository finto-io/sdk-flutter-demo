import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kyc_demo/components/CustomButton.dart';

class UploaderScreen extends StatefulWidget {
  const UploaderScreen({super.key});
  @override
  State<UploaderScreen> createState() => _PlatformChannelState();
}

class _PlatformChannelState extends State<UploaderScreen> {
  bool isUploading = false;
  String path = '';

  late StreamSubscription streamSubscription;

  static const EventChannel eventChannel =
      EventChannel('samples.flutter.io/uploaderEventChannel');

  static const MethodChannel methodChannel =
      MethodChannel('samples.flutter.io/uploaderMethodChannel');

  Future<void> _callUploader() async {
    try {
      await methodChannel.invokeMethod('openUploader');
    } on PlatformException catch (e) {
      print("error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    streamSubscription = eventChannel
        .receiveBroadcastStream()
        .listen(_onEvent, onError: _onError);
    _callUploader();
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscription.cancel();
  }

  void _onEvent(event) {
    setState(() {
      isUploading = event['uploading'] ?? false;
      path = event['path'] ?? "";
    });
  }

  void clipboardCopy() {
    Clipboard.setData(ClipboardData(text: path)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Address copied to clipboard",
            textAlign: TextAlign.center,
          ),
        ),
      );
    });
  }

  void _onError(Object error) {
    print('error: $error');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Uploader')),
      body: SafeArea(
        minimum: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
                child: Container(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (isUploading) const Text("Loading..."),
                        if (path.isNotEmpty) Text(path)
                      ],
                    ))),
            CustomButton(
              label: "Try again",
              onPressed: clipboardCopy,
            )
          ],
        ),
      ),
    );
  }
}
