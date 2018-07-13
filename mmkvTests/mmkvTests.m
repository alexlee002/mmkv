//
//  mmkvTests.m
//  mmkvTests
//
//  Created by Alex Lee on 2018/7/11.
//  Copyright © 2018 alexlee002. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Almmkv.pbobjc.h"
#import "almmkv.h"

@interface mmkvTests : XCTestCase

@end

@implementation mmkvTests

- (void)testProtobufMessage {
    
    ALKVPair *kv1 = [ALKVPair message];
    kv1.name = @"setting_1";
    kv1.sint32Val = 1024;
    
    ALKVPair *kv2 = [ALKVPair message];
    kv2.name = @"setting_1";
    kv2.floatVal = 10.24;
    
    ALKVPair *kv3 = [ALKVPair message];
    kv3.name = @"setting_1";
    kv3.strVal = @"hello";
    
    ALKVList *store = [ALKVList message];
    store.itemArray = @[kv1].mutableCopy;
    NSMutableData *data = [NSMutableData dataWithBytes:"\n" length:1];
    [data appendData:kv1.delimitedData];
    NSLog(@">> %@", data);
    NSLog(@"== %@", store.data);
    
    [store.itemArray addObject:kv2];
    [data appendBytes:"\n" length:1];
    [data appendData:kv2.delimitedData];
    NSLog(@">> %@", data);
    NSLog(@"== %@", store.data);
    
    [store.itemArray addObject:kv3];
    [data appendBytes:"\n" length:1];
    [data appendData:kv3.delimitedData];
    NSLog(@">> %@", data);
    NSLog(@"== %@", store.data);
    
//    store.itemArray = @[kv1].mutableCopy;
//    NSLog(@"store:   %@", store.data);
//    NSLog(@"kv1(d):  %@", kv1.data);
//    NSLog(@"kv1(dd): %@", kv1.delimitedData);
//
//    store.itemArray = @[kv1, kv2].mutableCopy;
//    NSLog(@">> %@", store.data);
//    NSMutableData *d = kv1.delimitedData.mutableCopy;
//    [d appendData:kv2.delimitedData];
//    NSLog(@"== %@", d);
//    NSLog(@"++ %@", kv2.delimitedData);
//
//    store.itemArray = @[kv1, kv2, kv3].mutableCopy;
//    NSLog(@">> %@", store.data);
//    [d appendData:kv3.data];
//    NSLog(@"== %@", d);
//    NSLog(@"++ %@", kv3.data);
//
    
    //-------
//    ALKVList *store1 = [ALKVList parseFromData:store.data error:nil];
//    ALKVPair *kv = store1.itemArray[0];
//    NSLog(@"%@ = %d", kv.name, kv.sint32Val);
//    XCTAssertEqual(kv.sint32Val, 1024);
//
//    kv = store1.itemArray[1];
//    NSLog(@"%@ = %f", kv.name, kv.floatVal);
//    XCTAssert(ABS(kv.floatVal - 10.24) < 0.00001);
//
//    kv = store1.itemArray[2];
//    NSLog(@"%@ = %@", kv.name, kv.strVal);
//    XCTAssertEqualObjects(kv.strVal, @"hello");
//    NSLog(@"%@ = %f", kv.name, kv.floatVal);
    
}

- (void)testALMMKVWrite {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    path = [path stringByAppendingPathComponent:@"test.mmkv"];
    ALMMKV *mmkv = [[ALMMKV alloc] initWithFile:path];
    NSMutableDictionary *dict = [@{} mutableCopy];
    for (int i = 0; i < 10000; ++i) {
        dict[[NSString stringWithFormat:@"settings_key_string_%d", i]] = @(i);
    }
    CFTimeInterval t = CFAbsoluteTimeGetCurrent();
   for (NSString *key in dict.allKeys) {
        [mmkv setInteger:[dict[key] intValue] forKey:key];
    }
    t = (CFAbsoluteTimeGetCurrent() - t) * 1000;
    NSLog(@"== time: %fms", t);
    
    [mmkv reset];
    [dict removeAllObjects];
    for (int i = 0; i < 10000; ++i) {
        dict[[NSString stringWithFormat:@"settings_key_string_%d", i]] = [NSString stringWithFormat:@"string value: %d", i];
    }
    t = CFAbsoluteTimeGetCurrent();
    for (NSString *key in dict.allKeys) {
        [mmkv setObject:dict[key] forKey:key];
    }
    t = (CFAbsoluteTimeGetCurrent() - t) * 1000;
    NSLog(@"== time: %fms", t);
}

- (void)testMMKVRead {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    path = [path stringByAppendingPathComponent:@"test.mmkv"];
    ALMMKV *mmkv = [[ALMMKV alloc] initWithFile:path];
    NSMutableDictionary *dict = [@{} mutableCopy];
    for (int i = 0; i < 10000; ++i) {
        dict[[NSString stringWithFormat:@"settings_key_string_%d", i]] = @(i);
    }
    CFTimeInterval t = CFAbsoluteTimeGetCurrent();
    for (NSString *key in dict.allKeys) {
        [mmkv integerForKey:key];
    }
    t = (CFAbsoluteTimeGetCurrent() - t) * 1000;
    NSLog(@"== time: %fms", t);
    
    [mmkv reset];
    [dict removeAllObjects];
    for (int i = 0; i < 10000; ++i) {
        dict[[NSString stringWithFormat:@"settings_key_string_%d", i]] = [NSString stringWithFormat:@"string value: %d", i];
    }
    t = CFAbsoluteTimeGetCurrent();
    for (NSString *key in dict.allKeys) {
        [mmkv objectOfClass:NSString.class forKey:key];
    }
    t = (CFAbsoluteTimeGetCurrent() - t) * 1000;
    NSLog(@"== time: %fms", t);
}

//- (void)setUp {
//    [super setUp];
//    // Put setup code here. This method is called before the invocation of each test method in the class.
//}
//
//- (void)tearDown {
//    // Put teardown code here. This method is called after the invocation of each test method in the class.
//    [super tearDown];
//}
//
//- (void)testExample {
//    // This is an example of a functional test case.
//    // Use XCTAssert and related functions to verify your tests produce the correct results.
//}
//
//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
