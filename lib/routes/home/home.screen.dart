import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_kyc_demo/components/customButton.dart';

class Permissions {
  const Permissions();
  Future<void> checkPermission(BuildContext context, VoidCallback onSuccess,
      VoidCallback onError) async {
    if (await Permission.camera.request().isGranted) {
      onSuccess.call();
    } else {
      final status = await Permission.camera.request();
      if (status.isGranted) {
        onSuccess.call();
      } else {
        onError.call();
      }
    }
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  // const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  void checkPermission() {
    const Permissions()
        .checkPermission(context, navigateToScanner, showMessage);
  }

  void navigateToScanner() {
    if (mounted) {
      Navigator.pushNamed(context, '/scanner-front');
    }
  }

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
              onPressed: checkPermission,
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
