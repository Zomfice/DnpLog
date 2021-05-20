//
//  NetworkRedirectUrlProtocol.swift
//  NetworkInterceptor
//
//  Created by Kenneth Poon on 26/8/18.
//  Copyright © 2018 Kenneth Poon. All rights reserved.
//

import Foundation

class NetworkRedirectUrlProtocol: URLProtocol {    

    var session: URLSession?
    var sessionTask: URLSessionTask?
    
    open override class func canInit(with request: URLRequest) -> Bool {
        if let httpHeaders = request.allHTTPHeaderFields, httpHeaders.isEmpty {
            return false
        }
        if let _ = URLProtocol.property(forKey: "NetworkRequestSniffableUrlProtocol", in: request) {
            return false
        }
        
        return true
    }
    
    open override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        let mutableRequest: NSMutableURLRequest = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        URLProtocol.setProperty("YES", forKey: "NetworkRequestSniffableUrlProtocol", in: mutableRequest)
        return mutableRequest.copy() as! URLRequest
    }
    
    open override func startLoading() {
        let mutableRequest: NSMutableURLRequest = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest

        let config = URLSessionConfiguration.default
        config.protocolClasses = [type(of: self)]
        
        session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        sessionTask = self.session?.dataTask(with: self.request)
        
        //sessionTask = session?.dataTask(with: mutableRequest as URLRequest)
        
//        sessionTask = session?.dataTask(with: mutableRequest as URLRequest, completionHandler: { [weak self] (data, response, error) in
//            guard let strongSelf = self else { return }
//
//            if let error = error {
//                strongSelf.client?.urlProtocol(strongSelf, didFailWithError: error)
//                return
//            }
//
//            strongSelf.client?.urlProtocol(strongSelf, didReceive: response!, cacheStoragePolicy: .allowed)
//            strongSelf.client?.urlProtocol(strongSelf, didLoad: data!)
//            strongSelf.client?.urlProtocolDidFinishLoading(strongSelf)
//        })
        
        sessionTask?.resume()
    }
    
    override public func stopLoading() {
        sessionTask?.cancel()
        sessionTask = nil
    }
}

extension NetworkRedirectUrlProtocol: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            self.client?.urlProtocol(self, didFailWithError: error)
            return
        }
        self.client?.urlProtocolDidFinishLoading(self)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        completionHandler(.allow)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            
        }
        
        let m_url = "\(dataTask.originalRequest?.url?.path ?? "")"
        print("--\(m_url)")
        
        let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) ?? ""
        let response = "{\n\(string)\n}"
        print(response)
        
        self.client?.urlProtocol(self, didLoad: data)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        self.client?.urlProtocol(self, wasRedirectedTo: request, redirectResponse: response)
    }
}

