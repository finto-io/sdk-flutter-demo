// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import UIKit
import Flutter
import kyc_sdk
import DotDocument
import MobileCoreServices
import UniformTypeIdentifiers

enum ChannelName {
    static let uploaderMethodChannel = "samples.flutter.io/uploaderMethodChannel"
    static let uploaderEventChannel = "samples.flutter.io/uploaderEventChannel"
}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler, FilePickerDelegate {
    
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
            
            self.navigationController = UINavigationController(rootViewController: controller)
            self.window.rootViewController = self.navigationController
            self.navigationController.setNavigationBarHidden(true, animated: true)
            self.window.makeKeyAndVisible()
            
            self.initBaeSdk()
            
            let uploaderMethodChannel = FlutterMethodChannel(name: ChannelName.uploaderMethodChannel,
                                                             binaryMessenger: controller.binaryMessenger)
            
            let uploaderEventChannel = FlutterEventChannel(name: ChannelName.uploaderEventChannel,
                                                           binaryMessenger: controller.binaryMessenger)
            
            uploaderMethodChannel.setMethodCallHandler({
                [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
                guard call.method == "openUploader" else {
                    result(FlutterMethodNotImplemented)
                    return
                }
                self?.openUploader()
            })
            
            uploaderEventChannel.setStreamHandler(self)
            
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
    
    private func openUploader() {
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
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        print("onCancel")
        eventSink = nil
        return nil
    }
    
}
