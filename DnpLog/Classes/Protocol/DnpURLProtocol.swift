//
//  DnpNSURLProtocol.swift
//  DnpLog
//
//  Created by Fice on 2021/5/19.
//

import Foundation


@objc public class DnpURLProtocol: URLProtocol {
    static let hasInitKey = "DnpMarkerProtocolKey"
    private var session : URLSession?
    
}

extension DnpURLProtocol {
    
    public override class func canInit(with request: URLRequest) -> Bool {
        
        if let value = URLProtocol.property(forKey: hasInitKey, in: request) as? Bool, value {
            return false
        }
        
        if request.url?.scheme != "http" ,request.url?.scheme != "https" {
            return false
        }
        
        let contentType = request.value(forHTTPHeaderField: "Content-Type")
        
        if let contentTypeStr = contentType, (contentTypeStr as NSString).contains("multipart/form-data")  {
            return false
        }
        return true
    }
    
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        guard let mutableRequest = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest else {
            return request
        }
        URLProtocol.setProperty(true, forKey: hasInitKey, in: mutableRequest)
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
        print("request: \(mutableRequest) Cookie: \(cookieValue)")
        //mutableRequest.addValue(cookieValue, forHTTPHeaderField: "Cookie")
        return mutableRequest as URLRequest
    }
    
    public override func startLoading() {
        guard let mutableRequest = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest else {
            return
        }
        print("-----开始请求-------\(mutableRequest.url)")
        let configuration = URLSessionConfiguration.ephemeral
        self.session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue())
        let task = self.session?.dataTask(with: self.request)
        task?.resume()
        // 添加task
        if let m_task = task {
            DnpDataManager.shared.addRequest(task: m_task)
        }
        // 打印数据
    }
    
    public override func stopLoading() {
        self.session?.invalidateAndCancel()
        self.session = nil
    }
}

extension DnpURLProtocol : URLSessionDataDelegate {
    
    private func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let e = error {
            self.client?.urlProtocol(self, didFailWithError: e)
        }else{
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    private func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
//        if response.isKind(of: HTTPURLResponse.self),
//           let response = response as? HTTPURLResponse,
//           let allHeaderFields = response.allHeaderFields as? [String: String],
//           let _ = allHeaderFields["Set-Cookie"] ,
//           let url = response.url{
//            let cookies = HTTPCookie.cookies(withResponseHeaderFields: allHeaderFields, for: url)
//            for cookie in cookies {
//                HTTPCookieStorage.shared.setCookie(cookie)
//            }
//        }
        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        completionHandler(URLSession.ResponseDisposition.allow)
    }
    
    private func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        let model = DnpDataManager.shared.mutable_requests_dict[dataTask]
        var newData = NSMutableData(data: data)
        if let origindata = model?.originalData {
            newData = NSMutableData(data: origindata)
            newData.append(data)
        }
        model?.originalData = newData as Data
        
        self.client?.urlProtocol(self, didLoad: data)
        
    }
    
    private func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        
    }
    
}
