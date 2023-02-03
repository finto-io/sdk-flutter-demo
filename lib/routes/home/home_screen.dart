import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_kyc_demo/routes/router_list.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_kyc_demo/components/customButton.dart';

class Permissions {
  const Permissions();
  Future<bool> checkPermission(BuildContext context) async {
    if (await Permission.camera.request().isGranted) {
      return true;
    } else {
      final status = await Permission.camera.request();
      if (status.isGranted) {
        return true;
      } else {
        return false;
      }
    }
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  void checkPermission(route) {
    const Permissions().checkPermission(context).then((value) => {
          if (value) {navigateTo(route)} else {showMessage()}
        });
  }

  void navigateTo(String route) {
    if (mounted) {
      Navigator.pushNamed(context, route);
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
                checkPermission(RoutesList.uploader);
              },
            ),
            const Divider(),
            CustomButton(
              label: 'Scan documents',
              onPressed: () {
                checkPermission(RoutesList.scannerFront);
              },
            ),
            const Divider(),
            CustomButton(
              label: 'Video recorder',
              onPressed: () {
                checkPermission(RoutesList.videoRecorder);
              },
            ),
          ],
        ),
      ),
    );
  }
}
