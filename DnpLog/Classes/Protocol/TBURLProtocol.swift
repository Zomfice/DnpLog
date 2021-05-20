//
//  TBURLProtocol.swift
//  NetworkLogDemo
//
//  Created by Fice on 2021/5/20.
//

import Foundation


import UIKit

class TBURLProtocol: URLProtocol, URLSessionDataDelegate, URLSessionTaskDelegate{
    
    fileprivate var dataTask:URLSessionDataTask?
    fileprivate let sessionDelegateQueue = OperationQueue()
    
    class func startMonitor(){
        let sessionConfiguration = TBSessionConfiguration.shared
        URLProtocol.registerClass(TBURLProtocol.self)
        if !sessionConfiguration.isSwizzle{
            sessionConfiguration.load()
        }
    }
    
    class func stopMonitor(){
        let sessionConfiguration = TBSessionConfiguration.shared
        URLProtocol.unregisterClass(TBURLProtocol.self)
        if sessionConfiguration.isSwizzle{
            sessionConfiguration.unload()
        }
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        if URLProtocol.property(forKey: "TBURLProtocolHandledKey", in: request) != nil {
            return false
        }
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        let mutableReqeust = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
         //在这里可以对请求修改
        URLProtocol.setProperty(true, forKey: "TBURLProtocolHandledKey",
                                in: mutableReqeust)
        return mutableReqeust as URLRequest
    }
    
    override func startLoading() {
        print("抓取请求地址: \(request.url!.absoluteString)")
        
        let defaultConfigObj = URLSessionConfiguration.default
        sessionDelegateQueue.maxConcurrentOperationCount = 1
        sessionDelegateQueue.name = "com.TB.session.queue"
        let defaultSession = Foundation.URLSession(configuration: defaultConfigObj,
                                                   delegate: self, delegateQueue: sessionDelegateQueue)
        dataTask = defaultSession.dataTask(with: self.request)
        dataTask!.resume()
    }
    
    override func stopLoading() {
        dataTask?.cancel()
        dataTask = nil
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        error == nil ? client?.urlProtocolDidFinishLoading(self) : client?.urlProtocol(self, didFailWithError: error!)
        self.dataTask = nil
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            
        }
        
        let m_url = "\(dataTask.originalRequest?.url?.path ?? "")"
        print("--\(m_url)")
        
        let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) ?? ""
        let response = "{\n\(string)\n}"
        print(response)
        
        
        client?.urlProtocol(self, didLoad: data)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        client?.urlProtocol(self, wasRedirectedTo: request, redirectResponse: response)
    }
}

class TBSessionConfiguration: NSObject {
    
    static var shared = TBSessionConfiguration()
    fileprivate override init(){}
    
    
    var isSwizzle = false
    
    func load(){
        isSwizzle = true
        guard let cls = NSClassFromString("__NSCFURLSessionConfiguration") ?? NSClassFromString("NSURLSessionConfiguration") else { return }
        swizzleSelector(selector: #selector(protocolClasses), fromClass: cls, toClass: TBSessionConfiguration.self)
    }
    
    func unload(){
        isSwizzle = false
        guard let cls = NSClassFromString("__NSCFURLSessionConfiguration") ?? NSClassFromString("NSURLSessionConfiguration") else { return }
        swizzleSelector(selector: #selector(protocolClasses), fromClass: cls, toClass: TBSessionConfiguration.self)
    }
    
    func swizzleSelector(selector: Selector, fromClass: AnyClass, toClass: AnyClass){
        let originalMethod = class_getInstanceMethod(fromClass, selector)
        let stubMethod = class_getInstanceMethod(toClass, selector)
        guard originalMethod != nil && stubMethod != nil else { return }
        method_exchangeImplementations(originalMethod!, stubMethod!)
    }
    
    @objc func protocolClasses() -> NSArray{
        return [TBURLProtocol.self]
    }
}
