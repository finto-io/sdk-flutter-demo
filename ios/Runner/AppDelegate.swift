import UIKit
import Flutter
import kyc_sdk
import DotDocument
import MobileCoreServices
import UniformTypeIdentifiers
import Foundation
import WebKit

@UIApplicationMain
@objc class AppDelegate:
    FlutterAppDelegate,
    FlutterStreamHandler,
    FilePickerDelegate
{
    private var eventSink: FlutterEventSink?
    var urlString: String = ""
    var API: Api!
    var kyc: Onboarding?
    var navigationController: UINavigationController!
    
    override init() {
        super.init()
        guard let infoDictionary: [String: Any] = Bundle.main.infoDictionary else { return }
        guard let KycUrl: String = infoDictionary["KycUrl"] as? String else { return }
        self.urlString = KycUrl
        self.API = Api(URL(string: KycUrl))
    }
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            GeneratedPluginRegistrant.register(with: self)
            
            guard let controller = window?.rootViewController as? FlutterViewController else {
                fatalError("rootViewController is not type FlutterViewController")
            }
            
            let scannerFactoryFront = Factory(controller: controller, viewType: ViewTypes.front)
            let scannerFactoryBack = Factory(controller: controller, viewType: ViewTypes.back)
            let scannerFactorySelfie = Factory(controller: controller, viewType: ViewTypes.selfie)
            let scannerFactoryRecorder = Factory(controller: controller, viewType: ViewTypes.recorder)
            
            registrar(forPlugin: ViewTypes.front)?.register(scannerFactoryFront, withId: ViewTypes.front)
            registrar(forPlugin: ViewTypes.back)?.register(scannerFactoryBack, withId: ViewTypes.back)
            registrar(forPlugin: ViewTypes.selfie)?.register(scannerFactorySelfie, withId: ViewTypes.selfie)
            registrar(forPlugin: ViewTypes.recorder)?.register(scannerFactoryRecorder, withId: ViewTypes.recorder)
            
            self.initializeSDK()
            
            self.navigationController = UINavigationController(rootViewController: controller)
            self.window.rootViewController = self.navigationController
            self.navigationController.setNavigationBarHidden(true, animated: true)
            self.window.makeKeyAndVisible()
            
            let uploaderMethodChannel = FlutterMethodChannel(name: ChannelNames.uploaderMethodChannel,
                                                             binaryMessenger: controller.binaryMessenger)
            uploaderMethodChannel.setMethodCallHandler({
                [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
                guard call.method == "initUploader" else {
                    result(FlutterMethodNotImplemented)
                    return
                }
                self?.initUploader()
            })
            let uploaderEventChannel = FlutterEventChannel(name: ChannelNames.uploaderEventChannel,
                                                           binaryMessenger: controller.binaryMessenger)
            uploaderEventChannel.setStreamHandler(self)
            
            
            let resultMethodChannel = FlutterMethodChannel(name: ChannelNames.resultMethodChannel,
                                                           binaryMessenger: controller.binaryMessenger)
            resultMethodChannel.setMethodCallHandler({
                [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
                
                switch call.method {
                case "getScannerResult":
                    self?.getScannerResult(result: result)
                    return
                case "getDocumentBack":
                    self?.getDocumentBack(result: result)
                    return
                case "getDocumentFront":
                    self?.getDocumentFront(result: result)
                    return
                case "getDocumentPortrait":
                    self?.getDocumentPortrait(result: result)
                    return
                case "getSelfie":
                    self?.getSelfie(result: result)
                    return
                case "getSimilarity":
                    self?.getSimilarity(result: result)
                    return
                case "getDocumentsUrls":
                    self?.getDocumentsUrls(result: result)
                    return
                default:
                    result(FlutterMethodNotImplemented)
                    return
                }
            })
            
            
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
    
    
    private func initializeSDK() {
        if let url = Bundle.main.url(forResource: "iengine", withExtension: "lic") {
            do {
                let license = try Data(contentsOf: url)
                kyc = Onboarding(license:license, baseURL: URL(string: urlString)!)
                kyc?.initialize()
            } catch {
                print("Failed to initialize sdk")
                return
            }
        }
    }
    
    private func initUploader() {
        let controller = getPickerController()
        controller.delegate = self
        self.navigationController.present(controller, animated: true)
    }
    
    private func getPickerController() -> FilePicker {
        if #available(iOS 14, *) {
            return FilePicker(documentTypes: [UTType.image])
        } else {
            return FilePicker(documentTypes: [kUTTypePDF as String])
        }
    }
    
    func filePickerSuccess(_ controller: FilePicker, _ urls: [URL]) {
        guard let eventSink = eventSink else {
            return
        }
        eventSink(["type": ChannelEventTypes.upload_success, "data": String(describing: urls[0])])
    }
    
    func filePickerFailed(_ controller: FilePicker, error: BaeError) {
        guard let eventSink = eventSink else {
            return
        }
        eventSink(["type": ChannelEventTypes.upload_failed, "data": error.message])
    }
    
    func filePickerUploadingStarted(_ controller: FilePicker) {
        guard let eventSink = eventSink else {
            return
        }
        eventSink(["type": ChannelEventTypes.upload_started, "data": ""])
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
