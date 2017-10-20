//
//  Extension.Alamofire.swift
//  Pods
//
//  Created by Afriyandi Setiawan on 8/4/17.
//
//

import Foundation
import Alamofire

extension SessionManager: APIManagerProtocol {
    func apiRequest<T: Any & EndPoint>(_ endPoint: T) -> ApiRequestProtocol {
        let encoding = endPoint.jsonBody ? endPoint.jsonEncoding : endPoint.urlEncoding
        let method = Alamofire.HTTPMethod(rawValue: endPoint.method.rawValue) ?? .get
        return request(endPoint.url, method: method, parameters: endPoint.parameters, encoding: encoding, headers: endPoint.HTTPheaders)
    }
    
    func uploadMultiForm<T: Any & EndPoint, U: Any & FormUpload>(_ endPoint: T, withForm form: U, response: @escaping (SessionManager.MultipartFormDataEncodingResult) -> Void) {
        
        Alamofire.upload(multipartFormData: { _form in
            _form.append(form.file, withName: form.name, fileName: form.fileName, mimeType: form.mimeType)
            if let param = endPoint.parameters {
                for (key, value) in param {
                    _form.append(value.data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            }
        }, to: endPoint.url, headers: endPoint.HTTPheaders, encodingCompletion: { _message in
            response(_message)
        })
    }
    
    func upload<T: Any & EndPoint>(_ endPoint: T, data: Data) -> ApiRequestProtocol {
        return Alamofire.upload(data, to: endPoint.url)
    }
    
    func download<T: Any & EndPoint>(_ endPoint: T) -> DownloadRequestProtocol {
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("\(Date().timeIntervalSince1970).tmp")
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        return Alamofire.download(endPoint.url, parameters: endPoint.parameters, headers: endPoint.HTTPheaders, to: destination)
    }
}

extension DataRequest: ApiRequestProtocol {
    func apiResponse(_ completionHandler: @escaping (DataResponse<Any>) -> Void) -> Self {
        return responseJSON(completionHandler: completionHandler)
    }
}

extension DownloadRequest: DownloadRequestProtocol {
    func downloadResponse(_ completionHandler: @escaping (DownloadResponse<Data>) -> Void) -> Self {
        return responseData(completionHandler: completionHandler)
    }
}

