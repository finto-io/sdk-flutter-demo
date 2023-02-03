import Flutter

public class Factory: NSObject, FlutterPlatformViewFactory, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    let controller: FlutterViewController
    let viewType: String
    
    init(
        controller: FlutterViewController,
        viewType: String
    ) {
        self.viewType = viewType
        self.controller = controller
    }
    
    public func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        let channel = FlutterMethodChannel(
            name: viewType + String(viewId),
            binaryMessenger: controller.binaryMessenger
        )
        
        let channelName = getChannelName()
        
        let eventChannel = FlutterEventChannel(name: channelName,
                                               binaryMessenger: controller.binaryMessenger)
        eventChannel.setStreamHandler(self)
        
        switch viewType {
        case ViewTypes.front:
            return ScannerFrontView(frame, viewId: viewId, channel: channel, args: args, callback: callback)
        case ViewTypes.back:
            return ScannerBackView(frame, viewId: viewId, channel: channel, args: args, callback: callback)
        case ViewTypes.selfie:
            return ScannerSelfieView(frame, viewId: viewId, channel: channel, args: args, callback: callback)
        case ViewTypes.recorder:
            return VideoRecorderView(frame, viewId: viewId, channel: channel, args: args, callback: callback)
        default:
            fatalError("Incompatible viewType with return type FlutterPlatformView")
        }
    }
    
    func getChannelName() -> String {
        switch viewType {
        case ViewTypes.front:
            return ChannelNames.scannerFrontEventChannel
        case ViewTypes.back:
            return ChannelNames.scannerBackEventChannel
        case ViewTypes.selfie:
            return ChannelNames.scannerSelfieEventChannel
        case ViewTypes.recorder:
              return ChannelNames.recorderEventChannel
        default:
            fatalError("Incompatible viewType for event channel initialization")
        }
    }
    
    func callback(data: [String: String]) {
        guard let eventSink = eventSink else {
            return
        }
        eventSink(data)
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
