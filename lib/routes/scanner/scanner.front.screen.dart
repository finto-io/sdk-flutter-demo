import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kyc_demo/components/CustomUIKitView.dart';

class ScannerFrontScreen extends StatefulWidget {
  const ScannerFrontScreen({super.key});
  @override
  State<ScannerFrontScreen> createState() => _PlatformChannelState();
}

class _PlatformChannelState extends State<ScannerFrontScreen> {
  late StreamSubscription streamSubscription;

  static const EventChannel eventChannel =
      EventChannel('samples.flutter.io/scannerFrontEventChannel');

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
    if (type == "scanFrontSuccess" && mounted) {
      Navigator.pushNamed(context, '/scanner-back');
    } else {
      var error = event["params"];
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red.shade900,
        content: Text(
          "$error",
          textAlign: TextAlign.left,
        ),
      ));
      Navigator.popUntil(context, ModalRoute.withName('/'));
    }
  }

  _onError(error) {
    debugPrint("Error: $error");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Scan front of your ID')),
      body: SafeArea(
        minimum: const EdgeInsets.all(0.0),
        child: CustomUIKitView(
          viewType: ViewTypes.front,
          onCreated: (instance) {
            instance.initialize();
            initEventSubscription();
          },
        ),
      ),
    );
  }
}
