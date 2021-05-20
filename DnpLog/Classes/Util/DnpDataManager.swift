//
//  DnpDataManager.swift
//  DnpLog
//
//  Created by Fice on 2021/5/19.
//

import Foundation


class DnpDataManager: NSObject {
    
    static let shared = DnpDataManager()
    
    var requests: [DnpDataModel] = []
    
    var requests_dict = [URLSessionDataTask: DnpDataModel]()
    
    func addRequest(task: URLSessionDataTask?)  {
        guard let dataTask = task else {
            return
        }
        
        objc_sync_enter(self)
        if self.requests.count > 100 , let task = self.requests.first?.task{
            self.requests.removeFirst()
            self.requests_dict.removeValue(forKey: task)
        }
        
        let model = DnpDataModel()
        model.task = dataTask
        model.time = Date.timeInterval()
        
        self.requests.append(model)
        self.requests_dict[dataTask] = model
        
        NotificationCenter.default.post(name: DnpLogNotificationName, object: model)
        objc_sync_exit(self)
    }
    
}
