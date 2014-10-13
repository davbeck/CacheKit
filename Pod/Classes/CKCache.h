//
//  CKCache.h
//  Pods
//
//  Created by David Beck on 10/13/14.
//
//

#import <Foundation/Foundation.h>


/** The CacheKit base class.
 
 This class serves as the abstract base class for other caches. You cannot create a CKCache
 directly. Instead, you should create an instance of one of it's concrete subclasses.
 
 Subclasses:
 
 - `CKMemoryCache`: An in memory only cache that does not persist when the cache is destroyed.
 - `CKFileCache`: A cache that stores it's objects as files on disk.
 - `CKSQLiteCache`: A cache that stores it's objects in an SQLite database.
 - `CKNullCache`: A cache that never stores it's objects. Use this for testing.
 
 `CKSQLiteCache` is much faster than `CKFileCache` in almost every situation. However, as the size
 of the objects and even the number of objects grow, `CKFileCache` can become faster. Both use 
 `NSCoding` to convert their objects to raw data.
 
 ## Keys
 
 Keys are always `NSString`s. If you are using a shared or global cache, you need to make sure that
 the keys you use are unique. The easiest way to do this is to prefix them with your class name.
 
 ## Objects
 
 Objects are copied when added to a cache. Currently, for persistent caches, objects must conform
 to NSCoding to be written to disk. In the future those caches should include a transformer property
 to allow for different methods of storage.
 */

@interface CKCache : NSObject

/** Init cache with a given name.
 
 @param name The name for the new cache. If a cache is persistent, passing the same name 2 caches
 will cause them to share data, however there may be issues with concurrency. You should use the
 same name for the cache each time the app is launched.
 @return A new cache with the given name.
 */
- (instancetype)initWithName:(NSString *)name NS_DESIGNATED_INITIALIZER;

/** The name for the cache.
 
 If a cache is persistent, passing the same name 2 caches
 will cause them to share data, however there may be issues with concurrency. You should use the
 same name for the cache each time the app is launched.
 
 The name of the cache should not change.
 */
@property (readonly, copy) NSString *name;


/** Whether an object exists for the given key.
 
 If the object has expired, this method returns `NO`.
 
 @param key The key to look up the object with.
 @return `YES` if any object exists with that key, `NO` otherwise.
 */
- (BOOL)objectExistsForKey:(NSString *)key;

/** Get the object for the given key.
 
 If the object has expired, this method returns `nil`.
 
 @param key The key to look up the object with.
 @return The object for the given key, or nil.
 */
- (id)objectForKey:(NSString *)key;

/** Get the object for the given key.
 
 If the object has expired, or does not exist in the cache, the content block will be called and
 it's results added to the cache and returned.
 
 @param key The key to look up the object with.
 @param content The block that provides an object when the cache misses. Can be nil.
 @return The object for the given key, or nil.
 */
- (id)objectForKey:(NSString *)key withContent:(id(^)())content;

/** Get the object for the given key.
 
 If the object has expired, or does not exist in the cache, the content block will be called and
 it's results added to the cache and returned. In that case, `expiresIn` will be used for the
 returned value when it is stored in the cache.
 
 @param key The key to look up the object with.
 @param expiresIn The amount of seconds before the content object will expire. If this number is
 <= 0 the object will typically be stored but ignored on subsequent requests.
 @param content The block that provides an object when the cache misses. Can be nil.
 @return The object for the given key, or nil.
 */
- (id)objectForKey:(NSString *)key expiresIn:(NSTimeInterval)expiresIn withContent:(id(^)())content;

/** Get the object for the given key.
 
 If the object has expired, or does not exist in the cache, the content block will be called and
 it's results added to the cache and returned. In that case expires will be used for the
 returned value when it is stored in the cache.
 
 @param key The key to look up the object with.
 @param expires When the content object should expire.
 @param content The block that provides an object when the cache misses. Can be nil.
 @return The object for the given key, or nil.
 */
- (id)objectForKey:(NSString *)key expires:(NSDate *)expires withContent:(id(^)())content;


/** Add or replace the object for the given key
 
 If the object already exists in the cache, it is replaced.
 
 @param obj The object to store in the cache.
 @param key The key to store the object as.
 */
- (void)setObject:(id)obj forKey:(NSString *)key;

/** Add or replace the object for the given key
 
 If the object already exists in the cache, it is replaced. The object will be returned for the
 given key for expiresIn seconds.
 
 @param obj The object to store in the cache.
 @param key The key to store the object as.
 @param expiresIn The amount of seconds before the content object will expire. If this number is
 <= 0 the object will typically be stored but ignored on subsequent requests.
 */
- (void)setObject:(id)obj forKey:(NSString *)key expiresIn:(NSTimeInterval)expiresIn;

/** Add or replace the object for the given key
 
 If the object already exists in the cache, it is replaced. The object will be returned for the
 given key until after expires.
 
 @param obj The object to store in the cache.
 @param key The key to store the object as.
 @param expires When the content object should expire.
 */
- (void)setObject:(id)obj forKey:(NSString *)key expires:(NSDate *)expires;


/** Remove the object stored in key.
 
 If an object is stored in the cache for the given key, it will be removed.
 
 @param key The key to store the object as.
 */
- (void)removeObjectForKey:(NSString *)key;

/** Remove all objects in the cache.
 
 Empties any and all objects in the cache. For persistent caches, this is the only way to clear the
 cache permanently.
 */
- (void)removeAllObjects;

/** Removes any objects in the cache that have expired
 
 This does not garuntee that expired objects will be removed. Some caches, like `CKMemoryCache` 
 are not able to enumerate all of their cached objects.
 
 Subclasses should override this if they can remove only expired objects.
 */
- (void)removeExpiredObjects;

@end
