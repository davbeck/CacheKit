//
//  CKMemoryCacheTests.m
//  CacheKit
//
//  Created by David Beck on 10/13/14.
//  Copyright (c) 2014 David Beck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import <CacheKit/CacheKit.h>


@interface CKMemoryCacheTests : XCTestCase
{
    CKMemoryCache<NSNumber *> *_cache;
}

@end

@implementation CKMemoryCacheTests

- (void)setUp
{
    [super setUp];
    
    _cache = [[CKMemoryCache alloc] initWithName:@"Tests"];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
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
    XCTAssertFalse([_cache objectExistsForKey:@"A"], @"removeObjectForKey did not remove object");
    
    id object = [_cache objectForKey:@"A" withContent:^{
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
    
    id object = [_cache objectForKey:@"A" withContent:^{
        return @2;
    }];
    XCTAssertEqualObjects(object, @2, @"objectForKey:withContent: did not return correct object.");
    
    XCTAssertEqualObjects([_cache objectForKey:@"A"], @2, @"objectForKey for key just added");
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
        XCTAssertEqualObjects([_cache objectForKey:@"B" withContent:^{
            return @5;
        }], @2, @"Inccorrect cache hit.");
    }];
}

@end
