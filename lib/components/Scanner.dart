import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef ScannerCreateCallback = void Function(ScannerController controller);

enum ViewTypes { front, back, selfie }

extension ParseToString on ViewTypes {
  String toShortString() {
    return this.toString().split('.').last;
  }
}

class Scanner extends StatefulWidget {
  const Scanner({
    super.key,
    required this.viewType,
    required this.onScannerCreated,
  });

  final ViewTypes viewType;
  final ScannerCreateCallback onScannerCreated;

  @override
  State<StatefulWidget> createState() => ScannerState();
}

class ScannerState extends State<Scanner> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: widget.viewType.toShortString(),
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: widget.viewType.toShortString(),
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }
    return Text(
        '$defaultTargetPlatform is not yet supported by the map view plugin');
  }

  void _onPlatformViewCreated(int id) {
    if (widget.onScannerCreated == null) {
      return;
    }
    widget.onScannerCreated(
        ScannerController(id, widget.viewType.toShortString()));
  }
}

class ScannerController {
  late MethodChannel _channel;

  ScannerController(int id, String viewType) {
    _channel = MethodChannel('$viewType$id');
  }

  Future<void> initScanner(String str) async {
    return _channel.invokeMethod('initScanner', str);
  }
}
