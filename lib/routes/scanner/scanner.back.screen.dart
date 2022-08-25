import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kyc_demo/components/Scanner.dart';

class ScannerBackScreen extends StatefulWidget {
  const ScannerBackScreen({super.key});
  @override
  State<ScannerBackScreen> createState() => _PlatformChannelState();
}

class _PlatformChannelState extends State<ScannerBackScreen> {
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
    debugPrint("flutter back: $event");
    if (type == "scanBackSuccess" && mounted) {
      Navigator.pushNamed(context, '/scanner-selfie');
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
      appBar: AppBar(title: const Text('Scan your back ID')),
      body: SafeArea(
        minimum: const EdgeInsets.all(0.0),
        child: Scanner(
            viewType: ViewTypes.back,
            onScannerCreated: (instance) {
              instance.initScanner("BACK!!!!");
              initEventSubscription();
            }),
      ),
    );
  }
}
