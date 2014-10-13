//
//  CKCache.h
//  Pods
//
//  Created by David Beck on 10/13/14.
//
//

#import <Foundation/Foundation.h>

@interface CKCache : NSObject

- (instancetype)initWithName:(NSString *)name NS_DESIGNATED_INITIALIZER;

@property (readonly, copy) NSString *name;

- (BOOL)objectExistsForKey:(NSString *)key;
- (id)objectForKey:(NSString *)key;
- (id)objectForKey:(NSString *)key withContent:(id(^)())content;
- (id)objectForKey:(NSString *)key expiresIn:(NSTimeInterval)expiresIn withContent:(id(^)())content;
- (id)objectForKey:(NSString *)key expires:(NSDate *)expires withContent:(id(^)())content;

- (void)setObject:(id)obj forKey:(NSString *)key;
- (void)setObject:(id)obj forKey:(NSString *)key expiresIn:(NSTimeInterval)expiresIn;
- (void)setObject:(id)obj forKey:(NSString *)key expires:(NSDate *)expires;

- (void)removeObjectForKey:(NSString *)key;
- (void)removeAllObjects;

/** Removes any objects in the cache that have expired
 
 This does not garuntee that expired objects will be removed. Some caches, like `CKMemoryCache` 
 are not able to enumerate all of their cached objects.
 
 Subclasses should override this if they can remove only expired objects.
 */
- (void)removeExpiredObjects;

@end
