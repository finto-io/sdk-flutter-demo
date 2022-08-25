// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import UIKit
import Flutter
import kyc_sdk
import DotDocument
import MobileCoreServices
import UniformTypeIdentifiers
import Foundation
import WebKit

public class WebviewFactory : NSObject, FlutterPlatformViewFactory {
    let controller: FlutterViewController
    
    init(controller: FlutterViewController) {
        self.controller = controller
    }
    
    public func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        let channel = FlutterMethodChannel(
            name: "webview" + String(viewId),
            binaryMessenger: controller.binaryMessenger
        )
        return MyWebview(frame, viewId: viewId, channel: channel, args: args)
    }
}

public class MyWebview: NSObject, FlutterPlatformView, WKScriptMessageHandler, WKNavigationDelegate {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
    }

    let frame: CGRect
    let viewId: Int64
    let channel: FlutterMethodChannel
    let webview: WKWebView
    
    init(_ frame: CGRect, viewId: Int64, channel: FlutterMethodChannel, args: Any?) {
        self.frame = frame
        self.viewId = viewId
        self.channel = channel
        
        let config = WKWebViewConfiguration()
        let webview = WKWebView(frame: frame, configuration: config)

        self.webview = webview

        super.init()
        
        channel.setMethodCallHandler({
            (call: FlutterMethodCall, result: FlutterResult) -> Void in
            if (call.method == "loadUrl") {
                let url = call.arguments as! String
                webview.load(URLRequest(url: URL(string: url)!))
            }
        })
    }
    
    public func view() -> UIView {
        return self.webview
    }
}


enum ChannelName {
    static let uploaderMethodChannel = "samples.flutter.io/uploaderMethodChannel"
    static let uploaderEventChannel = "samples.flutter.io/uploaderEventChannel"
    static let scannerMethodChannel = "samples.flutter.io/scannerMethodChannel"
}

@UIApplicationMain
@objc class AppDelegate:
    FlutterAppDelegate,
    FlutterStreamHandler,
    FilePickerDelegate,
    DocumentScanFrontViewControllerDelegate,
    DocumentScanBackViewControllerDelegate,
    SelfieAutoCaptureViewControllerDelegate{
    
    private var eventSink: FlutterEventSink?
    var ob:Onboarding?
    var navigationController: UINavigationController!
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            GeneratedPluginRegistrant.register(with: self)
            
            
            guard let controller = window?.rootViewController as? FlutterViewController else {
                fatalError("rootViewController is not type FlutterViewController")
            }
            
            let webviewFactory = WebviewFactory(controller: controller)
            registrar(forPlugin: "webview")?.register(webviewFactory, withId: "webview")
            
            self.navigationController = UINavigationController(rootViewController: controller)
            self.window.rootViewController = self.navigationController
            self.navigationController.setNavigationBarHidden(true, animated: true)
            self.window.makeKeyAndVisible()
            
            self.initBaeSdk()
            
            // Uploader channels
            let uploaderMethodChannel = FlutterMethodChannel(name: ChannelName.uploaderMethodChannel,
                                                             binaryMessenger: controller.binaryMessenger)
            
            let uploaderEventChannel = FlutterEventChannel(name: ChannelName.uploaderEventChannel,
                                                           binaryMessenger: controller.binaryMessenger)
            
            uploaderMethodChannel.setMethodCallHandler({
                [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
                guard call.method == "initUploader" else {
                    result(FlutterMethodNotImplemented)
                    return
                }
                self?.initUploader()
            })
            
            
            
            uploaderEventChannel.setStreamHandler(self)
            
            // Scanner channels
            let scannerMethodChannel = FlutterMethodChannel(name: ChannelName.scannerMethodChannel,
                                                            binaryMessenger: controller.binaryMessenger)
            
            scannerMethodChannel.setMethodCallHandler({
                [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
                guard call.method == "initScanner" else {
                    result(FlutterMethodNotImplemented)
                    return
                }
                self?.initScanner()
            })
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
    
    
    private func initBaeSdk() {
        if let url = Bundle.main.url(forResource: "iengine", withExtension: "lic") {
            let URL_PATH: String = "https://bl4-dev-02.baelab.net/api/BAF3E974-52AA-7598-FF04-56945EF93500/48EE4790-8AEF-FEA5-FFB6-202374C61700";
            do {
                let license = try Data(contentsOf: url)
                ob = Onboarding(license:license, baseURL: URL(string: URL_PATH)!)
                ob?.initialize()
            } catch {
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
    
    public func onListen(withArguments arguments: Any?,
                         eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        return nil
    }
    
    func filePickerSuccess(_ controller: FilePicker, _ urls: [URL]) {
        guard let eventSink = eventSink else {
            return
        }
        let res: String = String(describing: urls[0])
        eventSink(["path": res, "uploading": false, "error": nil])
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
        eventSink(["result": "", "uploading": true, "error": nil])
    }
    
    
    func initScanner() {
//        FLNativeView.controller.viewDidLoad()
//        let controller = DocumentScanFrontViewController()
//        controller.delegate = self
//        self.navigationController.pushViewController(controller, animated: true)
    }
    
    func documentScanFrontSuccess(_ controller: DocumentScanFrontViewController) {
        let controller = DocumentScanBackViewController()
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func documentScanFrontFailed(_ controller: DocumentScanFrontViewController, error: DocumentError) {
        controller.restart()
    }
    
    func documentScanBackSuccess(_ controller: DocumentScanBackViewController) {
        let controller = SelfieAutoCaptureViewController();
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func documentScanBackFailed(_ controller: DocumentScanBackViewController, error: DocumentError) {
        print(error.code)
        //        if error.code == "NO_CORNERS" {
        //            controller.restart()
        //            return
        //        }
        //        if error.code == "PAGE_DOESNT_MATCH_DOCUMENT_TYPE_OF_PREVIOUS_PAGE" {
        //            let controller = DocumentScanFrontViewController()
        //            controller.delegate = self
        //        }
    }
    
    func selfieAutoCaptureSuccess(_ controller: SelfieAutoCaptureViewController) {
        DispatchQueue.main.async {
            self.ob?.inspectDocument(){ res in
                DispatchQueue.main.async {
                    do {
                        let encoder = JSONEncoder()
                        encoder.outputFormatting = .prettyPrinted
                        let data = try encoder.encode(res)
                        guard let jsonString = String(data: data, encoding: .utf8) else { return }
                        print(jsonString)
                        
                    } catch {
                        print("Failed to encode JSON")
                    }
                }
            }
            //            self.navigationController?.popToViewController(self, animated: true)
        }
    }
    
    func selfieAutoCaptureFailed(_ controller: SelfieAutoCaptureViewController, error: SelfieError) {
        DispatchQueue.main.async {
            if error.code == .noFaceFound {
                controller.restart()
                return
            }
            self.selfieAutoCaptureSuccess(controller)
        }
    }
    
    
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        print("onCancel")
        eventSink = nil
        return nil
    }
    
}



