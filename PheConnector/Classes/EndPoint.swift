//
//  EndPoint.swift
//  Pods
//
//  Created by Afriyandi Setiawan on 8/3/17.
//
//

import Foundation
import Alamofire
import SwiftyJSON

public protocol EndPoint {
    var url: URL {get}
    var method: HTTPMethod {get}
    var parameters: [String: AnyObject]? {get}
    var HTTPheaders: Dictionary<String, String>? {get}
    var jsonBody: Bool {get}
}

extension EndPoint {
    var jsonEncoding: ParameterEncoding {
        return JSONEncoding.default
    }
    var urlEncoding:ParameterEncoding {
        return URLEncoding.default
    }
}

public enum Message {
    case success(json: JSON?)
    case failed(error: Error?)
    }

public protocol FormUpload {
    var name: String {get set}
    var fileName: String {get set}
    var mimeType: String {get set}
    var file: Data {get set}
 }

protocol APIManagerProtocol {
    func apiRequest<T: Any & EndPoint>(_ endPoint: T) -> ApiRequestProtocol
    func uploadMultiForm<T: Any & EndPoint, U: Any & FormUpload>(_ endPoint: T, withForm form: U, response: @escaping (SessionManager.MultipartFormDataEncodingResult) -> Void) -> Void
    func upload<T: Any & EndPoint>(_ endPoint: T, data: Data) -> ApiRequestProtocol
    func download<T: Any & EndPoint>(_ endPoint: T) -> DownloadRequestProtocol
}

protocol ApiRequestProtocol {
    @discardableResult
    func apiResponse(_ completionHandler: @escaping (DataResponse<Any>) -> Void) -> Self
}

protocol DownloadRequestProtocol {
    @discardableResult
    func downloadResponse(_ completionHandler: @escaping (DownloadResponse<Data>) -> Void) -> Self
}

