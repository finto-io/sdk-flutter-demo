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
    private let URL_PATH = "https://bl4-dev-02.baelab.net/api/BAF3E974-52AA-7598-FF04-56945EF93500/48EE4790-8AEF-FEA5-FFB6-202374C61700"
    private var eventSink: FlutterEventSink?
    var kyc:Onboarding?
    var navigationController: UINavigationController!
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            GeneratedPluginRegistrant.register(with: self)
            
            guard let controller = window?.rootViewController as? FlutterViewController else {
                fatalError("rootViewController is not type FlutterViewController")
            }
            
            let scannerFactoryFront = ScannerFactory(controller: controller, scannerType: ScannerNames.front)
            let scannerFactoryBack = ScannerFactory(controller: controller, scannerType: ScannerNames.back)
            let scannerFactorySelfie = ScannerFactory(controller: controller, scannerType: ScannerNames.selfie, getScanningResult: getScanningResult)
            registrar(forPlugin: ScannerNames.front)?.register(scannerFactoryFront, withId: ScannerNames.front)
            registrar(forPlugin: ScannerNames.back)?.register(scannerFactoryBack, withId: ScannerNames.back)
            registrar(forPlugin: ScannerNames.selfie)?.register(scannerFactorySelfie, withId: ScannerNames.selfie)
            
            self.navigationController = UINavigationController(rootViewController: controller)
            self.window.rootViewController = self.navigationController
            self.navigationController.setNavigationBarHidden(true, animated: true)
            self.window.makeKeyAndVisible()
            
            self.initializeSDK()
            
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
            
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
    
    
    private func initializeSDK() {
        if let url = Bundle.main.url(forResource: "iengine", withExtension: "lic") {
            do {
                let license = try Data(contentsOf: url)
                kyc = Onboarding(license:license, baseURL: URL(string: URL_PATH)!)
                kyc?.initialize()
            } catch {
                print("Failed to initialize sdk")
                return
            }
        }
    }
    
    private func getScanningResult(_ cb:@escaping (_ res: String)->Void) -> Void {
        self.kyc?.inspectDocument(){ res in
            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let data = try encoder.encode(res)
                guard let jsonString = String(data: data, encoding: .utf8) else { return }
                cb(jsonString)
            } catch {
                print("Failed to encode JSON")
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
        let res: String = String(describing: urls[0])
        eventSink(["path": res, "uploading": false, "error": ""])
    }
    
    func filePickerFailed(_ controller: FilePicker, error: FilePickerError) {
        guard let eventSink = eventSink else {
            return
        }
        eventSink(["path": "", "uploading": false, "error": error])
    }
    
    func filePickerUploadingStarted(_ controller: FilePicker) {
        guard let eventSink = eventSink else {
            return
        }
        eventSink(["result": "", "uploading": true, "error": ""])
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



