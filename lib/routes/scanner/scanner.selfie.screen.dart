import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kyc_demo/components/ScannerUIKit.dart';
import 'package:flutter_kyc_demo/routes/scanner/scanner.result.screen.dart';

class ScannerSelfieScreen extends StatefulWidget {
  const ScannerSelfieScreen({super.key});
  @override
  State<ScannerSelfieScreen> createState() => _PlatformChannelState();
}

class _PlatformChannelState extends State<ScannerSelfieScreen> {
  late StreamSubscription streamSubscription;

  static const EventChannel eventChannel =
      EventChannel('samples.flutter.io/scannerSelfieEventChannel');

  @override
  void initState() {
    super.initState();
  }

  void initEventSubscription() {
    streamSubscription = eventChannel
        .receiveBroadcastStream()
        .listen(_onEvent, onError: _onError);
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscription.cancel();
  }

  _onEvent(event) {
    var type = event["type"];
    if (type == "scanSelfieSuccess" && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute<String>(
          builder: (context) => ScannerResultScreen(result: event["params"]),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red.shade900,
        content: Text(
          "$event['params']",
          textAlign: TextAlign.left,
        ),
      ));
    }
  }

  _onError(error) {
    debugPrint("Error: $error");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Please take a selfie')),
      body: SafeArea(
          minimum: const EdgeInsets.all(0.0),
          child: ScannerUIKit(
              viewType: ViewTypes.selfie,
              onCreated: (instance) {
                instance.initialize();
                initEventSubscription();
              })),
    );
  }
}
