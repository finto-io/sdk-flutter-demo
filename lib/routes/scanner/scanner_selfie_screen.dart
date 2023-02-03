import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kyc_demo/components/CustomUIKitView.dart';
import 'package:flutter_kyc_demo/enums/enums.dart';
import 'package:flutter_kyc_demo/main.dart';
import 'package:flutter_kyc_demo/routes/router_list.dart';

// ignore: non_constant_identifier_names
double SIMILARITY_EDGE = 0.7;

class ScannerSelfieScreen extends StatefulWidget {
  const ScannerSelfieScreen({super.key});
  @override
  State<ScannerSelfieScreen> createState() => _PlatformChannelState();
}

class _PlatformChannelState extends State<ScannerSelfieScreen> with RouteAware {
  late StreamSubscription streamSubscription;
  late CustomUIKitController _instance;
  bool isLoading = false;
  static const EventChannel eventChannel =
      EventChannel('kyc.sdk/scannerSelfieEventChannel');

  static const MethodChannel methodChannel =
      MethodChannel('kyc.sdk/resultMethodChannel');

  @override
  void initState() {
    super.initState();
  }

  void initEventSubscription() {
    streamSubscription =
        eventChannel.receiveBroadcastStream().listen(onEvent, onError: onError);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didPopNext() {
    if (!mounted) return;
    _instance.restart();
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscription.cancel();
    routeObserver.unsubscribe(this);
  }

  Future<void> processNavigation() async {
    double similarity = await getSimilarity();
    if (similarity > 1) return;
    debugPrint("similarity: $similarity");
    debugPrint("SIMILARITY_EDGE: $SIMILARITY_EDGE");
    String path = similarity > SIMILARITY_EDGE
        ? RoutesList.scannerRecorder
        : RoutesList.scannerComparing;
    if (!mounted) return;
    Navigator.pushNamed(context, path);
  }

  Future<double> getSimilarity() async {
    setState(() {
      isLoading = true;
    });
    try {
      return await methodChannel.invokeMethod('getSimilarity');
    } on PlatformException catch (e) {
      String errorMessage = e.message ?? "Something went wrong";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            textAlign: TextAlign.center,
          ),
        ),
      );
      return 1000;
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  onEvent(event) {
    if (!mounted) return;
    switch (event["type"]) {
      case "scan_selfie_success":
        {
          processNavigation();
        }
        break;
      case "scan_selfie_failed":
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
      appBar: AppBar(title: const Text('Please take a selfie')),
      body: SafeArea(
          minimum: const EdgeInsets.all(0.0),
          child: Stack(
            children: [
              CustomUIKitView(
                viewType: ViewTypes.selfie,
                onCreated: (instance) {
                  instance.initialize();
                  _instance = instance;
                  initEventSubscription();
                },
              ),
              isLoading
                  ? Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      right: 0,
                      child: Container(
                        height: double.infinity,
                        width: double.infinity,
                        color: Colors.black,
                        alignment: Alignment.center,
                        child: const Text('Comparing...',
                            style: TextStyle(color: Colors.white)),
                      ),
                    )
                  : Container()
            ],
          )),
    );
  }
}
