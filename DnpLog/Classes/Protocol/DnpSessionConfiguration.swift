//
//  DnpSessionConfiguration.swift
//  DnpLog
//
//  Created by Fice on 2021/5/20.
//

import Foundation

class DnpSessionConfiguration: NSObject {
    
    static var shared = DnpSessionConfiguration()
    fileprivate override init(){}
    
    var isSwizzle = false
    
    func load(){
        guard !isSwizzle else {
            return
        }
        isSwizzle = true
        URLProtocol.registerClass(DnpURLProtocol.self)
        swizzleSelector()
        interceptWebview()
    }
    
    func unload(){
        isSwizzle = false
        URLProtocol.unregisterClass(DnpURLProtocol.self)
        swizzleSelector()
    }
    
    func swizzleSelector(){
        let instance = URLSessionConfiguration.default
        let uRLSessionConfigurationClass: AnyClass = object_getClass(instance)!
        
        let method1: Method = class_getInstanceMethod(uRLSessionConfigurationClass, #selector(getter: uRLSessionConfigurationClass.protocolClasses))!
        let method2: Method = class_getInstanceMethod(URLSessionConfiguration.self, #selector(URLSessionConfiguration.__procotolClasses))!

        method_exchangeImplementations(method1, method2)
    }
    
    @objc func protocolClasses() -> NSArray{
        return [DnpURLProtocol.self]
    }
    
    func interceptWebview() {
        //实现WKWebview拦截功能
        /*
        guard let object = NSClassFromString("WKBrowsingContextController") else {
            return
        }
        let cls = object as AnyObject
        let sel = NSSelectorFromString("registerSchemeForCustomProtocol:")
        if cls.responds(to: sel) {
            let _ = cls.perform(sel, with: "http")
            let _ = cls.perform(sel, with: "https")
        }*/
    }
}


extension URLSessionConfiguration {
    
    @objc func __procotolClasses() -> [AnyClass]? {
        guard let fakeProcotolClasses = self.__procotolClasses() else {
            return []
        }
        var originalProtocolClasses = fakeProcotolClasses.filter {
            return  $0 != DnpURLProtocol.self
        }
        originalProtocolClasses.insert(DnpURLProtocol.self, at: 0)
        return originalProtocolClasses
    }
    
}
