import 'package:flutter/material.dart';
import 'package:flutter_kyc_demo/routes/home/home.screen.dart';
import 'package:flutter_kyc_demo/routes/scanner/scanner.back.screen.dart';
import 'package:flutter_kyc_demo/routes/scanner/scanner.front.screen.dart';
import 'package:flutter_kyc_demo/routes/scanner/scanner.selfie.screen.dart';
import 'package:flutter_kyc_demo/routes/uploader/uploader.screen.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => const HomeScreen(),
      '/uploader': (context) => const UploaderScreen(),
      '/scanner-front': (context) => const ScannerFrontScreen(),
      '/scanner-back': (context) => const ScannerBackScreen(),
      '/scanner-selfie': (context) => const ScannerSelfieScreen(),
    },
  ));
}
