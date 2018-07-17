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
//    kv3.strVal = @"hello";
    
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
    ALMMKV *mmkv = [ALMMKV mmkvWithPath:path];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    
    NSMutableDictionary *dict = [@{} mutableCopy];
    for (int i = 0; i < 10000; ++i) {
        dict[[NSString stringWithFormat:@"int_%d", i]] = @(i);
    }
    
    CFTimeInterval t = CFAbsoluteTimeGetCurrent();
    for (NSString *key in dict.allKeys) {
        [mmkv setInteger:[dict[key] intValue] forKey:key];
    }
    t = (CFAbsoluteTimeGetCurrent() - t) * 1000;
    NSLog(@"== mmkv write int; time:         %fms", t);
    
    t = CFAbsoluteTimeGetCurrent();
    for (NSString *key in dict.allKeys) {
        [defaults setInteger:[dict[key] intValue] forKey:key];
        [defaults synchronize];
    }
    t = (CFAbsoluteTimeGetCurrent() - t) * 1000;
    NSLog(@"== userdefaults write int; time: %fms", t);
    
    ///////////////////////////
    [dict removeAllObjects];
    for (int i = 0; i < 10000; ++i) {
        dict[[NSString stringWithFormat:@"string_%d", i]] = [NSString stringWithFormat:@"string value: %d", i];
    }
    t = CFAbsoluteTimeGetCurrent();
    for (NSString *key in dict.allKeys) {
        [mmkv setObject:dict[key] forKey:key];
    }
    t = (CFAbsoluteTimeGetCurrent() - t) * 1000;
    NSLog(@"== mmkv write string; time:         %fms", t);
    
    t = CFAbsoluteTimeGetCurrent();
    for (NSString *key in dict.allKeys) {
        [defaults setObject:dict[key] forKey:key];
        [defaults synchronize];
    }
    t = (CFAbsoluteTimeGetCurrent() - t) * 1000;
    NSLog(@"== userdefaults write string; time: %fms", t);
}

- (void)testMMKVRead {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    path = [path stringByAppendingPathComponent:@"test.mmkv"];
    {
        ALMMKV *mmkv = [ALMMKV mmkvWithPath:path];
        [mmkv reset];
        
        NSMutableDictionary *dict = [@{} mutableCopy];
        for (int i = 0; i < 10000; ++i) {
            dict[[NSString stringWithFormat:@"settings_key_string_%d", i]] = @(i);
        }
        for (NSString *key in dict.allKeys) {
            [mmkv setInteger:[dict[key] intValue] forKey:key];
        }
        
        [dict removeAllObjects];
        for (int i = 0; i < 10000; ++i) {
            dict[[NSString stringWithFormat:@"settings_key_string_%d", i]] = [NSString stringWithFormat:@"string value: %d", i];
        }
        for (NSString *key in dict.allKeys) {
            [mmkv setObject:dict[key] forKey:key];
        }
    }
    
    {
        ALMMKV *mmkv = [ALMMKV mmkvWithPath:path];
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
}

- (void)testUserDefault {
    NSUserDefaults *dft = [NSUserDefaults standardUserDefaults];
    NSString *intKey = @"int_key";
    [dft setInteger:1234 forKey:intKey];
    NSLog(@"--- int ---");
    NSLog(@"int:      %ld", [dft integerForKey:intKey]);
    NSLog(@"float:    %f", [dft floatForKey:intKey]);
    NSLog(@"NSString: %@", [dft stringForKey:intKey]);
    NSLog(@"NSData:   %@", [dft dataForKey:intKey]);
    NSLog(@"NSObject: %@", [dft objectForKey:intKey]);
    
    NSString *strKey = @"str_key";
    [dft setObject:@"1234" forKey:strKey];
    NSLog(@"--- str ---");
    NSLog(@"int:      %ld", [dft integerForKey:strKey]);
    NSLog(@"float:    %f", [dft floatForKey:strKey]);
    NSLog(@"NSString: %@", [dft stringForKey:strKey]);
    NSLog(@"NSData:   %@", [dft dataForKey:strKey]);
    NSLog(@"NSObject: %@", [dft objectForKey:strKey]);
    
    NSString *dataKey = @"data_key";
    [dft setObject:[@"hello" dataUsingEncoding:NSUTF8StringEncoding] forKey:dataKey];
    NSLog(@"--- data ---");
    NSLog(@"int:      %ld", [dft integerForKey:dataKey]);
    NSLog(@"float:    %f", [dft floatForKey:dataKey]);
    NSLog(@"NSString: %@", [dft stringForKey:dataKey]);
    NSLog(@"NSData:   %@", [dft dataForKey:dataKey]);
    NSLog(@"NSObject: %@", [dft objectForKey:dataKey]);
    
    NSString *dateKey = @"date_key";
    [dft setObject:[NSDate date] forKey:dateKey];
    NSLog(@"--- data ---");
    NSLog(@"int:      %ld", [dft integerForKey:dateKey]);
    NSLog(@"float:    %f", [dft floatForKey:dateKey]);
    NSLog(@"NSString: %@", [dft stringForKey:dateKey]);
    NSLog(@"NSData:   %@", [dft dataForKey:dateKey]);
    NSLog(@"NSObject: %@", [dft objectForKey:dateKey]);
    
    NSString *numKey = @"nsnumber_key";
    [dft setObject:@12.34 forKey:numKey];
    NSLog(@"--- nsnumber ---");
    NSLog(@"int:      %ld", [dft integerForKey:numKey]);
    NSLog(@"float:    %f", [dft floatForKey:numKey]);
    NSLog(@"NSString: %@", [dft stringForKey:numKey]);
    NSLog(@"NSData:   %@", [dft dataForKey:numKey]);
    NSLog(@"NSObject: %@", [dft objectForKey:numKey]);
    
    NSString *numDataKey1 = @"num_data_key1";
    [dft setObject:[NSKeyedArchiver archivedDataWithRootObject:@1234] forKey:numDataKey1];
    NSLog(@"--- num data1 ---");
    NSLog(@"int:      %ld", [dft integerForKey:numDataKey1]);
    NSLog(@"float:    %f", [dft floatForKey:numDataKey1]);
    NSLog(@"NSString: %@", [dft stringForKey:numDataKey1]);
    NSLog(@"NSData:   %@", [dft dataForKey:numDataKey1]);
    NSLog(@"NSObject: %@", [dft objectForKey:numDataKey1]);
    
//    NSString *numDataKey2 = @"num_data_key2";
//    int iv = 1234;
//    [dft setObject:[NSValue valueWithPointer:&iv] forKey:numDataKey2];
//    NSLog(@"--- num data1 ---");
//    NSLog(@"int:      %ld", [dft integerForKey:numDataKey2]);
//    NSLog(@"float:    %f", [dft floatForKey:numDataKey2]);
//    NSLog(@"NSString: %@", [dft stringForKey:numDataKey2]);
//    NSLog(@"NSData:   %@", [dft dataForKey:numDataKey2]);
//    NSLog(@"NSObject: %@", [dft objectForKey:numDataKey2]);
}

- (void)testProtobuf {
    ALKVPair *kv = [ALKVPair message];
    kv.name = @"test_int_key";
    kv.sint32Val = 1234;
    CFTimeInterval t = CFAbsoluteTimeGetCurrent();
    for (int i = 0; i < 10000; ++i) {
        [kv delimitedData];
    }
    NSLog(@"format int: %fms", (CFAbsoluteTimeGetCurrent() - t) * 1000);
    
    kv.name = @"test_str_key";
//    kv.strVal = @"NSUserDefaults *dft = [NSUserDefaults standardUserDefaults];";
    t = CFAbsoluteTimeGetCurrent();
    for (int i = 0; i < 10000; ++i) {
        [kv delimitedData];
    }
    NSLog(@"format str: %fms", (CFAbsoluteTimeGetCurrent() - t) * 1000);
}

- (void)testMultiThread {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    path = [path stringByAppendingPathComponent:@"test.mmkv"];
    void (^mmkv_job)(NSString *) = ^(NSString *name) {
        {
            ALMMKV *mmkv = [ALMMKV mmkvWithPath:path];
            XCTAssertNotNil(mmkv);
            
            [mmkv setBool:YES forKey:[name stringByAppendingString:@"_bool"]];
            NSLog(@"[JOB: %@; %@] write bool", name, mmkv);
            
            [mmkv setObject:[NSDate date] forKey:[name stringByAppendingString:@"_date"]];
            NSLog(@"[JOB: %@; %@] write date", name, mmkv);
            
            [mmkv setObject:name forKey:[name stringByAppendingString:@"_str"]];
            NSLog(@"[JOB: %@; %@] write string", name, mmkv);
        }
        
        {
            ALMMKV *mmkv = [ALMMKV mmkvWithPath:path];
            XCTAssertNotNil(mmkv);
            id obj = [mmkv objectOfClass:NSDate.class forKey:[name stringByAppendingString:@"_date"]];
            XCTAssertNotNil(obj);
            NSLog(@"[JOB: %@; %@] read date: %@", name, mmkv, obj);
            
            obj = [mmkv objectOfClass:NSString.class forKey:[name stringByAppendingString:@"_str"]];
            XCTAssertNotNil(obj);
            NSLog(@"[JOB: %@; %@] read str: %@", name, mmkv, obj);
            
            obj = [mmkv objectOfClass:NSNumber.class forKey:[name stringByAppendingString:@"_bool"]];
            XCTAssertNotNil(obj);
            NSLog(@"[JOB: %@; %@] read bool: %@", name, mmkv, obj);
        }
    };
    
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue =  dispatch_queue_create("mmkv-test", DISPATCH_QUEUE_CONCURRENT);
    
    for (int i = 0; i < 20; ++i) {
        dispatch_group_async(group, queue, ^{
            mmkv_job([NSString stringWithFormat:@"MMKV-Test-%02d", i]);
        });
    }
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
#if DEBUG
    [ALMMKV dump];
#endif
    NSLog(@"== DONE ==");
}

- (void)testDefaultMMKV {
    [[ALMMKV defaultMMKV] reset];
    [[ALMMKV defaultMMKV] setObject:@"hello mmkv" forKey:@"string"];
    NSLog(@"read string: %@", [[ALMMKV defaultMMKV] objectOfClass:NSString.class forKey:@"string"]);
    
#if DEBUG
    [ALMMKV dump];
#endif
}

- (void)testRemoveKey {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    path = [path stringByAppendingPathComponent:@"test.mmkv"];
    {
        ALMMKV *mmkv = [ALMMKV mmkvWithPath:path];
        [mmkv reset];
        [mmkv setObject:[NSDate date] forKey:@"date"];
        
        [mmkv setObject:@"hello mmkv" forKey:@"string"];
        NSLog(@"read string: %@", [mmkv objectOfClass:NSString.class forKey:@"string"]);
        NSLog(@"read data:   %@", [mmkv objectOfClass:NSDate.class forKey:@"date"]);

        NSLog(@"remove key: string");
        [mmkv removeObjectForKey:@"string"];
        NSLog(@"read string: %@", [mmkv objectOfClass:NSString.class forKey:@"string"]);
        NSLog(@"read data:   %@", [mmkv objectOfClass:NSDate.class forKey:@"date"]);
    }
#if DEBUG
    [ALMMKV dump];
#endif
    NSLog(@"------------");
    NSLog(@"read string: %@", [[ALMMKV mmkvWithPath:path] objectOfClass:NSString.class forKey:@"string"]);
    NSLog(@"read data:   %@", [[ALMMKV mmkvWithPath:path] objectOfClass:NSDate.class forKey:@"date"]);
}

@end
