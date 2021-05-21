//
//  DnpLogDataModel.swift
//  DnpLog
//
//  Created by Fice on 2021/5/19.
//

import Foundation


class DnpLogDataModel: NSObject {
    
    var task : URLSessionDataTask?
    var originalData: Data?
    var hookData: Data?
    var time : TimeInterval = 0
    // request status
    var status: String{
        if task?.response == nil {
            if task?.error != nil  {
                return "❌  "
            }else{
                return "⚠️"
            }
        }else{
            return "✅ "
        }
    }
    // request url path
    var url: String{
        if let urlpath = task?.originalRequest?.url {
            return "\(urlpath)"
        }
        return ""
    }
    // request port date time
    var date: String {
        return Date.currentDate(time: time,format: "MM-dd HH:mm:ss")
    }
    
}


extension DnpLogDataModel {
    func requestURL() -> String {
        var p_url = ""
        if let urlpath = self.task?.originalRequest?.url {
            p_url = "\(urlpath)"
        }
        return p_url
    }
    
    func requestMethod() -> String {
        return "\(self.task?.originalRequest?.httpMethod ?? "")"
    }
    
    func requestHeader() -> String {
        var p_header = "{\n\n}"
        if let allHTTPHeaderFields = self.task?.originalRequest?.allHTTPHeaderFields {
            let headers = String.jsonToString(dic: allHTTPHeaderFields)
            p_header = headers
        }
        return p_header
    }
    
    func requestBody() -> String {
        var p_body = "{\n\n}"
        if let httpBody = self.task?.originalRequest?.httpBody {
            p_body = httpBody.dataToString()//"{\n\(httpBody.dataToString())\n}"
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
            p_body = data.dataToString()
        }
        return p_body
    }
    
    func responseHeader() -> String {
        var p_response_header = "{\n\n}"
        if let response = self.task?.response as? HTTPURLResponse,
           let allHTTPHeaderFields = response.allHeaderFields as? [String: Any],
           allHTTPHeaderFields.count > 0{
            p_response_header = String.jsonToString(dic: allHTTPHeaderFields)
        }
        return p_response_header
    }
    
    func originalResponse() -> String {
        var p_response = "{\n\n}"
        if let originData = self.originalData{
            let dataString = originData.dataToString()
            if dataString.count > 0 {
                p_response = dataString
            }else if let string = String(data: originData, encoding: .utf8){
                p_response = "{\n\(string)\n}"
            }
        }
        return p_response
    }
    
    func hookResponse() -> String {
        var hook_response = ""
        if let hookdata = self.hookData {
            hook_response = "\(hookdata.dataToString())"
        }
        return hook_response
    }
    
    func requestError() -> String {
        var p_error = ""
        if let error = self.task?.error {
            p_error = "{\n\(error)\n}"
        }
        return p_error
    }
    
    func logDataFormat(rheader: Bool = true) -> String {
        let p_url = requestURL()
        let p_method = requestMethod()
        let p_header = requestHeader()
        let p_body = requestBody()
        let p_response_header = responseHeader()
        let p_response = originalResponse()
        let h_response = hookResponse()
        let p_error = requestError()
        
        var netLog = "URL: "
        netLog.append(p_url)
        netLog.append("\n\n")
        
        netLog.append("Method: ")
        netLog.append(p_method)
        netLog.append("\n\n")
        
        netLog.append("Headers: ")
        netLog.append(p_header)
        netLog.append("\n\n")
        
        netLog.append("RequestBody: ")
        netLog.append(p_body)
        netLog.append("\n\n")
        
        if p_error.count > 0 {
            netLog.append("Error: ")
            netLog.append(p_error)
            netLog.append("\n\n")
        }else{
            netLog.append("Response: ")
            netLog.append(p_response)
            netLog.append("\n\n")
        }
        
        if h_response.count > 0 {
            netLog.append("HookResponse: ")
            netLog.append(h_response)
            netLog.append("\n\n")
        }
        
        if rheader {
            netLog.append("\n\n")
            netLog.append("ResponseHeader: ")
            netLog.append(p_response_header)
            netLog.append("\n\n")
        }
        
        return netLog
    }
}
