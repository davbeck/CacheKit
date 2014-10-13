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

@property (copy) NSString *name;

- (BOOL)objectExistsForKey:(id)key;
- (id)objectForKey:(id)key;
- (id)objectForKey:(id)key withContent:(id(^)())content;
- (id)objectForKey:(id)key expiresIn:(NSTimeInterval)expiresIn withContent:(id(^)())content;
- (id)objectForKey:(id)key expires:(NSDate *)expires withContent:(id(^)())content;

- (void)setObject:(id)obj forKey:(id)key;
- (void)setObject:(id)obj forKey:(id)key expiresIn:(NSTimeInterval)expiresIn;
- (void)setObject:(id)obj forKey:(id)key expires:(NSDate *)expires;

- (void)removeObjectForKey:(id)key;
- (void)removeAllObjects;

/** Removes any objects in the cache that have expired
 
 This does not garuntee that expired objects will be removed. Some caches, like `CKMemoryCache` 
 are not able to enumerate all of their cached objects.
 
 Subclasses should override this if they can remove only expired objects.
 */
- (void)removeExpiredObjects;

@end
