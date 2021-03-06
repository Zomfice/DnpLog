//
//  DnpCommon.swift
//  DnpTool
//
//  Created by Zomfice on 2019/7/27.
//

import Foundation
import UIKit


internal let screenwidth = UIScreen.main.bounds.width
internal let screenheight = UIScreen.main.bounds.height

internal let navigationHeight: CGFloat = iphoneX ? 88.0 : 64.0

internal let statusbarHeight: CGFloat = iphoneX ? 44.0 : 20.0

internal let tabBarHeight: CGFloat = iphoneX ? 83.0 : 49.0

internal let bottomSafeArea: CGFloat = iphoneX ? 34 : 0

internal let navigationbarHeight: CGFloat = 44.0

/// 根据750*1334分辨率计算size
internal func screenScale(x: CGFloat) -> CGFloat {
    return x * screenwidth / 750
}

/// iphoneX
internal var iphoneX: Bool{
    var iphonex = false
    if UIDevice.current.userInterfaceIdiom != .phone{
        return false
    }
    if #available(iOS 11, *) {
        let mainWindow = DnpToolCommon.getKeyWindow()
        if let window = mainWindow{
            if window.safeAreaInsets.bottom > CGFloat(0.0) {
                iphonex = true
            }
        }
    }
    return iphonex
}

// MARK: 16进制颜色RGB
extension UIColor{
    static func dnp_colorWithHex(hex: Int32,alpha: CGFloat)-> UIColor {
        return UIColor(red: CGFloat(((hex >> 16) & 0xFF))/255.0, green: CGFloat(((hex >> 8) & 0xFF))/255.0, blue: CGFloat((hex & 0xFF))/255.0, alpha: alpha)
    }
    static func rgb(red: CGFloat,green: CGFloat,blue: CGFloat,alpha: CGFloat = 1.0) -> UIColor{
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
}

class DnpToolCommon: NSObject {
    internal static func getKeyWindow() -> UIWindow? {
        var keyWindow : UIWindow? = nil
        if let delegateWindow = UIApplication.shared.delegate?.window , delegateWindow != nil {
            keyWindow = delegateWindow
        }else{
            let windows = UIApplication.shared.windows
            for window in windows {
                if !window.isHidden {
                    keyWindow = window
                    break
                }
            }
        }
        return keyWindow
    }
}


// MARK: 当前资源Bundle
internal class DnpBundle {
    static func getBundlePath(resource name: String,ofType type: String) -> String? {
        var bundle = Bundle(for: DnpToolCommon.self)
        if let resource = bundle.resourcePath, let resourceBundle = Bundle(path: resource + "/DnpLog.bundle") {
            bundle = resourceBundle
        }
        return bundle.path(forResource: name, ofType: type)
    }
}

// MARK: Bundle中图片
extension UIImage {
    static func imageName(name: String) -> UIImage? {
        var imageName = name
        let scale = UIScreen.main.scale
        if abs(scale - 3) <= 0.001 {
            imageName = name + "@3x"
        }else if abs(scale - 2) <= 0.001 {
            imageName = name + "@2x"
        }
        var image: UIImage? = nil
        if let m_path = DnpBundle.getBundlePath(resource: imageName, ofType: "png") {
            image = UIImage(contentsOfFile: m_path)
        }
        if image == nil {
            image = UIImage(named: name)
        }
        return image
    }
}

// MARK: 当前类名
extension NSObject{
    var classname: String{
        get{
            let name =  type(of: self).description()
            if(name.contains(".")){
                return name.components(separatedBy: ".")[1];
            }else{
                return name;
            }
        }
    }
}

// MARK: 字体估算高度
extension NSString{
    func calculateSize(limitSize: CGSize,font: UIFont,lineSpace: CGFloat) -> CGSize {
        var attributes = [NSAttributedString.Key: Any]()
        if lineSpace > 0{
            let style = NSMutableParagraphStyle()
            style.lineSpacing = lineSpace
            attributes = [NSMutableAttributedString.Key.paragraphStyle : style,
                          NSMutableAttributedString.Key.font : font]
        }else{
            attributes = [NSMutableAttributedString.Key.font : font]
        }
        return self.boundingRect(with: limitSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size
    }
}

// MARK: TableView`s reuseIdentifier
protocol ReuseViewProtocol: NSObjectProtocol {
    static var reuseIdentifier: String { get }
}

extension UIView: ReuseViewProtocol {
    static var reuseIdentifier: String {
        return "\(self)"
    }
}

internal let ShowNotification = "ShowPluginNotificationName"
internal let CloseNotification = "ClosePluginNotificationName"

/// Use for Log Notification Name
//internal let DnpLogNotification = "DnpLogNotification"
/// 快速开启Log
internal let DnpOpenLogModule = "DnpLogOpenMoudle"

/*
 Use for Log Notification userInfo key
 
 NotificationCenter.default.post(name: NSNotification.Name(rawValue: DnpLogNotification), object: nil,userInfo: [DnpLog:[String: Any])
 */
//internal let DnpLog = "DnpLog"

/// exit(0);Kill App
