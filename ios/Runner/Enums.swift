enum ChannelNames {
    static let uploaderMethodChannel = "samples.flutter.io/uploaderMethodChannel"
    static let uploaderEventChannel = "samples.flutter.io/uploaderEventChannel"

    static let scannerFrontEventChannel = "samples.flutter.io/scannerFrontEventChannel"
    static let scannerBackEventChannel = "samples.flutter.io/scannerBackEventChannel"
    static let scannerSelfieEventChannel = "samples.flutter.io/scannerSelfieEventChannel"
    
    static let recorderEventChannel = "samples.flutter.io/recorderEventChannel"
}

enum ViewTypes {
    static let front = "front"
    static let back = "back"
    static let selfie = "selfie"
    static let recorder = "recorder"
}

enum ChannelEventTypes {
    static let upload_started = "upload_started"
    static let upload_success = "upload_success"
    static let upload_failed = "upload_failed"
    
    static let scan_front_success = "scan_front_success"
    static let scan_front_failed = "scan_front_failed"
    
    static let scan_back_success = "scan_back_success"
    static let scan_back_failed = "scan_back_failed"
    
    static let scan_selfie_success = "scan_selfie_success"
    static let scan_selfie_failed = "scan_selfie_failed"
    
    static let record_success = "record_success"
    static let record_failed = "record_failed"
}
