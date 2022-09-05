import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kyc_demo/components/customUiKitView.dart';
import 'package:flutter_kyc_demo/enums/enums.dart';

class ScannerBackScreen extends StatefulWidget {
  const ScannerBackScreen({Key? key}) : super(key: key);
  @override
  State<ScannerBackScreen> createState() => _PlatformChannelState();
}

class _PlatformChannelState extends State<ScannerBackScreen> {
  late StreamSubscription streamSubscription;

  static const EventChannel eventChannel =
      EventChannel('samples.flutter.io/scannerBackEventChannel');

  @override
  void initState() {
    super.initState();
  }

  void initEventSubscription() {
    streamSubscription =
        eventChannel.receiveBroadcastStream().listen(onEvent, onError: onError);
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscription.cancel();
  }

  onEvent(event) {
    if (!mounted) return;
    switch (event["type"]) {
      case "scan_back_success":
        {
          Navigator.pushNamed(context, '/scanner-selfie');
        }
        break;
      case "scan_back_failed":
        {
          String error = event['data'];
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red.shade900,
            content: Text(
              error,
              textAlign: TextAlign.left,
            ),
          ));
          Navigator.popUntil(context, ModalRoute.withName('/'));
        }
        break;
      default:
        break;
    }
  }

  onError(error) {
    debugPrint("Error: $error");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Scan back of your ID')),
      body: SafeArea(
        minimum: const EdgeInsets.all(0.0),
        child: CustomUIKitView(
          viewType: ViewTypes.back,
          onCreated: (instance) {
            instance.initialize();
            initEventSubscription();
          },
        ),
      ),
    );
  }
}
