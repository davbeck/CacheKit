//
//  CKCacheContent.h
//  Pods
//
//  Created by David Beck on 10/13/14.
//
//

#import <Foundation/Foundation.h>

@interface CKCacheContent : NSObject <NSCoding, NSCopying>

+ (instancetype)cacheContentWithObject:(id)object expires:(NSDate *)expires;

@property (nonatomic, readonly, copy) id object;
@property (nonatomic, readonly, copy) NSDate *expires;

@end
