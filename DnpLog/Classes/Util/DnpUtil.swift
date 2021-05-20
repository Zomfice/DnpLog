//
//  DnpUtil.swift
//  DnpLog
//
//  Created by Fice on 2021/5/19.
//

import Foundation

let DnpLogNotificationName = NSNotification.Name(rawValue: "DnpLogNotificationName")

extension String{
    static func jsonToString(dic : [String: Any]?) -> String{
        guard let dict = dic else {
            return ""
        }
        if JSONSerialization.isValidJSONObject(dict){
            let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            if let m_data = data,let encodeString = String(data: m_data, encoding: .utf8){
                return encodeString.replacingOccurrences(of: "\\/", with: "/")//encodeString
            }
        }
        return ""
    }
    
    static func stringToJson(string: String?) -> [String: Any] {
        guard let str = string else {
            return [:]
        }
        if let data = str.data(using: String.Encoding.utf8){
            let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            if let dic = json as? [String: Any]{
                return dic
            }
        }
        return [:]
    }
}


extension Date{
    /// 当前事件戳
    static func timeInterval() -> TimeInterval{
        let date = NSDate(timeIntervalSinceNow: 0)
        let time : TimeInterval = date.timeIntervalSince1970
        return time
    }
    /// 当前日期
    static func currentDate(time: TimeInterval)-> String{
        let date = Date(timeIntervalSince1970: time)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
}


extension NSObject {
    static func exchangeMethod(selector: Selector,
                               replace: Selector,
                               class classType: AnyClass) {
        let select1 = selector
        let select2 = replace
        let select1Method = class_getInstanceMethod(classType, select1)
        let select2Method = class_getInstanceMethod(classType, select2)
        guard (select1Method != nil && select2Method != nil) else {
            return
        }
        let didAddMethod  = class_addMethod(classType,
                                            select1,
                                            method_getImplementation(select2Method!),
                                            method_getTypeEncoding(select2Method!))
        if didAddMethod {
            class_replaceMethod(classType,
                                select2,
                                method_getImplementation(select1Method!),
                                method_getTypeEncoding(select1Method!))
        }else {
            method_exchangeImplementations(select1Method!, select2Method!)
        }
    }
}
