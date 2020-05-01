#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Extension)

+ (BOOL)swizzleMethod:(SEL)originalSelector withMethod:(SEL)swizzledSelector;
+ (BOOL)swizzleClassMethod:(SEL)originalSelector withClassMethod:(SEL)swizzledSelector;

- (BOOL)swizzleMethod:(SEL)originalSelector withMethod:(SEL)swizzledSelector; // swizzle only for current object

@property (nonatomic, strong, readonly) NSMutableDictionary *userInfo;

@end

NS_ASSUME_NONNULL_END
