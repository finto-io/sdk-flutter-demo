import Flutter
import kyc_sdk

public class ScannerSelfieView: NSObject, FlutterPlatformView, SelfieAutoCaptureViewControllerDelegate {
    
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
        let controller = SelfieAutoCaptureViewController();
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
    
    
    public func selfieAutoCaptureSuccess(_ controller: SelfieAutoCaptureViewController) {
        self.callback(["type": "scanSelfieSuccess", "params": ""])
    }
    
    public func selfieAutoCaptureFailed(_ controller: SelfieAutoCaptureViewController, error: SelfieError) {
        self.callback(["type": "scanSelfieFailed", "params": String(describing: error.code)])
    }
    
    public func view() -> UIView {
        return self._view
    }
}
