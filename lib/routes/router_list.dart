import 'package:flutter/material.dart';
import 'package:flutter_kyc_demo/routes/home/home_screen.dart';
import 'package:flutter_kyc_demo/routes/scanner/scanner_back_screen.dart';
import 'package:flutter_kyc_demo/routes/scanner/scanner_comparing_screen.dart';
import 'package:flutter_kyc_demo/routes/scanner/scanner_front_screen.dart';
import 'package:flutter_kyc_demo/routes/scanner/scanner_recorder_screen.dart';
import 'package:flutter_kyc_demo/routes/scanner/scanner_result_screen.dart';
import 'package:flutter_kyc_demo/routes/scanner/scanner_selfie_screen.dart';
import 'package:flutter_kyc_demo/routes/uploader/uploader_screen.dart';
import 'package:flutter_kyc_demo/routes/videoRecorder/video_recorder_result_screen.dart';
import 'package:flutter_kyc_demo/routes/videoRecorder/video_recorder_screen.dart';

class RoutesList {
  static const home = '/';

  static const uploader = './uploader';

  static const videoRecorder = './video_recorder';
  static const videoRecorderResult = './video_recorder_result';

  static const scannerFront = '/scanner_front';
  static const scannerBack = '/scanner_back';
  static const scannerSelfie = '/scanner_selfie';
  static const scannerResult = '/scanner_result';
  static const scannerRecorder = '/scanner_recorder';
  static const scannerComparing = '/scanner_comparing';
}

class Routes {
  static Map<String, WidgetBuilder> getAll() => _routes;
  static final Map<String, WidgetBuilder> _routes = {
    RoutesList.home: ((context) => const HomeScreen()),
    RoutesList.uploader: ((context) => const UploaderScreen()),
    RoutesList.videoRecorder: ((context) => const VideoRecorderScreen()),
    RoutesList.videoRecorderResult: ((context) =>
        const VideoRecorderResultScreen()),
    RoutesList.scannerFront: ((context) => const ScannerFrontScreen()),
    RoutesList.scannerBack: ((context) => const ScannerBackScreen()),
    RoutesList.scannerSelfie: ((context) => const ScannerSelfieScreen()),
    RoutesList.scannerResult: ((context) => const ScannerResultScreen()),
    RoutesList.scannerRecorder: ((context) => const ScannerRecorderScreen()),
    RoutesList.scannerComparing: ((context) => const ScannerComparingScreen()),
  };
}
