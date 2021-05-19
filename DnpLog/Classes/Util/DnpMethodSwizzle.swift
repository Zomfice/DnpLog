//
//  DnpMethodSwizzle.swift
//  DnpLog
//
//  Created by Fice on 2021/5/19.
//

import Foundation


extension NSObject{
    
    @objc static func swizzleClassMethodWithOriginSel(oriSel: Selector,swiSel: Selector) {
        let cls = self
        let originAddObserverMethod = class_getClassMethod(cls, oriSel)
        let swizzledAddObserverMethod = class_getClassMethod(cls, swiSel)
        
        self.swizzleMethodWithOriginSel(oriSel: oriSel, oriMethod: originAddObserverMethod, swizzledSel: swiSel, swizzledMethod: swizzledAddObserverMethod, cls: cls)
    }
    
   @objc static func swizzleInstanceMethodWithOriginSel(oriSel: Selector,swiSel: Selector) {
        let originAddObserverMethod = class_getInstanceMethod(self, oriSel)
        let swizzledAddObserverMethod = class_getInstanceMethod(self, swiSel)
        self.swizzleMethodWithOriginSel(oriSel: oriSel, oriMethod: originAddObserverMethod, swizzledSel: swiSel, swizzledMethod: swizzledAddObserverMethod, cls: self)
    }
    
    @objc static func swizzleMethodWithOriginSel(oriSel: Selector,oriMethod: Method?,swizzledSel: Selector,swizzledMethod: Method?,cls: AnyClass?) {
        guard (oriMethod != nil && swizzledMethod != nil) else {
            return
        }
        let didAddMethod = class_addMethod(cls, oriSel, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
        if didAddMethod {
            class_replaceMethod(cls, swizzledSel, method_getImplementation(oriMethod!), method_getTypeEncoding(oriMethod!))
        }else{
            method_exchangeImplementations(oriMethod!, swizzledMethod!)
        }
    }
    
}
