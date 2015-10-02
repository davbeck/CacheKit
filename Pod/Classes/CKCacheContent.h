//
//  CKCacheContent.h
//  Pods
//
//  Created by David Beck on 10/13/14.
//
//

#import <Foundation/Foundation.h>

@interface CKCacheContent<__covariant ObjectType:id<NSCoding, NSObject>> : NSObject <NSCoding, NSCopying>

+ (nonnull instancetype)cacheContentWithObject:(nonnull ObjectType)object expires:(nullable NSDate *)expires;

@property (nonatomic, readonly, strong, nonnull) ObjectType object;
@property (nonatomic, readonly, copy, nullable) NSDate *expires;

@end
