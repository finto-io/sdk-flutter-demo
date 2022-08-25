import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_kyc_demo/components/CustomButton.dart';

class Permissions {
  const Permissions();
  Future<void> checkCameraPermission(BuildContext context,
      VoidCallback onSuccess, VoidCallback onError) async {
    late Permission permission;
    if (Platform.isIOS) {
      permission = Permission.camera;
    } else {
      permission = Permission.storage;
    }
    final status = await permission.request();
    if (status.isGranted) {
      onSuccess.call();
    } else {
      onError.call();
    }
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  void showMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Further use requires permission to use the camera.\nGo to settings and allow the required permission.",
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Demo'),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CustomButton(
              label: 'Uploader',
              onPressed: () {
                Navigator.pushNamed(context, '/uploader');
              },
            ),
            const Divider(),
            CustomButton(
              label: 'Scan documents',
              onPressed: () {
                const Permissions().checkCameraPermission(context, () {
                  if (mounted) {
                    Navigator.pushNamed(context, '/scanner-front');
                  }
                }, showMessage);
              },
            ),
            const Divider(),
            CustomButton(
              label: 'Video recorder',
              onPressed: () {
                Navigator.pushNamed(context, '/video-recorder');
              },
            ),
          ],
        ),
      ),
    );
  }
}
