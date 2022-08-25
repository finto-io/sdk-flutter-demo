import 'package:flutter/material.dart';
import 'package:flutter_kyc_demo/components/CustomButton.dart';

class ScannerResultScreen extends StatefulWidget {
  const ScannerResultScreen({super.key, this.result});
  final String? result;
  @override
  State<ScannerResultScreen> createState() => ScannerResultState();
}

class ScannerResultState extends State<ScannerResultScreen> {
  void scanAgain() {
    if (mounted) {
      Navigator.popUntil(context, ModalRoute.withName('/scanner-front'));
    }
  }

  void backToHome() {
    if (mounted) {
      Navigator.popUntil(context, ModalRoute.withName('/'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanning result')),
      body: SafeArea(
        minimum: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            SingleChildScrollView(
              child: Expanded(
                child: Container(
                    alignment: Alignment.center,
                    child: Text(widget.result ?? "Result not available")),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Flexible(
                  child: CustomButton(
                    label: "Scan Again",
                    onPressed: scanAgain,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: CustomButton(
                    label: "Back to home screen",
                    onPressed: backToHome,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
