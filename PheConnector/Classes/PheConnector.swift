//
//  PheConnector.swift
//  Pods
//
//  Created by Afriyandi Setiawan on 8/1/17.
//
//

import Foundation
import Alamofire
import SwiftyJSON

public struct Phe {
    
    public typealias message = (Bool, (error: Error?, json: JSON?)) -> Void
    
    static var manager: SessionManager = {
        let a = URLSessionConfiguration.default
        return SessionManager(configuration: a)
    }()
        
    public init() {
        Phe.manager = SessionManager(configuration: URLSessionConfiguration.default)
    }
    
    public init(withSessionManager session: URLSessionConfiguration) {
        Phe.manager = SessionManager(configuration: session)
    }
    
    public func routine<T: Any & EndPoint>(_ endPoint: T, message: @escaping message) {
        Phe.manager.apiRequest(endPoint).apiResponse { (response) in
            return message(response.result.isSuccess, (response.error, JSON(data: response.data ?? Data())))
        }
    }
    
    public func uploadMultiForm<T: Any & EndPoint, U: Any & FormUpload>(_ endPoint: T, withForm form: U, message: @escaping message) {
        Phe.manager.uploadMultiForm(endPoint, withForm: form) { (result) in
            switch result {
            case .success(let _upload, _, _):
                _upload.responseJSON(completionHandler: { (completion) in
                    switch completion.result {
                    case .success:
                        #if DEBUG_UPLOAD
                            let countBytes = ByteCountFormatter()
                            countBytes.allowedUnits = [.useMB]
                            countBytes.countStyle = .file
                            let prompt = UIAlertController(title: "Upload Debugger", message: completion.timeline.description + "\nfile size: \(countBytes.string(fromByteCount: Int64(image.image.count)))", preferredStyle: .alert)
                            let ok = UIAlertAction(title: "OK", style: .destructive, handler: { _ in
                                return result(true, completion.data)
                            })
                            prompt.addAction(ok)
                            prompt.showCustom()
                        #endif
                        message(true, (nil, JSON(data: completion.data ?? Data())))
                    case .failure:
                        message(false, (completion.error, nil))
                    }
                })
            case .failure(let err):
                message(false, (err, nil))
            }
        }
    }
    
    public func upload<T: Any & EndPoint>(_ endPoint: T, withData data: Data, message: @escaping message) {
        Phe.manager.upload(endPoint, data: data).apiResponse { (response) in
            return message(response.result.isSuccess, (response.error, JSON(data: response.data ?? Data())))
        }
    }
    
    public func download<T: Any & EndPoint>(_ endPoint: T, message: @escaping (Bool, Data?) -> Void) {
        Phe.manager.download(endPoint).downloadResponse { (response) in
            var data: Data?
            defer {
                message(response.result.isSuccess, data)
            }
            if let destinationURL = response.destinationURL, let _data = try? Data(contentsOf: destinationURL) {
                data = _data
            }
        }
    }
    
    public func clearCache(){
        let cacheURL =  FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let fileManager = FileManager.default
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory( at: cacheURL, includingPropertiesForKeys: nil, options: [])
            let tmpFIle = directoryContents.filter({ (file) -> Bool in
                return file.pathExtension == "tmp"
            })
            for file in tmpFIle {
                do {
                    try fileManager.removeItem(at: file)
                }
                catch let error as NSError {
                    debugPrint("Ooops! Something went wrong: \(error)")
                }
                
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}

extension UIAlertController {
    
    public func showCustomAlert(animated: Bool, completion: @escaping ()->()) {
        presentCustom(animated: animated, completion: completion)
    }
    
    public func showToast(animated: Bool, duration: Double, completion: @escaping ()->()) {
        presentCustom(animated: animated) {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.dismiss(animated: animated, completion: completion)
            }
        }
    }
    
    func presentCustom(animated: Bool, completion: (() -> Void)?) {
        if let rootVC = UIApplication.shared.keyWindow?.visibleViewController {
            presentFromController(controller: rootVC, animated: animated, completion: completion)
        }
    }
    
    private func presentFromController(controller: UIViewController, animated: Bool, completion: (() -> Void)?) {
        controller.definesPresentationContext = true
        switch controller {
        case let navVC as UINavigationController:
            presentFromController(controller: navVC.visibleViewController!, animated: animated, completion: completion)
            break
        case let tabVC as UITabBarController:
            presentFromController(controller: tabVC.selectedViewController!, animated: animated, completion: completion)
        case let presented where (controller.presentedViewController != nil):
            presented.present(self, animated: animated, completion: completion)
        default:
            controller.present(self, animated: animated, completion: completion)
        }
    }
}

extension UIWindow {
    public var visibleViewController: UIViewController? {
        return UIWindow.visibleViewController(from: rootViewController)
    }
    public static func visibleViewController(from viewController: UIViewController?) -> UIViewController? {
        switch viewController {
        case let navigationController as UINavigationController:
            return UIWindow.visibleViewController(from: navigationController.visibleViewController)
            
        case let tabBarController as UITabBarController:
            return UIWindow.visibleViewController(from: tabBarController.selectedViewController)
            
        case let presentingViewController where viewController?.presentedViewController != nil:
            return UIWindow.visibleViewController(from: presentingViewController?.presentedViewController)
            
        default:
            return viewController
        }
    }
}
