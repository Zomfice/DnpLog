//
//  DnpLogManager.swift
//  DnpLog
//
//  Created by Fice on 2021/5/19.
//

import Foundation


public class DnpLogManager: NSObject {
    // 域名白名单, 只过滤白名单内域名
    static var domainWhiteList = [String]()
    // 终端数据打印
    public static var terminalPrint: Bool = false
    
    /// configs 域名白名单
    public static func startMonitor(configs: (() -> [String] )? = nil) {
        domainWhiteList = configs?() ?? []
        DnpSessionConfiguration.shared.load()
        DnpTool.shareInstance.show()
    }
    
    public static func stopMonitor() {
        DnpSessionConfiguration.shared.unload()
    }
    
    static func interceptorDomainFilter(request: URLRequest) -> Bool {
        guard domainWhiteList.count > 0,let requestURL = request.url else {
            return true
        }
        let url = "\(requestURL)"
        for dominString in domainWhiteList {
            if url.contains(dominString) {
                return true
            }
        }
        return false
    }
    
}
