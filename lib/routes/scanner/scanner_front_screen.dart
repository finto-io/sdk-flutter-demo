import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kyc_demo/components/CustomUIKitView.dart';
import 'package:flutter_kyc_demo/enums/enums.dart';
import 'package:flutter_kyc_demo/main.dart';
import 'package:flutter_kyc_demo/routes/router_list.dart';

class ScannerFrontScreen extends StatefulWidget {
  const ScannerFrontScreen({super.key});
  @override
  State<ScannerFrontScreen> createState() => _PlatformChannelState();
}

class _PlatformChannelState extends State<ScannerFrontScreen> with RouteAware {
  late StreamSubscription streamSubscription;

  late CustomUIKitController _instance;

  static const EventChannel eventChannel =
      EventChannel('kyc.sdk/scannerFrontEventChannel');

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
  void didPopNext() {
    if (!mounted) return;
    _instance.restart();
  }

  void initEventSubscription() {
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
          Navigator.pushNamed(context, RoutesList.scannerBack);
        }
        break;
      case "scan_front_failed":
        {
          String error = event['data'];
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red.shade900,
            content: Text(
              error,
              textAlign: TextAlign.left,
            ),
          ));
          _instance.restart();
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