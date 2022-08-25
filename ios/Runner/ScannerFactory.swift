import Flutter

public class ScannerFactory: NSObject, FlutterPlatformViewFactory, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    let controller: FlutterViewController
    let scannerType: String
    let getResult: () -> String
    
    init(controller: FlutterViewController, scannerType: String, getResult: @escaping () -> String ) {
        self.controller = controller
        self.scannerType = scannerType
        self.getResult = getResult
    }
    
    public func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        let channel = FlutterMethodChannel(
            name: scannerType + String(viewId),
            binaryMessenger: controller.binaryMessenger
        )
        let eventChannel = FlutterEventChannel(name: ChannelNames.scannerEventChannel,
                                               binaryMessenger: controller.binaryMessenger)
        eventChannel.setStreamHandler(self)
        print("scannerType", scannerType);
        if(scannerType == ScannerNames.front) {
            return ScannerFrontView(frame, viewId: viewId, channel: channel, args: args, callback: callback)
        } else if (scannerType == ScannerNames.back) {
            return ScannerBackView(frame, viewId: viewId, channel: channel, args: args, callback: callback)
        } else {
            return ScannerSelfieView(frame, viewId: viewId, channel: channel, args: args, callback: callback)
        }
    }
    
    func callback(arg: [String: String]) {
        guard let eventSink = eventSink else {
            print("dispatcher missing")
            return
        }
        let res = getResult()
        print(res)
        eventSink(arg)
    }
    
    public func onListen(withArguments arguments: Any?,
                         eventSink: @escaping FlutterEventSink) -> FlutterError? {
        print("Scanner events onListen")
        self.eventSink = eventSink
        
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        print("Scanner events onCancel")
        eventSink = nil
        return nil
    }
}
