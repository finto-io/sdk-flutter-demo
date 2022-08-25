import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kyc_demo/components/Scanner.dart';
import 'package:flutter_kyc_demo/routes/scanner/scanner.result.screen.dart';

class ScannerSelfieScreen extends StatefulWidget {
  const ScannerSelfieScreen({super.key});
  @override
  State<ScannerSelfieScreen> createState() => _PlatformChannelState();
}

class _PlatformChannelState extends State<ScannerSelfieScreen> {
  late StreamSubscription streamSubscription;

  static const EventChannel eventChannel =
      EventChannel('samples.flutter.io/scannerEventChannel');

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
    debugPrint("flutter selfie: $event");
    if (type == "scanSelfieSuccess" && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute<String>(
          builder: (context) => ScannerResultScreen(result: event["params"]),
        ),
      );
    } else {
      debugPrint("Error: $event['params']");
    }
  }

  _onError(error) {
    debugPrint("Error:$error");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Please take a selfie')),
      body: SafeArea(
          minimum: const EdgeInsets.all(0.0),
          child: Scanner(
              viewType: ViewTypes.selfie,
              onScannerCreated: (instance) {
                instance.initScanner("SELFIE!!!!");
                initEventSubscription();
              })),
    );
  }
}
