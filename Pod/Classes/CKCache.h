//
//  CKCache.h
//  Pods
//
//  Created by David Beck on 10/13/14.
//
//

#import <Foundation/Foundation.h>


typedef _Nonnull id(^CKCacheContentBlock)();


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

@interface CKCache<__covariant ObjectType:id<NSCoding, NSObject>> : NSObject

/** Init cache with a given name.
 
 @param name The name for the new cache. If a cache is persistent, passing the same name 2 caches
 will cause them to share data, however there may be issues with concurrency. You should use the
 same name for the cache each time the app is launched.
 @return A new cache with the given name.
 */
- (nonnull instancetype)initWithName:(nonnull NSString *)name NS_DESIGNATED_INITIALIZER;

/** The name for the cache.
 
 If a cache is persistent, passing the same name 2 caches
 will cause them to share data, however there may be issues with concurrency. You should use the
 same name for the cache each time the app is launched.
 
 The name of the cache should not change.
 */
@property (readonly, copy, nonnull) NSString *name;


/** Whether an object exists for the given key.
 
 If the object has expired, this method returns `NO`.
 
 @param key The key to look up the object with.
 @return `YES` if any object exists with that key, `NO` otherwise.
 */
- (BOOL)objectExistsForKey:(nonnull NSString *)key;

/** Get the object for the given key.
 
 If the object has expired, this method returns `nil`.
 
 @param key The key to look up the object with.
 @return The object for the given key, or nil.
 */
- (nullable ObjectType)objectForKey:(nonnull NSString *)key;

/** Get the object for the given key.
 
 If the object has expired, or does not exist in the cache, the content block will be called and
 it's results added to the cache and returned.
 
 @param key The key to look up the object with.
 @param content The block that provides an object when the cache misses. Can be nil.
 @return The object for the given key, or nil.
 */
- (nullable ObjectType)objectForKey:(nonnull NSString *)key withContent:(nullable CKCacheContentBlock)content;

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
- (nullable ObjectType)objectForKey:(nonnull NSString *)key expiresIn:(NSTimeInterval)expiresIn withContent:(nullable CKCacheContentBlock)content;

/** Get the object for the given key.
 
 If the object has expired, or does not exist in the cache, the content block will be called and
 it's results added to the cache and returned. In that case expires will be used for the
 returned value when it is stored in the cache.
 
 @param key The key to look up the object with.
 @param expires When the content object should expire.
 @param content The block that provides an object when the cache misses. Can be nil.
 @return The object for the given key, or nil.
 */
- (nullable ObjectType)objectForKey:(nonnull NSString *)key expires:(nullable NSDate *)expires withContent:(nullable CKCacheContentBlock)content;

/** Get the object for the given key if it is cached in memory.
 
 Most caches have an in memory cache to suplement their on disk cache. This method will return
 the object for the given key only if it can be retrieved quickly from that in memory cache.
 You can call this and if it returns nil, load the object from disk in a background queue.
 
 Subclasses should return nil if they do not have an in memory cache (the default behavior).
 
 @param key The key to look up the object with.
 @return The object for the given key, or nil.
 */
- (nullable ObjectType)objectInMemoryForKey:(nonnull NSString *)key;


/** Add or replace the object for the given key
 
 If the object already exists in the cache, it is replaced.
 
 @param obj The object to store in the cache.
 @param key The key to store the object as.
 */
- (void)setObject:(nonnull ObjectType)obj forKey:(nonnull NSString *)key;

/** Add or replace the object for the given key
 
 If the object already exists in the cache, it is replaced. The object will be returned for the
 given key for expiresIn seconds.
 
 @param obj The object to store in the cache.
 @param key The key to store the object as.
 @param expiresIn The amount of seconds before the content object will expire. If this number is
 <= 0 the object will typically be stored but ignored on subsequent requests.
 */
- (void)setObject:(nonnull ObjectType)obj forKey:(nonnull NSString *)key expiresIn:(NSTimeInterval)expiresIn;

/** Add or replace the object for the given key
 
 If the object already exists in the cache, it is replaced. The object will be returned for the
 given key until after expires.
 
 @param obj The object to store in the cache.
 @param key The key to store the object as.
 @param expires When the content object should expire.
 */
- (void)setObject:(nonnull ObjectType)obj forKey:(nonnull NSString *)key expires:(nullable NSDate *)expires;


/** Remove the object stored in key.
 
 If an object is stored in the cache for the given key, it will be removed.
 
 @param key The key to store the object as.
 */
- (void)removeObjectForKey:(nonnull NSString *)key;

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

/** Checks the current filesize of the cache and removes enough objects to reduce the size below the maxFilesize.
 
 Subclasses can call this at their discression. Subclasses decide how they will impliment this as well. By default, if the currentFilesize is larger than the maxFilesize, all objects are removed.
 */
- (void)trimFilesize;

/** Maximum filesize to use for cached content
 
 When a max file size is set, if the current file size is larger, all the objects in the cache will be removed. This is not checked until the next time the max is set, which is usually on application start.
 */
@property (nonatomic) NSUInteger maxFilesize;

/** The current size on disk of the cache
 
 
 */
@property (nonatomic, readonly) NSUInteger currentFilesize;

@end
