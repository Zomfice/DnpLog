//
//  DnpDataManager.swift
//  DnpLog
//
//  Created by Fice on 2021/5/19.
//

import Foundation


class DnpDataManager: NSObject {
    
    static let shared = DnpDataManager()
    
    var mutable_requests: [DnpDataModel] = []
    
    var mutable_requests_dict = [URLSessionDataTask: DnpDataModel]()
    
    func addRequest(task: URLSessionDataTask)  {
        
        objc_sync_enter(self)
        
        if self.mutable_requests.count > 100 , let task = self.mutable_requests.first?.task{
            self.mutable_requests.removeFirst()
            self.mutable_requests_dict.removeValue(forKey: task)
        }
        
        let model = DnpDataModel()
        model.task = task
        model.time = Date.timeInterval()
        
        self.mutable_requests.append(model)
        self.mutable_requests_dict[task] = model
        

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            print("-----log---\(model.logDataFormat())")
        }
        
        NotificationCenter.default.post(name: DnpLogNotification, object: model)
        objc_sync_exit(self)
    }
    
}
