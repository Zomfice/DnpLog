//
//  ViewController.swift
//  DnpLog
//
//  Created by Zomfice on 05/19/2021.
//  Copyright (c) 2021 Zomfice. All rights reserved.
//

import UIKit
import ZLNetworkComponent
import AFNetworking

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        
        //let bytesArray = UnsafeBufferPointer(start: bts, count: bytes.count).map{$0}
        //self.request()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.request()
    }
    
    
    func request() {
        let config = ZLNetConfig()
        config.isNeedLog = false
        config.isNeedDomainName = false
        config.isNeedServiceResponse = false
        //let path = "https://unsplash.com/napi/photos?page=0&per_page=2&order_by=latest"
        let path = "http://meizi.leanapp.cn/category/All/page/1"
        ZLNetWork.request(requestType: .get, path: path, parameters: nil, netConfig: config
        , progressBlock: nil, dataTaskBlock: nil, serviceResponse: nil) { (response, error) in
            if let _ = response{
                //print("----\(m_response)")
            }
        }
    }
    
    func request2() {
        let session = AFHTTPSessionManager()
        session.requestSerializer = AFHTTPRequestSerializer()
        session.responseSerializer = AFHTTPResponseSerializer()
        
        session.requestSerializer.timeoutInterval = 10;
        let acceptSet: Set<String> = ["application/json","text/plain","text/javascript","text/json","text/html","text/json"]
        session.responseSerializer.acceptableContentTypes = acceptSet
        let urlpath = "https://unsplash.com/napi/photos?page=0&per_page=2&order_by=latest"
        session.get(urlpath, parameters: nil, progress: nil) { (task, response) in
            if let dict = response as? [String: Any] {
                print(dict)
            }else{
                print("无")
            }

        } failure: { (_, error) in
            print("failure")
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

