//
//  CKCacheContent.h
//  Pods
//
//  Created by David Beck on 10/13/14.
//
//

#import <Foundation/Foundation.h>

@interface CKCacheContent : NSObject <NSCoding, NSCopying>

+ (nonnull instancetype)cacheContentWithObject:(nonnull id)object expires:(nullable NSDate *)expires;

@property (nonatomic, readonly, strong, nonnull) id<NSCoding, NSObject> object;
@property (nonatomic, readonly, copy, nullable) NSDate *expires;

@end
