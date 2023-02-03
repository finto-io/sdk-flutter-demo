import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kyc_demo/components/CustomButton.dart';
import 'dart:io' show Platform;

import 'package:flutter_kyc_demo/routes/router_list.dart';

class ScannerResultScreen extends StatefulWidget {
  const ScannerResultScreen({super.key, this.videoRecord});
  final String? videoRecord;
  @override
  State<ScannerResultScreen> createState() => ScannerResultState();
}

class ScannerResultState extends State<ScannerResultScreen> {
  Object? scanResult;
  String errorText = '';
  Map<String, dynamic>? documentsUrls;
  Uint8List? selfie;
  Uint8List? documentBack;
  Uint8List? documentFront;

  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    getResultInfo();
  }

  static const MethodChannel methodChannel =
      MethodChannel('kyc.sdk/resultMethodChannel');

  Future<void> getResultInfo() async {
    setState(() {
      isLoading = true;
    });
    try {
      String scanResponse =
          await methodChannel.invokeMethod('getScannerResult');
      String selfieBase64 = await methodChannel.invokeMethod('getSelfie');
      String documentBackBase64 =
          await methodChannel.invokeMethod('getDocumentBack');
      String documentFrontBase64 =
          await methodChannel.invokeMethod('getDocumentFront');
      String documentsJsonMap =
          await methodChannel.invokeMethod('getDocumentsUrls');
      setState(() {
        scanResult = json.decode(scanResponse);
        selfie = dataFromBase64String(selfieBase64);
        documentBack = dataFromBase64String(documentBackBase64);
        documentFront = dataFromBase64String(documentFrontBase64);
        documentsUrls = json.decode(documentsJsonMap);
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

  void scanAgain() {
    if (mounted) {
      Navigator.popUntil(context, ModalRoute.withName(RoutesList.scannerFront));
    }
  }

  void backToHome() {
    if (mounted) {
      Navigator.popUntil(context, ModalRoute.withName('/'));
    }
  }

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Link copied to clipboard",
            textAlign: TextAlign.center,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double bottomOffset = Platform.isAndroid ? 20.0 : 0.0;
    String text = errorText.isNotEmpty
        ? errorText
        : scanResult != null
            ? scanResult.toString()
            : '';
    String backDocUrl =
        documentsUrls != null ? documentsUrls!["backDocument"] : "";
    String frontDocUrl =
        documentsUrls != null ? documentsUrls!["frontDocument"] : "";
    String selfieUrl = documentsUrls != null ? documentsUrls!["selfie"] : "";
    return Scaffold(
      appBar: AppBar(title: const Text('Scanning result')),
      body: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 20.0),
        child: SingleChildScrollView(
            child: Container(
                alignment: Alignment.center,
                child: !isLoading
                    ? Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: const Text("Scanning result",
                                style: TextStyle(fontSize: 18)),
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Text(text),
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: const Text("Video record url",
                                style: TextStyle(fontSize: 18)),
                          ),
                          Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: GestureDetector(
                                onTap: () {
                                  copyToClipboard(widget.videoRecord ?? "");
                                },
                                child: Text(widget.videoRecord ?? ""),
                              )),
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: const Text("Front side",
                                style: TextStyle(fontSize: 18)),
                          ),
                          Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: GestureDetector(
                                onTap: () {
                                  copyToClipboard(frontDocUrl);
                                },
                                child: Text(frontDocUrl),
                              )),
                          Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: Image.memory(documentFront!)),
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: const Text("Back side",
                                style: TextStyle(fontSize: 18)),
                          ),
                          Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: GestureDetector(
                                onTap: () {
                                  copyToClipboard(backDocUrl);
                                },
                                child: Text(backDocUrl),
                              )),
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Image.memory(documentBack!),
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: const Text("Selfie",
                                style: TextStyle(fontSize: 18)),
                          ),
                          Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: GestureDetector(
                                onTap: () {
                                  copyToClipboard(selfieUrl);
                                },
                                child: Text(selfieUrl),
                              )),
                          Image.memory(selfie!),
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
                label: "Scan Again",
                onPressed: scanAgain,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: CustomButton(
                disabled: isLoading,
                label: "Back to home",
                onPressed: backToHome,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
