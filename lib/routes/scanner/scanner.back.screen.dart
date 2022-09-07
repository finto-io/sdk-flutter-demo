import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kyc_demo/components/customUiKitView.dart';
import 'package:flutter_kyc_demo/enums/enums.dart';
import 'package:flutter_kyc_demo/main.dart';

class ScannerBackScreen extends StatefulWidget {
  const ScannerBackScreen({Key? key}) : super(key: key);
  @override
  State<ScannerBackScreen> createState() => _PlatformChannelState();
}

class _PlatformChannelState extends State<ScannerBackScreen> with RouteAware {
  late StreamSubscription streamSubscription;

  static const EventChannel eventChannel =
      EventChannel('samples.flutter.io/scannerBackEventChannel');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didPush() {
    print('FLUTTER: didPush ScannerBackScreen');
  }

  @override
  void didPopNext() {
    print('FLUTTER: didPopNext ScannerBackScreen');
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
          print("ERROR!!!!!!: $error");
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
