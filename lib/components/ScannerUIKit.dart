import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef ScannerCreateCallback = void Function(
    ScannerUIKitController controller);

enum ViewTypes { front, back, selfie }

extension ParseToString on ViewTypes {
  String toShortString() {
    return this.toString().split('.').last;
  }
}

class ScannerUIKit extends StatefulWidget {
  const ScannerUIKit({
    super.key,
    required this.viewType,
    required this.onCreated,
  });

  final ViewTypes viewType;
  final ScannerCreateCallback onCreated;

  @override
  State<StatefulWidget> createState() => ScannerUIKitState();
}

class ScannerUIKitState extends State<ScannerUIKit> {
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
    if (widget.onCreated == null) {
      return;
    }
    widget
        .onCreated(ScannerUIKitController(id, widget.viewType.toShortString()));
  }
}

class ScannerUIKitController {
  late MethodChannel _channel;

  ScannerUIKitController(int id, String viewType) {
    _channel = MethodChannel('$viewType$id');
  }

  Future<void> initialize() async {
    return _channel.invokeMethod('initialize');
  }
}
