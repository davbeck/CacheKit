//
//  NSData+Random.m
//  CacheKit
//
//  Created by David Beck on 5/16/16.
//  Copyright © 2016 Think Ultimate. All rights reserved.
//

#import "NSData+Random.h"


@implementation NSData (Random)

+ (NSData *)randomDataWithSize:(NSInteger)size {
	NSMutableData* data = [NSMutableData dataWithCapacity:size];
	for(NSUInteger i = 0; i < size/sizeof(u_int32_t); i++) {
		u_int32_t randomBits = arc4random();
		[data appendBytes:(void*)&randomBits length:sizeof(u_int32_t)];
	}
	return [data copy];
}

@end
