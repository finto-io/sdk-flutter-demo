import 'package:flutter/material.dart';
import 'package:flutter_kyc_demo/routes/home/home.screen.dart';
import 'package:flutter_kyc_demo/routes/scanner/scanner.back.screen.dart';
import 'package:flutter_kyc_demo/routes/scanner/scanner.front.screen.dart';
import 'package:flutter_kyc_demo/routes/scanner/scanner.result.screen.dart';
import 'package:flutter_kyc_demo/routes/scanner/scanner.selfie.screen.dart';
import 'package:flutter_kyc_demo/routes/uploader/uploader.screen.dart';
import 'package:flutter_kyc_demo/routes/videoRecorder/video.recorder.result.screen.dart';
import 'package:flutter_kyc_demo/routes/videoRecorder/video.recorder.screen.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => const HomeScreen(),
      '/uploader': (context) => const UploaderScreen(),
      '/scanner-front': (context) => const ScannerFrontScreen(),
      '/scanner-back': (context) => const ScannerBackScreen(),
      '/scanner-selfie': (context) => const ScannerSelfieScreen(),
      '/scanner-result': (context) => const ScannerResultScreen(),
      '/video-recorder': (context) => const VideoRecorderScreen(),
      '/video-recorder-result': (context) => const VideoRecorderResultScreen(),
    },
  ));
}
