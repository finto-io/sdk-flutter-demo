import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kyc_demo/components/customUiKitView.dart';
import 'package:flutter_kyc_demo/enums/enums.dart';
import 'package:flutter_kyc_demo/main.dart';

class ScannerFrontScreen extends StatefulWidget {
  const ScannerFrontScreen({super.key});
  @override
  State<ScannerFrontScreen> createState() => _PlatformChannelState();
}

class _PlatformChannelState extends State<ScannerFrontScreen> with RouteAware {
  late StreamSubscription streamSubscription;

  late CustomUIKitController _instance;

  static const EventChannel eventChannel =
      EventChannel('samples.flutter.io/scannerFrontEventChannel');

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
    print('FLUTTER: didPush ScannerFrontScreen');
  }

  @override
  void didPopNext() {
    // here back button was pressed
    print('FLUTTER:  didPopNext ScannerFrontScreen');
    _instance.restart();
  }

  void initEventSubscription() {
    debugPrint("Subscribe");
    streamSubscription =
        eventChannel.receiveBroadcastStream().listen(onEvent, onError: onError);
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscription.cancel();
    routeObserver.unsubscribe(this);
  }

  onEvent(event) {
    if (!mounted) return;
    switch (event["type"]) {
      case "scan_front_success":
        {
          Navigator.pushNamed(context, '/scanner-back');
        }
        break;
      case "scan_front_failed":
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
    debugPrint("BUILD");
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Scan front of your ID')),
      body: SafeArea(
        minimum: const EdgeInsets.all(0.0),
        child: CustomUIKitView(
          viewType: ViewTypes.front,
          onCreated: (instance) {
            _instance = instance;
            instance.initialize();
            initEventSubscription();
          },
        ),
      ),
    );
  }
}
