//
//  ViewController.swift
//  DnpLog
//
//  Created by Zomfice on 05/19/2021.
//  Copyright (c) 2021 Zomfice. All rights reserved.
//

import UIKit
import AFNetworking

class ViewController: UIViewController {

    lazy var button: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        button.setTitle("点击网络请求", for: .normal)
        button.backgroundColor = UIColor.magenta
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(startNetwork), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.addSubview(button)
        button.center = view.center
    }
    
    @objc private func startNetwork() {
        // success data
        self.request(path: "http://baobab.kaiyanapp.com/api/v3/discovery")
        // error data
        self.request(path: "http://baobab.wandoujia.com/api/v1/feed?vc=67&u=011f2924aa2cf27aa5dc8066c041fe08116a9a0c&v=4.1.0&f=iphone")
        // html data
        self.request(path: "http://meizi.leanapp.cn/category/All/page/1")
        // html data
        self.request2(path: "https://www.taobao.com/")
        self.request2(path: "https://www.baidu.com/")
    }
    
    
    func request(path: String) {
        let session = AFHTTPSessionManager()
        session.requestSerializer = AFHTTPRequestSerializer()
        session.responseSerializer = AFHTTPResponseSerializer()
        session.requestSerializer.timeoutInterval = 10;
        let acceptSet: Set<String> = ["application/json","text/plain","text/javascript","text/json","text/html","text/json"]
        session.responseSerializer.acceptableContentTypes = acceptSet
        session.get(path, parameters: nil, headers: nil, progress: nil) { (task, response) in
            if let _ = response as? [String: Any] {
                //print(dict)
            }
        } failure: { (_, error) in
            //print("\(error)")
        }
    }
    
    func request2(path: String) {
        let url: URL = URL(string: path)!
        let request: URLRequest = URLRequest(url: url)
        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue()) { (response:URLResponse?, data:Data?, error:Error?) in
            if error == nil {
                let _ = String(data: data!, encoding: String.Encoding.utf8)!
                //print("请求成功 = \(result)")
            }else{
                //print("请求失败 error = \(error.debugDescription)")
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

