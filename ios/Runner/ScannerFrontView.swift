import Flutter
import kyc_sdk

public class ScannerFrontView: NSObject, FlutterPlatformView, DocumentScanFrontViewControllerDelegate {
    let viewId: Int64
    let frame: CGRect
    let channel: FlutterMethodChannel
    let _view: UIView
    var callback: (([String: String]) -> Void)
    
    init(_ frame: CGRect, viewId: Int64, channel: FlutterMethodChannel, args: Any?, callback: @escaping (([String: String]) -> Void)) {
        self.frame = frame
        self.viewId = viewId
        self.channel = channel
        self.callback = callback
        let controller = DocumentScanFrontViewController();
        self._view = controller.view
        super.init()
        controller.delegate = self
        channel.setMethodCallHandler({
            (call: FlutterMethodCall, result: FlutterResult) -> Void in
            if (call.method == "initialize") {
                controller.restart()
            }
        })
    }
    
    public func documentScanFrontSuccess(_ controller: DocumentScanFrontViewController) {
        self.callback(["type": ChannelEventTypes.scan_front_success, "data": ""])
    }
    
    public func documentScanFrontFailed(_ controller: DocumentScanFrontViewController, error: DocumentError) {
        self.callback(["type": ChannelEventTypes.scan_front_failed, "data": error.code])
    }
    
    public func view() -> UIView {
        return self._view
    }
}
