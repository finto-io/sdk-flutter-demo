import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kyc_demo/components/Webview.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});
  @override
  State<ScannerScreen> createState() => _PlatformChannelState();
}

class _PlatformChannelState extends State<ScannerScreen> {
  // late StreamSubscription streamSubscription;

  // static const EventChannel eventChannel =
  //     EventChannel('samples.flutter.io/uploaderEventChannel');

  static const MethodChannel methodChannel =
      MethodChannel('samples.flutter.io/scannerMethodChannel');

  Future<void> initScanner() async {
    try {
      await methodChannel.invokeMethod('initScanner');
    } on PlatformException catch (e) {
      debugPrint("error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    // initScanner();
    // streamSubscription = eventChannel
    //     .receiveBroadcastStream()
    //     .listen(_onEvent, onError: _onError);
  }

  @override
  void dispose() {
    super.dispose();
    // streamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner')),
      body: SafeArea(
          minimum: const EdgeInsets.all(16.0),
          child: WebView(onWebViewCreated: (id) {
            id.loadUrl("https://google.com");
          })),
    );
  }
}
