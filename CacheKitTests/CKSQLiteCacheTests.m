//
//  CKSQLiteCacheTests.m
//  CacheKit
//
//  Created by David Beck on 10/13/14.
//  Copyright (c) 2014 David Beck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import <CacheKit/CacheKit.h>


@interface CKSQLiteCacheTests : XCTestCase
{
    CKSQLiteCache<NSNumber *> *_cache;
}

@end

@implementation CKSQLiteCacheTests

- (void)setUp
{
    [super setUp];
    
    _cache = [[CKSQLiteCache alloc] initWithName:@"Tests"];
}

- (void)tearDown
{
    [_cache removeAllObjects];
    
    [super tearDown];
}

- (void)testReadWrite
{
    [_cache setObject:@1 forKey:@"A"];
    XCTAssertTrue([_cache objectExistsForKey:@"A"], @"objectExistsForKey for key just added");
    XCTAssertEqualObjects([_cache objectForKey:@"A"], @1, @"objectForKey for key just added");
    
    [_cache removeObjectForKey:@"A"];
    XCTAssertFalse([_cache objectExistsForKey:@"A"], @"removeObjectForKey did not remove object");
}

- (void)testRemoveAll
{
    [_cache setObject:@1 forKey:@"A"];
    [_cache setObject:@2 forKey:@"B"];
    [_cache setObject:@3 forKey:@"C"];
    
    [_cache removeAllObjects];
    XCTAssertFalse([_cache objectExistsForKey:@"A"], @"removeAllObjects did not remove object");
    XCTAssertFalse([_cache objectExistsForKey:@"B"], @"removeAllObjects did not remove object");
    XCTAssertFalse([_cache objectExistsForKey:@"C"], @"removeAllObjects did not remove object");
}

- (void)testContentBlock
{
    XCTAssertFalse([_cache objectExistsForKey:@"A"], @"objectExistsForKey at beginning of test.");
    
    NSNumber *object = [_cache objectForKey:@"A" withContent:^{
        return @1;
    }];
    XCTAssertEqualObjects(object, @1, @"objectForKey:withContent: did not return correct object.");
    
    XCTAssertEqualObjects([_cache objectForKey:@"A"], @1, @"objectForKey for key just added");
}

- (void)testExpiration
{
    [_cache setObject:@1 forKey:@"A" expires:[NSDate dateWithTimeIntervalSinceNow:-1]];
    XCTAssertFalse([_cache objectExistsForKey:@"A"], @"Expired object exists.");
    XCTAssertEqualObjects([_cache objectForKey:@"A"], nil, @"Expired object returned.");
    
    NSNumber *object = [_cache objectForKey:@"A" withContent:^{
        return @2;
    }];
    XCTAssertEqualObjects(object, @2, @"objectForKey:withContent: did not return correct object.");
    
    XCTAssertEqualObjects([_cache objectForKey:@"A"], @2, @"objectForKey for key just added");
}

- (void)testPersistence
{
    NSString *name = _cache.name;
    
    [_cache setObject:@1 forKey:@"A"];
    [_cache setObject:@2 forKey:@"B"];
    [_cache setObject:@3 forKey:@"C"];
    
    _cache = [[CKSQLiteCache alloc] initWithName:name];
    
    XCTAssertEqualObjects([_cache objectForKey:@"B"], @2, @"Cache not persisted.");
}

- (void)testRemovingExpiredObjects
{
    [_cache setObject:@1 forKey:@"A" expiresIn:100];
    [_cache setObject:@2 forKey:@"B"];
    [_cache setObject:@3 forKey:@"C" expiresIn:-100];
    
    [_cache removeExpiredObjects];
    
    XCTAssertEqualObjects([_cache objectForKey:@"A"], @1, @"Object with future expiration removed.");
    XCTAssertEqualObjects([_cache objectForKey:@"B"], @2, @"Object without expiration removed.");
    XCTAssertFalse([_cache objectExistsForKey:@"C"], @"Expired object exists.");
    XCTAssertEqualObjects([_cache objectForKey:@"C"], nil, @"Object with past expiration not removed.");
}

- (void)testCacheHitPerformance
{
    [_cache setObject:@1 forKey:@"A"];
    [_cache setObject:@2 forKey:@"B"];
    [_cache setObject:@3 forKey:@"C"];
    for (NSUInteger i = 0; i < 1000; i++) {
        [_cache setObject:@(i) forKey:[NSString stringWithFormat:@"%lu", (unsigned long)i]];
    }
    
    [self measureBlock:^{
        [_cache clearInternalCache];
        XCTAssertEqualObjects([_cache objectForKey:@"B" withContent:^{
            return @5;
        }], @2, @"Inccorrect cache hit.");
    }];
}

- (void)testCacheLargeHitPerformance
{
    NSUInteger size = 1024 * 1024;
    NSMutableData* data = [NSMutableData dataWithCapacity:size];
    for(NSUInteger i = 0; i < size/sizeof(u_int32_t); i++) {
        u_int32_t randomBits = arc4random();
        [data appendBytes:(void*)&randomBits length:sizeof(u_int32_t)];
    }
    NSData *aData = [data copy];
    
    [_cache setObject:aData forKey:@"A"];
    [_cache setObject:@2 forKey:@"B"];
    [_cache setObject:@3 forKey:@"C"];
    for (NSUInteger i = 0; i < 100; i++) {
        [data appendBytes:(void*)&i length:sizeof(i)];
        [_cache setObject:data forKey:[NSString stringWithFormat:@"%lu", (unsigned long)i]];
    }
    
    [self measureBlock:^{
        [_cache clearInternalCache];
        XCTAssertEqualObjects([_cache objectForKey:@"A"], aData, @"Inccorrect cache hit.");
    }];
}

@end
