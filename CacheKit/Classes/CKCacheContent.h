//
//  CKCacheContent.h
//  Pods
//
//  Created by David Beck on 10/13/14.
//
//

#import <Foundation/Foundation.h>

@interface CKCacheContent<__covariant id:id<NSCoding, NSObject>> : NSObject <NSCoding, NSCopying>

+ (nonnull instancetype)cacheContentWithObject:(nonnull id)object expires:(nullable NSDate *)expires;

@property (nonatomic, readonly, strong, nonnull) id object;
@property (nonatomic, readonly, copy, nullable) NSDate *expires;

@property (nonatomic, readonly) BOOL isExpired;

@end
