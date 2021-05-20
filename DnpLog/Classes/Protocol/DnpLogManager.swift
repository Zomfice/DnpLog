//
//  DnpLogManager.swift
//  DnpLog
//
//  Created by Fice on 2021/5/19.
//

import Foundation


public class DnpLogManager: NSObject {

    public static func startMonitor() {
//        let sessionConfiguration = TBSessionConfiguration.shared
//        URLProtocol.registerClass(DnpURLProtocol.self)
//        if !sessionConfiguration.isSwizzle{
//            sessionConfiguration.load()
//        }
        //TBURLProtocol.startMonitor()
        //NetworkRequestInterceptor().startRecording()
        
        DnpNetworkRequestInterceptor().startRecording()
    }
    
    public static func stopMonitor() {
        //URLProtocol.unregisterClass(DnpURLProtocol.self)
    }
    
}


@objc public class DnpNetworkRequestInterceptor: NSObject{

    func swizzleProtocolClasses(){
        let instance = URLSessionConfiguration.default
        let uRLSessionConfigurationClass: AnyClass = object_getClass(instance)!

        let method1: Method = class_getInstanceMethod(uRLSessionConfigurationClass, #selector(getter: uRLSessionConfigurationClass.protocolClasses))!
        let method2: Method = class_getInstanceMethod(URLSessionConfiguration.self, #selector(URLSessionConfiguration.dnp_fakeProcotolClasses))!

        method_exchangeImplementations(method1, method2)
    }
    
    public func startRecording() {
        URLProtocol.registerClass(DnpURLProtocol.self)
        swizzleProtocolClasses()
    }
    
    public func stopRecording() {
        URLProtocol.unregisterClass(DnpURLProtocol.self)
        swizzleProtocolClasses()
    }
}

extension URLSessionConfiguration {
    
    @objc func dnp_fakeProcotolClasses() -> [AnyClass]? {
        guard let fakeProcotolClasses = self.dnp_fakeProcotolClasses() else {
            return []
        }
        var originalProtocolClasses = fakeProcotolClasses.filter {
            return  $0 != DnpURLProtocol.self
        }
        originalProtocolClasses.insert(DnpURLProtocol.self, at: 0)
        return originalProtocolClasses
    }
    
}
