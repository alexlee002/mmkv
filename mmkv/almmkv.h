//
//  mmkv.h
//  mmkv
//
//  Created by Alex Lee on 2018/7/11.
//  Copyright © 2018 alexlee002. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for mmkv.
FOUNDATION_EXPORT double mmkvVersionNumber;

//! Project version string for mmkv.
FOUNDATION_EXPORT const unsigned char mmkvVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <mmkv/PublicHeader.h>


NS_ASSUME_NONNULL_BEGIN
@interface ALMMKV : NSObject

+ (nullable instancetype)defaultMMKV;
+ (nullable instancetype)mmkvWithPath:(NSString *)path;

- (BOOL)boolForKey:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key;
- (float)floatForKey:(NSString *)key;
- (double)doubleForKey:(NSString *)key;
- (nullable id)objectOfClass:(Class)cls forKey:(NSString *)key;

- (void)setBool:(BOOL)val forKey:(NSString *)key;
- (void)setInteger:(NSInteger)intval forKey:(NSString *)key;
- (void)setFloat:(float)val forKey:(NSString *)key;
- (void)setDouble:(double)val forKey:(NSString *)key;
- (void)setObject:(nullable id)obj forKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key;
- (void)reset;

#if DEBUG
+ (void)dump;
#endif
@end

NS_ASSUME_NONNULL_END
