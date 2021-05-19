//
//  DnpLogManager.swift
//  DnpLog
//
//  Created by Fice on 2021/5/19.
//

import Foundation


public class DnpLogManager: NSObject {

    public static func startMonitor() {
        //URLProtocol.registerClass(DnpURLProtocol.self)
    }
    
    public static func stopMonitor() {
        URLProtocol.unregisterClass(DnpURLProtocol.self)
    }
    
}
