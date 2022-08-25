import Flutter
import kyc_sdk

public class VideoRecorderView: NSObject, FlutterPlatformView, VideoViewControllerDelegate {
    
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
        let controller = VideoViewController();
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
    
    public func videoViewRecordSuccess(_ controller: VideoViewController, _ url: String) {
        print("videoViewRecordSuccess")
        self.callback(["type": "videoViewRecordSuccess", "params": url])
    }
    
    public func videoViewRecordFailed(_ controller: VideoViewController, error: Error) {
        print("videoViewRecordFailed")
        self.callback(["type": "videoViewRecordFailed", "params": String(describing: error)])
    }
    
    public func view() -> UIView {
        return self._view
    }
}
