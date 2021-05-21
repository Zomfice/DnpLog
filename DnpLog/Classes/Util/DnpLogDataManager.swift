//
//  DnpDataManager.swift
//  DnpLog
//
//  Created by Fice on 2021/5/19.
//

import Foundation


class DnpLogDataManager: NSObject {
    
    static let shared = DnpLogDataManager()
    
    var requests: [DnpLogDataModel] = []
    
    var requests_dict = [URLSessionDataTask: DnpLogDataModel]()
    
    func addRequest(task: URLSessionDataTask?)  {
        guard let dataTask = task else {
            return
        }
        
        objc_sync_enter(self)
        if self.requests.count > 100 , let task = self.requests.first?.task{
            self.requests.removeFirst()
            self.requests_dict.removeValue(forKey: task)
        }
        
        let model = DnpLogDataModel()
        model.task = dataTask
        model.time = Date.timeInterval()
        
        self.requests.append(model)
        self.requests_dict[dataTask] = model
        
        /*DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            var log = "********************************** API:request **********************************\n\n"
            log += "\(model.logDataFormat(rheader: false))"
            log += "🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀\n"
            print(log)
        }*/
        
        NotificationCenter.default.post(name: DnpLogNotificationName, object: model)
        objc_sync_exit(self)
    }
    
    static func removeAll() {
        shared.requests.removeAll()
        shared.requests_dict.removeAll()
        NotificationCenter.default.post(name: DnpLogNotificationName, object: nil)
    }
    
    // task数据更新
    static func requestTaskStatus(model: DnpLogDataModel?) {
        guard let model = model else {
            return
        }
        NotificationCenter.default.post(name: DnpLogNotificationName, object: model)
        if DnpLogManager.terminalPrint {
            DispatchQueue.main.async {
                var log = "********************************** API:request **********************************\n\n"
                log += "\(model.logDataFormat(rheader: false))"
                log += "🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀\n"
                print(log)
            }
        }
    }
    
}
