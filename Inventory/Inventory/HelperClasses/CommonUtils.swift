//
//  CommonUtils.swift
//  Inventory
//
//  Created by Vaibhav Singla on 04/07/18.
//  Copyright © 2018 Vaibhav Singla. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration

struct CommonUtils{
    
    // MARK: - Screen size
    static func screenSize() -> CGSize {
        return UIScreen.main.bounds.size
    }
    
    static func screenWidth() -> CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    static func screenHeight() -> CGFloat {
        return UIScreen.main.bounds.size.height
    }
    
    static var isZoomed: Bool {
        return UIScreen.main.scale < UIScreen.main.nativeScale
    }
    
    
    // MARK: - Device information
    static func getUUIDString() -> String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
    
    static func alertWithOkButton(title: String?, message: String?, viewController: UIViewController, sucessAction: @escaping(_ success: Bool)-> Void){
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            sucessAction(true)
        }))
        viewController.present(alertController, animated: true, completion: nil)
    }
    // MARK: - Internet availability check
    
    static func isInternetAvailable() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var isInternet = false
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return isInternet
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        isInternet = (isReachable && !needsConnection)
        return isInternet
    }
}
