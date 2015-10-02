//
//  CKNullCacheTests.m
//  CacheKit
//
//  Created by David Beck on 10/13/14.
//  Copyright (c) 2014 David Beck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import <CacheKit/CacheKit.h>


@interface CKNullCacheTests : XCTestCase
{
    CKNullCache<NSNumber *> *_cache;
}

@end

@implementation CKNullCacheTests

- (void)setUp
{
    [super setUp];
    
    _cache = [[CKNullCache alloc] initWithName:@"Tests"];
}

- (void)tearDown
{
    [_cache removeAllObjects];
    
    [super tearDown];
}

- (void)testReadWrite
{
    [_cache setObject:@1 forKey:@"A"];
    XCTAssertFalse([_cache objectExistsForKey:@"A"], @"objectExistsForKey should always be NO");
    XCTAssertEqualObjects([_cache objectForKey:@"A"], nil, @"objectForKey should always be nil");
    
    [_cache removeObjectForKey:@"A"];
    XCTAssertFalse([_cache objectExistsForKey:@"A"], @"removeObjectForKey did not remove object");
}

- (void)testContentBlock
{
    XCTAssertFalse([_cache objectExistsForKey:@"A"], @"Cache should be empty at the begining of the test.");
    
    id object = [_cache objectForKey:@"A" withContent:^{
        return @1;
    }];
    XCTAssertEqualObjects(object, @1, @"objectForKey:withContent: did not return correct object.");
    
    XCTAssertEqualObjects([_cache objectForKey:@"A"], nil, @"objectForKey should always be nil");
}

@end
