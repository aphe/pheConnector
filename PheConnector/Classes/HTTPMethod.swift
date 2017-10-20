//
//  EndPoint.swift
//  Pods
//
//  Created by Afriyandi Setiawan on 8/2/17.
//
//

import Foundation
import Alamofire

public protocol _HTTPMethod: Hashable {
    static var allValues: [Self] { get }
}

public extension _HTTPMethod {
    static func cases() -> AnySequence<Self> {
        typealias H = Self
        return AnySequence {
            () -> AnyIterator<H> in
            var raw = 0
            return AnyIterator {
                let current: Self = withUnsafePointer(to: &raw, { (_a) -> Self in
                    _a.withMemoryRebound(to: H.self, capacity: 1, { (_b) -> Self in
                        return _b.pointee
                    })
                })
                guard current.hashValue == raw else {
                    return nil
                }
                raw += 1
                return current
            }
        }
    }
    
    static var allValues:[Self] {
        return Array(cases())
    }
}

public enum HTTPMethod: String, _HTTPMethod {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}


