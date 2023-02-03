import Flutter
import kyc_sdk

public class VideoRecorderView: NSObject, FlutterPlatformView, VideoViewControllerDelegate {
    
    let viewId: Int64
    let frame: CGRect
    let channel: FlutterMethodChannel
    let controller: VideoViewController
    let _view: UIView
    var callback: (([String: String]) -> Void)
    
    init(_ frame: CGRect, viewId: Int64, channel: FlutterMethodChannel, args: Any?, callback: @escaping (([String: String]) -> Void)) {
        self.frame = frame
        self.viewId = viewId
        self.channel = channel
        self.callback = callback
        let controller = VideoViewController();
        self._view = controller.view
        self.controller = controller
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
        self.callback(["type": ChannelEventTypes.record_success, "data": url])
    }
    
    public func videoViewRecordFailed(_ controller: VideoViewController, _ error: BaeError) {
        self.callback(["type": ChannelEventTypes.record_failed, "data": String(describing: error.message)])
    }
    
    public func view() -> UIView {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.controller.button.frame.origin = CGPoint(
                x: self.controller.view.frame.size.width / 2 - self.controller.button.frame.size.width / 2,
                y: self.controller.view.frame.size.height - self.controller.button.frame.size.height - 30
            )
        }
        return self._view
    }
}
