import Foundation
import kyc_sdk

extension AppDelegate {
    func getDocumentBack(result: @escaping FlutterResult) {
        API.getDocumentBack() { doc, error in
            if let safeError = error {
                result(self.createFlutterError(baeError: safeError))
            }
            guard let safeDoc = doc else {return}
            result(safeDoc.data)
        }
    }
    
    func getDocumentFront(result: @escaping FlutterResult) {
        API.getDocumentFront() { doc, error in
            if let safeError = error {
                result(self.createFlutterError(baeError: safeError))
            }
            guard let safeDoc = doc else {return}
            result(safeDoc.data)
        }
    }
    
    func getDocumentPortrait(result: @escaping FlutterResult) {
        API.getDocumentPortrait() { doc, error in
            if let safeError = error {
                result(self.createFlutterError(baeError: safeError))
            }
            guard let safeDoc = doc else {return}
            print(safeDoc)
            result(safeDoc.data)
        }
    }
    
    func getSelfie(result: @escaping FlutterResult) {
        API.getSelfieFace() { doc, error in
            if let safeError = error {
                result(self.createFlutterError(baeError: safeError))
            }
            guard let safeDoc = doc else {return}
            print(safeDoc)
            result(safeDoc.data)
        }
    }
    
    func getScannerResult(result: @escaping FlutterResult) {
        API.getDocumentFields() { docs, error in
            if let safeError = error {
                result(self.createFlutterError(baeError: safeError))
            }
            guard let safeDocs = docs else {return}
            do {
                let data = try JSONEncoder().encode(safeDocs)
                guard var jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {return}
                if let theJSONData = try? JSONSerialization.data(
                    withJSONObject: jsonObject,
                    options: []) {
                    let theJSONText = String(data: theJSONData,
                                             encoding: .utf8)
                    result(theJSONText)
                }
                
            } catch {
                let error = FlutterError(code: "000",
                                         message: "Failed to encode JSON",
                                         details: nil
                )
                result(error)
            }
        }
    }
    
    func getSimilarity(result: @escaping FlutterResult) {
        API.similarity() { data, error in
            if let safeError = error {
                result(self.createFlutterError(baeError: safeError))
            }
            guard let score = data else {return}
            print("score:\(score)")
            result(score)
        }
    }
    
    func getDocumentsUrls(result: @escaping FlutterResult) {
        let urls = Uploader.urls
        if let jsonData = try? JSONSerialization.data(
            withJSONObject: urls,
            options: []) {
            let jsonText = String(data: jsonData,
                                  encoding: .utf8)
            result(jsonText)
        }
    }
    
    
    private func createFlutterError(baeError: BaeError) -> FlutterError {
        return FlutterError(code:String(baeError.code.hashValue),
                            message: baeError.message,
                            details: nil
        )
    }
}


