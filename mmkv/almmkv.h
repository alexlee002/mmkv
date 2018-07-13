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


@interface ALMMKV : NSObject

- (instancetype)initWithFile:(NSString *)path;

- (NSInteger)integerForKey:(NSString *)key;
- (id)objectOfClass:(Class)cls forKey:(NSString *)key;

- (BOOL)setInteger:(NSInteger)intval forKey:(NSString *)key;
- (BOOL)setObject:(id)obj forKey:(NSString *)key;

- (void)reset;


@end
