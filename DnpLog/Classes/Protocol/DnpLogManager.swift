//
//  DnpLogManager.swift
//  DnpLog
//
//  Created by Fice on 2021/5/19.
//

import Foundation


public class DnpLogManager: NSObject {
    
    

    public static func startMonitor() {
        DnpSessionConfiguration.shared.load()
        DnpTool.shareInstance.show()
    }
    
    public static func stopMonitor() {
        DnpSessionConfiguration.shared.unload()
    }
    
}
