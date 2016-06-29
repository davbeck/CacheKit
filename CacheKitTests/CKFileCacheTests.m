//
//  CKFileCacheTests.m
//  CacheKit
//
//  Created by David Beck on 10/13/14.
//  Copyright (c) 2014 David Beck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import <CacheKit/CacheKit.h>

#import "NSData+Random.h"


@interface CKFileCacheTests : XCTestCase
{
    CKFileCache *_cache;
}

@end

@implementation CKFileCacheTests

- (void)setUp
{
    [super setUp];
    
    _cache = [[CKFileCache alloc] initWithName:@"Tests"];
}

- (void)tearDown
{
    [_cache removeAllObjects];
    [_cache waitUntilFilesAreWritten];
    
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

- (void)testPersistence
{
    NSString *name = _cache.name;
    
    [_cache setObject:@1 forKey:@"A"];
    [_cache setObject:@2 forKey:@"B"];
    [_cache setObject:@3 forKey:@"C"];
    [_cache waitUntilFilesAreWritten];
    
    _cache = [[CKFileCache alloc] initWithName:name];
    
    XCTAssertEqualObjects([_cache objectForKey:@"B"], @2, @"Cache not persisted.");
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
    NSData *data = [NSData randomDataWithSize:1024 * 1024];
    
    [_cache setObject:data forKey:@"A"];
    [_cache setObject:@2 forKey:@"B"];
    [_cache setObject:@3 forKey:@"C"];
    for (NSUInteger i = 0; i < 100; i++) {
        [_cache setObject:[NSData randomDataWithSize:1024 * 1024] forKey:[NSString stringWithFormat:@"%lu", (unsigned long)i]];
    }
    
    [self measureBlock:^{
        [_cache clearInternalCache];
        XCTAssertEqualObjects([_cache objectForKey:@"A"], data, @"Inccorrect cache hit.");
    }];
}

- (void)testCacheSetPerformance
{
	[_cache setObject:@1 forKey:@"A"];
	[_cache setObject:@2 forKey:@"B"];
	[_cache setObject:@3 forKey:@"C"];
	for (NSUInteger i = 0; i < 1000; i++) {
		[_cache setObject:@(i) forKey:[NSString stringWithFormat:@"%lu", (unsigned long)i]];
	}
	
	[self measureBlock:^{
		[_cache setObject:@5 forKey:@"E"];
		[_cache waitUntilFilesAreWritten];
	}];
	
	XCTAssertEqualObjects([_cache objectForKey:@"E"], @5, @"Inccorrect cache hit.");
}

- (void)testMaxFilesize
{
	NSData *data = [NSData randomDataWithSize:1024];
	__block NSInteger iteration = 0;
	
	[self measureBlock:^{
		iteration++;
		CKFileCache *cache = [[CKFileCache alloc] initWithName:[NSString stringWithFormat:@"Tests-%ld", (long)iteration]];
		cache.maxFilesize = 100 * 1024;
	
		for (NSInteger i = 0; i < 200; i++) {
			[cache setObject:data forKey:[NSNumber numberWithInteger:i].stringValue];
		}
		[cache trimFilesize];
		[cache waitUntilFilesAreWritten];
		
		XCTAssertLessThanOrEqual(cache.currentFilesize, cache.maxFilesize);
	}];
}

@end
