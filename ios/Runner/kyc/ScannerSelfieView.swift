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
            if (call.method == "initialize") {
                controller.restart()
            }
        })
    }
    
    
    public func selfieAutoCaptureSuccess(_ controller: SelfieAutoCaptureViewController) {
        self.callback(["type": ChannelEventTypes.scan_selfie_success, "data": ""])
    }
    
    public func selfieAutoCaptureFailed(_ controller: SelfieAutoCaptureViewController, _ error: BaeError) {
        self.callback(["type": ChannelEventTypes.scan_selfie_failed, "data": String(describing: error.message)])
    }
    
    public func view() -> UIView {
        return self._view
    }
}
