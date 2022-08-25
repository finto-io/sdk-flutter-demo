import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef WebViewCreatedCallback = void Function(WebViewController controller);

class WebView extends StatefulWidget {
  const WebView({
    super.key,
    required this.onWebViewCreated,
  });

  final WebViewCreatedCallback onWebViewCreated;

  @override
  State<StatefulWidget> createState() => WebViewState();
}

class WebViewState extends State<WebView> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'webview',
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'webview',
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }
    return Text(
        '$defaultTargetPlatform is not yet supported by the map view plugin');
  }

  void _onPlatformViewCreated(int id) {
    if (widget.onWebViewCreated == null) {
      return;
    }
    widget.onWebViewCreated(WebViewController(id));
  }
}

class WebViewController {
  late MethodChannel _channel;

  WebViewController(int id) {
    _channel = MethodChannel('webview$id');
  }

  Future<void> loadUrl(String url) async {
    return _channel.invokeMethod('loadUrl', url);
  }
}
