//
//  DnpTool.swift
//  DnpTool
//
//  Created by Zomfice on 2019/7/30.
//

import UIKit

@objc public class DnpTool: NSObject {
    @objc public static let shareInstance  = DnpTool()
    private var enterView : DnpToolEnterView!
    private var hasInstall: Bool = false
    private var startPlugins = [String]()
    /// custom module show
    public var configModule: (() -> [[String:String]] )?
    /// custom module jump
    public var jumpModule: (()-> [[String: Any]])?
    
    override init() {
        super.init()
        self.initconfig()
    }
    /// Show DnpTool
    @objc public func show() {
        self.initEnter()
    }
    /// Close DnpTool
    @objc public func hidden() {
        enterView.isHidden = true
    }
    /// Hidden DnpTool
    @objc public func close() {
        DnpToolHomeWindow.shareInstance.hide()
    }
    
    internal func initEnter() {
        guard !hasInstall else {
            return
        }
        hasInstall = true
        enterView = DnpToolEnterView()
        enterView.makeKeyAndVisible()
    }
    
    /// init Log notification
    internal func initconfig() {
        //if UserDefaults.standard.bool(forKey: "\(DnpToolLogController.self)") {
        //    DnpLogListController.addnotification()
        //}
    }
    
    /// whether show DnpLog
    @objc public static var logisShow : Bool{
        //return UserDefaults.standard.bool(forKey: "\(DnpToolLogController.self)")
        return false
    }
    

}

// MARK: 使用文档
/*
 1. 配置自定义模块
     DnpTool.shareInstance.configModule = {
     return [["title": "--","type": "2"]]
     }
     DnpTool.shareInstance.jumpModule = {
     return [["type": "2","class": SecondController.self]]
     }
 */
