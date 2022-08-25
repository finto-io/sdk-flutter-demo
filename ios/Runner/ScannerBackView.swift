import Flutter
import kyc_sdk

public class ScannerBackView: NSObject, FlutterPlatformView, DocumentScanBackViewControllerDelegate {
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
        let controller = DocumentScanBackViewController();
        self._view = controller.view
        super.init()
        controller.delegate = self
        channel.setMethodCallHandler({
            (call: FlutterMethodCall, result: FlutterResult) -> Void in
            if (call.method == "initScanner") {
                controller.restart()
            }
        })
    }
    
    public func documentScanBackSuccess(_ controller: DocumentScanBackViewController) {
        self.callback(["type": "scanBackSuccess", "params": ""])
    }
    
    public func documentScanBackFailed(_ controller: DocumentScanBackViewController, error: DocumentError) {
        self.callback(["type": "scanBackFailed", "params": error.code])
    }
    
    public func view() -> UIView {
        return self._view
    }
}
