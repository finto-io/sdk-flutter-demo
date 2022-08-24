import 'package:flutter/material.dart';
import 'package:flutter_kyc_demo/components/CustomButton.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('KYC Demo'),
        ),
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Center(
              child: CustomButton(
            label: 'Uploader',
            onPressed: () {
              Navigator.pushNamed(context, '/uploader');
            },
          ))
        ]));
  }
}
