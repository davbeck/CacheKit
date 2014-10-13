//
//  CKSQLiteCache.h
//  Pods
//
//  Created by David Beck on 10/13/14.
//
//

#import "CKCache.h"


/** CKCache that stores it's objects in an SQLite database.
 
 Objects are persisted to the cache database using this cache. In addition, there is an in
 memory NSCache for quick access.
 
 All database access is performed on a serial queue and is thread safe.
 
 Notice: Objects must conform to the `NSCoding` protocol. Internally, objects are encoded
 using `NSCoding`. Properties are not stored as columns.
 */
@interface CKSQLiteCache : CKCache

/** A shared database cache.
 
 You can use this cache for general content you want stored in a database. Make sure your keys are
 unique across your app by prefixing them with class names or other unique data.
 
 @return A singleton instance of a database cache.
 */
+ (instancetype)sharedCache;

/** Clear the internal in memory cache
 
 This is primarily for testing purposes.
 */
- (void)clearInternalCache;

@end
