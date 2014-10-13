//
//  CKCache.m
//  Pods
//
//  Created by David Beck on 10/13/14.
//
//

#import "CKCache.h"

@implementation CKCache

- (instancetype)initWithName:(NSString *)name
{
    NSAssert([self class] != [CKCache class], @"You cannot init this class directly. Instead, use a subclass e.g. CKMemoryCache");
    
    self = [super init];
    if (self != nil) {
        _name = [name copy];
    }
    
    return self;
}

- (instancetype)init
{
    return [self initWithName:NSStringFromClass(self.class)];
}


- (BOOL)objectExistsForKey:(NSString *)key
{
    return [self objectForKey:key] != nil;
}

- (id)objectForKey:(NSString *)key
{
    return [self objectForKey:key expires:nil withContent:nil];
}

- (id)objectForKey:(NSString *)key withContent:(id(^)())content
{
    return [self objectForKey:key expires:nil withContent:content];
}

- (id)objectForKey:(NSString *)key expiresIn:(NSTimeInterval)expiresIn withContent:(id(^)())content
{
    return [self objectForKey:key expires:[NSDate dateWithTimeIntervalSinceNow:expiresIn] withContent:content];
}

- (id)objectForKey:(NSString *)key expires:(NSDate *)expires withContent:(id(^)())content
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}


- (void)setObject:(id)obj forKey:(NSString *)key
{
    [self setObject:obj forKey:key expires:nil];
}

- (void)setObject:(id)obj forKey:(NSString *)key expiresIn:(NSTimeInterval)expiresIn
{
    [self setObject:obj forKey:key expires:[NSDate dateWithTimeIntervalSinceNow:expiresIn]];
}

- (void)setObject:(id)obj forKey:(NSString *)key expires:(NSDate *)expires
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}


- (void)removeObjectForKey:(NSString *)key
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)removeAllObjects
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)removeExpiredObjects
{
}

@end
