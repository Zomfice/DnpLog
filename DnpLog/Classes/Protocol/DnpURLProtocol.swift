//
//  DnpNSURLProtocol.swift
//  DnpLog
//
//  Created by Fice on 2021/5/19.
//

import Foundation


class DnpURLProtocol: URLProtocol, URLSessionDataDelegate, URLSessionTaskDelegate {
    
    fileprivate var session : URLSession?
    fileprivate var dataTask:URLSessionDataTask?

    override class func canInit(with request: URLRequest) -> Bool {
        
        if let _ = URLProtocol.property(forKey: "DnpURLProtocol", in: request) {
            return false
        }

        if request.url?.scheme != "http" ,request.url?.scheme != "https" {
            return false
        }
        
        let contentType = request.value(forHTTPHeaderField: "Content-Type")
        if let contentTypeStr = contentType, (contentTypeStr as NSString).contains("multipart/form-data")  {
            return false
        }
        
        // 域名过滤
        guard DnpLogManager.interceptorDomainFilter(request: request) else {
            return false
        }
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        guard let mutableRequest = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest else {
            return request
        }
        URLProtocol.setProperty("YES", forKey: "DnpURLProtocol", in: mutableRequest)
        var cookieDic = [String: Any]()
        var cookieValue = String()
        let cookieJar = HTTPCookieStorage.shared
        if let cookies = cookieJar.cookies {
            for cookie in cookies {
                cookieDic[cookie.name] = cookie.value
            }
        }
        for key in cookieDic.keys {
            if let value = cookieDic[key] {
                let appendString = "\(key)=\(value);"
                cookieValue.append(appendString)
            }
        }
        mutableRequest.addValue(cookieValue, forHTTPHeaderField: "Cookie")
        return mutableRequest.copy() as! URLRequest
    }

    override func startLoading() {
        let config = URLSessionConfiguration.default
        config.protocolClasses = [type(of: self)]
        session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        dataTask = self.session?.dataTask(with: self.request)
        
        dataTask?.resume()
        DnpLogDataManager.shared.addRequest(task: dataTask)
    }

    override func stopLoading() {
        self.dataTask?.cancel()
        self.dataTask = nil
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        if response.isKind(of: HTTPURLResponse.self),
           let response = response as? HTTPURLResponse,
           let allHeaderFields = response.allHeaderFields as? [String: String],
           let _ = allHeaderFields["Set-Cookie"] ,
           let url = response.url{
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: allHeaderFields, for: url)
            for cookie in cookies {
                HTTPCookieStorage.shared.setCookie(cookie)
            }
        }
        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let e = error {
            if let dataTask = task as? URLSessionDataTask {
                let model = DnpLogDataManager.shared.requests_dict[dataTask]
                DnpLogDataManager.requestTaskStatus(model: model)
            }
            self.client?.urlProtocol(self, didFailWithError: e)
        }else{
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let model = DnpLogDataManager.shared.requests_dict[dataTask]
        var newData = NSMutableData(data: data)
        if let origindata = model?.originalData {
            newData = NSMutableData(data: origindata)
            newData.append(data)
        }
        model?.originalData = newData as Data
        
        DnpLogDataManager.requestTaskStatus(model: model)
        self.client?.urlProtocol(self, didLoad: data)
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        client?.urlProtocol(self, wasRedirectedTo: request, redirectResponse: response)
    }
    
}
