import 'package:flutter/material.dart';
import 'package:flutter_kyc_demo/routes/home/home.screen.dart';
import 'package:flutter_kyc_demo/routes/uploader/uploader.screen.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => const HomeScreen(),
      '/uploader': (context) => const UploaderScreen(),
    },
  ));
}
