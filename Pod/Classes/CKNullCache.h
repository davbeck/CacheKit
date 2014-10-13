//
//  CKNullCache.h
//  Pods
//
//  Created by David Beck on 10/13/14.
//
//

#import "CKCache.h"

/** A cache that doesn't store anything anywhere
 
 Use this for testing. It will always return nil unless given a content block, in which case it
 will return the result of that block.
 
 This is useful for testing your app without caching, but using the same interface as your
 production cache.
 */
@interface CKNullCache : CKCache

/** A shared null cache.
 
 This is the safest shared cache because it doesn't store anything anyway. There is no reason
 to create multiple null caches.
 
 @return A shared useless cache.
 */
+ (instancetype)sharedCache;

@end
