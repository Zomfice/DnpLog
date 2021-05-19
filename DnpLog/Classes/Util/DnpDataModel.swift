//
//  DnpDataModel.swift
//  DnpLog
//
//  Created by Fice on 2021/5/19.
//

import Foundation


class DnpDataModel: NSObject {
    
    var task : URLSessionDataTask?
    var originalData: Data?
    var hookData: Data?
    var time : TimeInterval = 0
    
    func logDataFormat() -> String {
        let m_url = "\(self.task?.originalRequest?.url?.path ?? "")"
        let m_method = "\(self.task?.originalRequest?.httpMethod ?? "")"
        var m_header = "{\n\n}"
        
        if let allHTTPHeaderFields = self.task?.originalRequest?.allHTTPHeaderFields {
            let headers = String.jsonToString(dic: allHTTPHeaderFields)
            m_header = "{\n\(headers)\n}"
        }
        
        var m_body = "{\n\n}"
        if let httpBody = self.task?.originalRequest?.httpBody {
            let string = NSString(data: httpBody, encoding: String.Encoding.utf8.rawValue) ?? ""
            m_body = "{\n\(string)\n}"
        }else if let stream = self.task?.originalRequest?.httpBodyStream {
            let bufferSize = 1024
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
            
            var data = Data()
            stream.open()
            while stream.hasBytesAvailable {
                let len = stream.read(buffer, maxLength: bufferSize)
                if len > 0,stream.streamError == nil {
                    data.append(buffer, count: len)
                }
            }
            buffer.deallocate()
            stream.close()
            let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) ?? ""
            m_body = "{\n\(string)\n}"
        }
        
        
        var m_response = "{\n\n}"
        if let originData = self.originalData{
            let string = NSString(data: originData, encoding: String.Encoding.utf8.rawValue) ?? ""
            m_response = "{\n\(string)\n}"
        }else if let error = self.task?.error {
            m_response = "{\n\(error.localizedDescription)\n}"
        }
         
        var hook_response = ""
        if let hookdata = self.hookData {
            let string = NSString(data: hookdata, encoding: String.Encoding.utf8.rawValue) ?? ""
            hook_response = "{\n\(string)\n}"
        }else if let error = self.task?.error {
            hook_response = "{\n\(error.localizedDescription)\n}"
        }
        
        var netLog = "URL: "
        netLog.append(m_url)
        netLog.append("\n\n")
        
        netLog.append("Method: ")
        netLog.append(m_method)
        netLog.append("\n\n")
        
        netLog.append("Headers: ")
        netLog.append(m_header)
        netLog.append("\n\n")
        
        netLog.append("RequestBody: ")
        netLog.append(m_body)
        netLog.append("\n\n")
        
        netLog.append("Response: ")
        netLog.append(m_response)
        netLog.append("\n\n")
        
        if hook_response.count > 0 {
            netLog.append("HookResponse: ")
            netLog.append(hook_response)
            netLog.append("\n\n")
        }
        
        return netLog
    }
}
