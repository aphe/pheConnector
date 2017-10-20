//
//  EndPoint.swift
//  PheConnector
//
//  Created by Afriyandi Setiawan on 8/2/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import PheConnector

enum Users {
    case login(uName:String, pass:String)
    case getUser(userName: String)
}

extension Users: EndPoint {
    
    var url: URL {
        let baseURL = URL.getBaseUrl()
        switch self {
        case .login:
            return baseURL.appendingPathComponent("post")
        case .getUser:
            return baseURL.appendingPathComponent("get")
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login:
            return .post
        case .getUser:
            return .get
        }
    }
    
    var parameters: [String : AnyObject]? {
        switch self {
        case .login(let uName, let password):
            return ["username": uName as AnyObject, "password": password as AnyObject]
        case .getUser(let uName):
            return ["username": uName as AnyObject]
        }
    }
    
    var HTTPheaders: Dictionary<String, String>? {
        switch self {
        case .login, .getUser:
            return CustomHeader
        }
    }
    
    var jsonBody: Bool {
        switch self {
        case .login:
            return true
        case .getUser:
            return false
        }
    }
    
}

extension URL {
    static func getBaseUrl() -> URL {
        guard let info = Bundle.main.infoDictionary,
//            let urlString = info["Base url"] as? String,
            let urlString = info["Base url"] as? String,
            let url = URL(string: urlString) else {
                fatalError("Cannot get base url from info.plist")
        }
        return url
    }
}

let CustomHeader:Dictionary<String, String> = {
    return ["User-Agent":"\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String) (o2o for \(UIDevice.current.model); iOS version \(UIDevice.current.systemVersion)) ~ phe"]
}()

let phe = Phe()
