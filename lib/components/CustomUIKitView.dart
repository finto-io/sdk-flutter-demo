import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kyc_demo/enums/enums.dart';

typedef CustomUIKitCallback = void Function(CustomUIKitController controller);

class CustomUIKitView extends StatefulWidget {
  const CustomUIKitView({
    Key? key,
    required this.viewType,
    required this.onCreated,
  }) : super(key: key);

  final ViewTypes viewType;
  final CustomUIKitCallback onCreated;

  @override
  State<StatefulWidget> createState() => ScannerUIKitState();
}

class ScannerUIKitState extends State<CustomUIKitView> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      const Map<String, dynamic> creationParams = <String, dynamic>{};

      return PlatformViewLink(
        viewType: widget.viewType.parse(),
        surfaceFactory: (context, controller) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
        onCreatePlatformView: (params) {
          return PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            viewType: widget.viewType.parse(),
            layoutDirection: TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onFocus: () {
              params.onFocusChanged(true);
            },
          )
            ..addOnPlatformViewCreatedListener((int id) {
              _onPlatformViewCreated(id);
              params.onPlatformViewCreated(id);
            })
            ..create();
        },
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: widget.viewType.parse(),
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
    widget.onCreated(CustomUIKitController(id, widget.viewType.parse()));
  }
}

class CustomUIKitController {
  late MethodChannel _channel;

  CustomUIKitController(int id, String viewType) {
    _channel = MethodChannel('$viewType$id');
  }

  Future<void> initialize() async {
    return _channel.invokeMethod('initialize');
  }

  Future<void> restart() async {
    return _channel.invokeMethod('restart');
  }
}
