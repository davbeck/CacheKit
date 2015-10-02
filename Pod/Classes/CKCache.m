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

- (nullable id)objectForKey:(nonnull NSString *)key withContent:(nullable CKCacheContentBlock)content
{
    return [self objectForKey:key expires:nil withContent:content];
}

- (nullable id)objectForKey:(nonnull NSString *)key expiresIn:(NSTimeInterval)expiresIn withContent:(nullable CKCacheContentBlock)content
{
    return [self objectForKey:key expires:[NSDate dateWithTimeIntervalSinceNow:expiresIn] withContent:content];
}

- (nullable id)objectForKey:(nonnull NSString *)key expires:(nullable NSDate *)expires withContent:(nullable CKCacheContentBlock)content
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (nullable id)objectInMemoryForKey:(nonnull NSString *)key
{
	return nil;
}


- (void)setObject:(nonnull id)obj forKey:(nonnull NSString *)key
{
    [self setObject:obj forKey:key expires:nil];
}

- (void)setObject:(nonnull id)obj forKey:(nonnull NSString *)key expiresIn:(NSTimeInterval)expiresIn
{
    [self setObject:obj forKey:key expires:[NSDate dateWithTimeIntervalSinceNow:expiresIn]];
}

- (void)setObject:(nonnull id)obj forKey:(nonnull NSString *)key expires:(NSDate *)expires
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

- (void)trimFilesize {
	if (_maxFilesize > 0 && self.currentFilesize > _maxFilesize) {
		[self removeAllObjects];
	}
}

- (void)setMaxFilesize:(NSUInteger)maxFilesize {
	_maxFilesize = maxFilesize;
	
	[self trimFilesize];
}

- (NSUInteger)currentFilesize {
	return 0;
}

@end
