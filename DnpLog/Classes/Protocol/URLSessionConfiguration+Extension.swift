//
//  URLSession+Extension.swift
//  DnpLog
//
//  Created by Fice on 2021/5/19.
//

import Foundation


public extension URLSessionConfiguration {

    @objc static func initLoad() {
        print("方法交换l ")
//        self.swizzleClassMethodWithOriginSel(oriSel: #selector(getter: URLSessionConfiguration.default), swiSel: #selector(getter: URLSessionConfiguration.dnp_defaultSessionConfiguration))
//        self.swizzleInstanceMethodWithOriginSel(oriSel: #selector(getter: self.default), swiSel: #selector(dnp_defaultSessionConfiguration))
//        self.swizzleClassMethodWithOriginSel(oriSel: #selector(getter: self.ephemeral), swiSel: #selector(dnp_ephemeralSessionConfiguration))
        //URLSessionConfiguration.swizzleClassMethodWithOriginSel(oriSel: #selector(background(withIdentifier:)), swiSel: #selector(dnpbackground(withIdentifier:)))
        //UIView.swizzleInstanceMethodWithOriginSel(oriSel: #selector(UIView.layoutSubviews), swiSel: #selector(dnp_layoutSubviews))

//        let originalSelector = #selector(UITableView.insertSections(_:with:))
//        let swizzledSelector = #selector(zl_insertSections(_:with:))
//        UIView.exchangeMethod(selector: originalSelector, replace: swizzledSelector, class: UITableView.self)
//
    }

    @objc func zl_insertSections(_ sections: NSIndexSet, with animation: UITableView.RowAnimation) {
        print("方法交换了啊--")
        zl_insertSections(sections, with: animation)
        print("方法交换了啊")
    }

    @objc class func dnpbackground(withIdentifier identifier: String) -> URLSessionConfiguration{
        print("方法交换了啊")
        return self.dnpbackground(withIdentifier: identifier)
    }

    @objc class var dnp_defaultSessionConfiguration: URLSessionConfiguration
    {
        print("方法交换了啊")
        let configuration = self.dnp_defaultSessionConfiguration
        configuration.addURLProtocol()
        return configuration
    }

//    @objc static func dnp_defaultSessionConfiguration() -> URLSessionConfiguration {
//        print("交换1")
//        let configuration = self.dnp_defaultSessionConfiguration()
//        configuration.addURLProtocol()
//        return configuration
//    }

    @objc static func dnp_ephemeralSessionConfiguration() -> URLSessionConfiguration {
        print("交换2")
        let configuration = self.dnp_ephemeralSessionConfiguration()
        configuration.addURLProtocol()
        return configuration
    }

    func addURLProtocol() {
        if self.responds(to: #selector(getter: URLSessionConfiguration.protocolClasses)),
           self.responds(to: #selector(setter: URLSessionConfiguration.protocolClasses)){
            guard let protocolClasses = self.protocolClasses else {
                print("交换失败")
                return
            }
            let urlProtocolClasses = NSMutableArray(array: protocolClasses)
            let protoCls = DnpURLProtocol.self
            if !urlProtocolClasses.contains(protoCls) {
                urlProtocolClasses.insert(protoCls, at: 0)
            }
            if let classList = urlProtocolClasses as? [AnyClass] {
                self.protocolClasses = classList
            }
            print("--娃娃")
        }else{
            print("--怎么了")
        }
    }

}

