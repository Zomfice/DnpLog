//
//  NSURLSessionConfiguration+XX.m
//  DnpLog
//
//  Created by Fice on 2021/5/19.
//

#import "NSURLSessionConfiguration+XX.h"
#import <objc/runtime.h>
#import <DnpLog/DnpLog-Swift.h>

@interface NSObject (Doraemon)

/**
 swizzle 类方法
 
 @param oriSel 原有的方法
 @param swiSel swizzle的方法
 */
+ (void)doraemon_swizzleClassMethodWithOriginSel:(SEL)oriSel swizzledSel:(SEL)swiSel;

/**
 swizzle 实例方法
 
 @param oriSel 原有的方法
 @param swiSel swizzle的方法
 */
+ (void)doraemon_swizzleInstanceMethodWithOriginSel:(SEL)oriSel swizzledSel:(SEL)swiSel;

@end


@implementation NSObject (Doraemon)

+ (void)doraemon_swizzleClassMethodWithOriginSel:(SEL)oriSel swizzledSel:(SEL)swiSel {
    Class cls = object_getClass(self);
    
    Method originAddObserverMethod = class_getClassMethod(cls, oriSel);
    Method swizzledAddObserverMethod = class_getClassMethod(cls, swiSel);
    
    [self swizzleMethodWithOriginSel:oriSel oriMethod:originAddObserverMethod swizzledSel:swiSel swizzledMethod:swizzledAddObserverMethod class:cls];
}

+ (void)doraemon_swizzleInstanceMethodWithOriginSel:(SEL)oriSel swizzledSel:(SEL)swiSel {
    Method originAddObserverMethod = class_getInstanceMethod(self, oriSel);
    Method swizzledAddObserverMethod = class_getInstanceMethod(self, swiSel);
    
    [self swizzleMethodWithOriginSel:oriSel oriMethod:originAddObserverMethod swizzledSel:swiSel swizzledMethod:swizzledAddObserverMethod class:self];
}

+ (void)swizzleMethodWithOriginSel:(SEL)oriSel
                         oriMethod:(Method)oriMethod
                       swizzledSel:(SEL)swizzledSel
                    swizzledMethod:(Method)swizzledMethod
                             class:(Class)cls {
    BOOL didAddMethod = class_addMethod(cls, oriSel, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(cls, swizzledSel, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
    } else {
        method_exchangeImplementations(oriMethod, swizzledMethod);
    }
}

@end

@implementation NSURLSessionConfiguration (XX)

+ (void)load{
    [NSURLProtocol registerClass:[DnpURLProtocol class]];
    [[self class] doraemon_swizzleClassMethodWithOriginSel:@selector(defaultSessionConfiguration) swizzledSel:@selector(doraemon_defaultSessionConfiguration)];
    [[self class] doraemon_swizzleClassMethodWithOriginSel:@selector(ephemeralSessionConfiguration) swizzledSel:@selector(doraemon_ephemeralSessionConfiguration)];
}

+ (NSURLSessionConfiguration *)doraemon_defaultSessionConfiguration{
    NSURLSessionConfiguration *configuration = [self doraemon_defaultSessionConfiguration];
    [configuration addDoraemonNSURLProtocol];
    return configuration;
}

+ (NSURLSessionConfiguration *)doraemon_ephemeralSessionConfiguration{
    NSURLSessionConfiguration *configuration = [self doraemon_ephemeralSessionConfiguration];
    [configuration addDoraemonNSURLProtocol];
    return configuration;
}

- (void)addDoraemonNSURLProtocol {
    if ([self respondsToSelector:@selector(protocolClasses)]
        && [self respondsToSelector:@selector(setProtocolClasses:)]) {
        NSMutableArray * urlProtocolClasses = [NSMutableArray arrayWithArray: self.protocolClasses];
        Class protoCls = DnpURLProtocol.class;
        if (![urlProtocolClasses containsObject:protoCls]) {
            [urlProtocolClasses insertObject:protoCls atIndex:0];
        }
        self.protocolClasses = urlProtocolClasses;
    }
}


@end


