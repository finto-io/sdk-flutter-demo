import Flutter

public class ScannerFactory: NSObject, FlutterPlatformViewFactory, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    let controller: FlutterViewController
    let scannerType: String
    let getScanningResult: ((_ cb: @escaping (_ res: String) -> Void)-> Void)?
    
    init(
        controller: FlutterViewController,
        scannerType: String,
        getScanningResult: ((_ cb:@escaping (_ res: String) -> Void) -> Void)?  = nil
    ) {
        self.controller = controller
        self.scannerType = scannerType
        self.getScanningResult = getScanningResult
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
        
        let channelName = getChannelName()
        
        let eventChannel = FlutterEventChannel(name: channelName,
                                               binaryMessenger: controller.binaryMessenger)
        eventChannel.setStreamHandler(self)
        if(scannerType == ScannerNames.front) {
            return ScannerFrontView(frame, viewId: viewId, channel: channel, args: args, callback: callback)
        } else if (scannerType == ScannerNames.back) {
            return ScannerBackView(frame, viewId: viewId, channel: channel, args: args, callback: callback)
        } else {
            return ScannerSelfieView(frame, viewId: viewId, channel: channel, args: args, callback: callback)
        }
    }
    
    func getChannelName() -> String {
        switch scannerType {
        case ScannerNames.front:
            return ChannelNames.scannerFrontEventChannel
        case ScannerNames.back:
            return ChannelNames.scannerBackEventChannel
        case ScannerNames.selfie:
            return ChannelNames.scannerSelfieChannel
        default:
            return ""
        }
    }
    
    func callback(data: [String: String]) {
        guard let eventSink = eventSink else {
            return
        }
        
        guard let getScanningResult = getScanningResult else {
            eventSink(data)
            return
        }
        
        getScanningResult() { res in
            var _data = data
            _data.updateValue(res, forKey: "params")
            eventSink(_data)
        }
    }
    
    public func onListen(withArguments arguments: Any?,
                         eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}
