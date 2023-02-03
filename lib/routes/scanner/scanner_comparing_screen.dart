import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kyc_demo/components/CustomButton.dart';
import 'package:flutter_kyc_demo/routes/router_list.dart';

class ScannerComparingScreen extends StatefulWidget {
  const ScannerComparingScreen({super.key});
  @override
  State<ScannerComparingScreen> createState() => ScannerComparingState();
}

class ScannerComparingState extends State<ScannerComparingScreen> {
  bool isLoading = false;
  String errorText = '';
  Uint8List? selfie;
  Uint8List? portrait;

  @override
  void initState() {
    super.initState();
    getUserImages();
  }

  static const MethodChannel methodChannel =
      MethodChannel('kyc.sdk/resultMethodChannel');

  Future<void> getUserImages() async {
    setState(() {
      isLoading = true;
    });
    try {
      String selfieBase64 = await methodChannel.invokeMethod('getSelfie');
      String portraitBase64 =
          await methodChannel.invokeMethod('getDocumentPortrait');
      setState(() {
        selfie = dataFromBase64String(selfieBase64);
        portrait = dataFromBase64String(portraitBase64);
      });
    } on PlatformException catch (e) {
      setState(() {
        errorText = e.message ?? '';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
  }

  void scanId() {
    if (mounted) {
      Navigator.popUntil(context, ModalRoute.withName(RoutesList.scannerFront));
    }
  }

  void scanSelfie() {
    if (mounted) {
      Navigator.popUntil(
          context, ModalRoute.withName(RoutesList.scannerSelfie));
    }
  }

  @override
  Widget build(BuildContext context) {
    double bottomOffset = Platform.isAndroid ? 20.0 : 0.0;
    return Scaffold(
      appBar: AppBar(title: const Text('Taking selfie')),
      body: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 20.0),
        child: SingleChildScrollView(
            child: Container(
                margin: const EdgeInsets.only(top: 40),
                alignment: Alignment.center,
                child: !isLoading
                    ? Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 40),
                            child: const Text("Identify not verified",
                                style: TextStyle(fontSize: 22)),
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 40),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: portrait == null
                                        ? Container()
                                        : Image.memory(selfie!)),
                                const SizedBox(width: 20.0),
                                Expanded(
                                    flex: 1,
                                    child: portrait == null
                                        ? Container()
                                        : Image.memory(portrait!)),
                              ],
                            ),
                          ),
                          const Text(
                              'The photo from your ID and your selfie do not match. Please retake photo or scan ID again.',
                              style: TextStyle(fontSize: 18))
                        ],
                      )
                    : const Text('Loading...'))),
      ),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.fromLTRB(16.0, 0, 16.0, bottomOffset),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Flexible(
              child: CustomButton(
                disabled: isLoading,
                label: "Scan ID again",
                onPressed: scanId,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: CustomButton(
                disabled: isLoading,
                label: "Scan selfie again",
                onPressed: scanSelfie,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
