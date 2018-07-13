//
//  almmkv.m
//  mmkv
//
//  Created by Alex Lee on 2018/7/12.
//  Copyright © 2018 alexlee002. All rights reserved.
//

#import "almmkv.h"
#import "Almmkv.pbobjc.h"
#import <sys/mman.h>
#import <sys/stat.h>

static size_t kPageSize = 256 * 1024;
@implementation ALMMKV {
    int _fd;
    NSString *_path;
    void *_mmptr;
    size_t _mmsize;
    size_t _cursize;
    
    NSMutableDictionary<NSString *, ALKVPair *> *_dict;
}

- (instancetype)initWithFile:(NSString *)path {
    self = [super init];
    if (self) {
        _fd = open([path fileSystemRepresentation], O_RDWR | O_CREAT, 0666);
        if (_fd == 0) {
            NSAssert(NO, @"Can not open file: %@", path);
            return nil;
        }
        struct stat statInfo;
        if( fstat( _fd, &statInfo ) != 0 ) {
            [self cleanup];
            NSAssert(NO, @"Can not read file: %@", path);
            return nil;
        }
        
        _mmsize = ((statInfo.st_size / kPageSize) + 1) * kPageSize;
        ftruncate(_fd, _mmsize);
        _mmptr = mmap(NULL, _mmsize, PROT_READ | PROT_WRITE, MAP_FILE | MAP_SHARED, _fd, 0);
        if (_mmptr == MAP_FAILED) {
            [self cleanup];
            NSAssert(NO, @"mmap failed. error: %d", errno);
            return nil;
        }
        _path = [path copy];
        [self load];
    }
    return self;
}

- (void)dealloc {
    [self cleanup];
}

- (void)cleanup {
    if (_mmptr) {
        munmap(_mmptr, _cursize);
    }
    if (_fd) {
        ftruncate(_fd, _cursize);
        close(_fd);
    }
}

- (NSInteger)integerForKey:(NSString *)key {
    ALKVPair *kv = _dict[key];
    switch (kv.valueOneOfCase) {
        case ALKVPair_FieldNumber_Sint32Val: return kv.sint32Val;
        case ALKVPair_FieldNumber_Sint64Val: return kv.sint64Val;
        case ALKVPair_FieldNumber_BoolVal: return (NSInteger)kv.boolVal;
        case ALKVPair_FieldNumber_FloatVal: return (NSInteger)kv.floatVal;
        case ALKVPair_FieldNumber_DoubleVal: return (NSInteger)kv.doubleVal;
        case ALKVPair_FieldNumber_BinaryVal:
            @try {
                id obj = [NSKeyedUnarchiver unarchiveObjectWithData:kv.binaryVal];
                if ([obj isKindOfClass:NSNumber.class] || [obj isKindOfClass:NSString.class]) {
                    return [obj integerValue];
                }
            } @catch (NSException *exception) {}
            return 0;
        case ALKVPair_FieldNumber_StrVal: return [kv.strVal integerValue];
        default: return 0;
    }
}

- (id)objectOfClass:(Class)cls forKey:(NSString *)key {
    ALKVPair *kv = _dict[key];
    id val = nil;
    if (kv.valueOneOfCase == ALKVPair_FieldNumber_StrVal) {
        val = kv.strVal;
    } else if (kv.valueOneOfCase == ALKVPair_FieldNumber_BinaryVal) {
        @try {
            val = [NSKeyedUnarchiver unarchiveObjectWithData:kv.binaryVal];
        } @catch (NSException *exception) {}
    }
    
    return [val isKindOfClass:cls] ? val : nil;
}


- (BOOL)setInteger:(NSInteger)intval forKey:(NSString *)key {
    ALKVPair *kv = [ALKVPair message];
    kv.name = key;
    if (intval > INT_MAX) {
        kv.sint64Val = (int64_t)intval;
    } else {
        kv.sint32Val = (int32_t)intval;
    }
    [self append:kv];
    return YES;
}

- (BOOL)setObject:(id)obj forKey:(NSString *)key {
    ALKVPair *kv = [ALKVPair message];
    kv.name = key;
    if ([obj isKindOfClass:NSString.class]) {
        kv.strVal = (NSString *)obj;
    } else if ([obj isKindOfClass:NSData.class]) {
        kv.binaryVal = (NSData *)obj;
    }
    
    [self append:kv];
    return YES;
}

- (void)reset {
    [_dict removeAllObjects];
    
    munmap(_mmptr, _mmsize);
    _mmsize = kPageSize;
    ftruncate(_fd, _mmsize);
    _mmptr = mmap(NULL, _mmsize, PROT_READ | PROT_WRITE, MAP_FILE | MAP_SHARED, _fd, 0);
}

- (void)append:(ALKVPair *)item {
    _dict[item.name] = item;
    
    NSMutableData *data = [NSMutableData data];
    [data appendBytes:"\n" length:1];
    [data appendData:item.delimitedData];
    
    if (data.length + _cursize >= _mmsize) {
        [self reallocWithExtraSize:data.length];
    }
    memcpy(_mmptr + _cursize, data.bytes, data.length);
    _cursize += data.length;
}

- (void)load {
    _dict = [NSMutableDictionary dictionary];
    NSData *data = [NSData dataWithBytes:_mmptr length:_cursize];
    ALKVList *kvlist = [ALKVList parseFromData:data error:nil];
    for (ALKVPair *item in kvlist.itemArray) {
        if (item.name != nil) {
            _dict[item.name] = item;
        }
    }
}

- (void)reallocWithExtraSize:(size_t)size {
    ALKVList *kvlist = [ALKVList message];
    kvlist.itemArray = _dict.allValues.mutableCopy;
    NSData *data = kvlist.data;
    memcpy(_mmptr, data.bytes, data.length);
    _cursize = data.length;
    
    size_t newTotalSize = _cursize + size;
    if (newTotalSize >= _mmsize) {
        munmap(_mmptr, _mmsize);
        _mmsize = ((newTotalSize / kPageSize) + 1) * kPageSize;
        ftruncate(_fd, _mmsize);
        _mmptr = mmap(NULL, _mmsize, PROT_READ | PROT_WRITE, MAP_FILE | MAP_SHARED, _fd, 0);
    }
}
@end
