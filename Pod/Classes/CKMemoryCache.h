//
//  CKMemoryCache.h
//  Pods
//
//  Created by David Beck on 10/13/14.
//
//

#import "CKCache.h"


/** An in memory only cache.
 
 Instances of this class only store their objects in memory, and never persist them. If you create
 another cache with the same name, it will not have the same objects.
 
 Internally, memory caches use `NSCache` to store their objects. Because of this, objects will be
 released during memory warning.
 */
@interface CKMemoryCache : CKCache

/** A shared memory cache.
 
 You can use this cache for general content you want stored in memory. Make sure your keys are
 unique across your app by prefixing them with class names or other unique data.
 
 @return A singleton instance of a memory cache.
 */
+ (instancetype)sharedCache;

@end
