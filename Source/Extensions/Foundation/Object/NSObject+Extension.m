#import "NSObject+Extension.h"
#import <objc/runtime.h>

@implementation NSObject (Extension)

+ (BOOL)swizzleMethod:(SEL)originalSelector withMethod:(SEL)swizzledSelector {
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
    if (originalMethod == NULL || swizzledMethod == NULL) {
        return NO;
    }
    BOOL didAddMethod = class_addMethod(self,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(self,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    return YES;
}

+ (BOOL)swizzleClassMethod:(SEL)originalSelector withClassMethod:(SEL)swizzledSelector {
    Method originalMethod = class_getClassMethod(self, originalSelector);
    Method swizzledMethod = class_getClassMethod(self, swizzledSelector);
    if (originalMethod == NULL || swizzledMethod == NULL) {
        return NO;
    }
    BOOL didAddMethod = class_addMethod(self,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(self,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    return YES;
}

- (BOOL)swizzleMethod:(SEL)originalSelector withMethod:(SEL)swizzledSelector {
    Class class = [self class];
    NSString *subclassName = [NSStringFromClass(class) stringByAppendingFormat:@"_OFSwizzle_%@", [[NSUUID UUID] UUIDString]];
    Class subclass = objc_allocateClassPair(class, [subclassName UTF8String], 0);
    objc_registerClassPair(subclass);
    if ([subclass swizzleMethod:originalSelector withMethod:swizzledSelector]) {
        object_setClass(self, subclass);
        return YES;
    } else {
        return NO;
    }
}

- (NSMutableDictionary *)userInfo {
    NSMutableDictionary *mutableDictionary = objc_getAssociatedObject(self, _cmd);
    if (!mutableDictionary) {
        mutableDictionary = [NSMutableDictionary new];
        objc_setAssociatedObject(self, _cmd, mutableDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return mutableDictionary;
}

@end
