//
//  CKMemoryCache.m
//  Pods
//
//  Created by David Beck on 10/13/14.
//
//

#import "CKMemoryCache.h"

#import "CKCacheContent.h"


@interface CKMemoryCache ()
{
    NSCache *_internalCache;
}

@end

@implementation CKMemoryCache

- (instancetype)initWithName:(NSString *)name
{
    self = [super initWithName:name];
    if (self) {
        _internalCache = [NSCache new];
    }
    
    return self;
}


- (BOOL)objectExistsForKey:(id)key
{
    CKCacheContent *cacheContent = [_internalCache objectForKey:key];
    
    return cacheContent != nil && cacheContent.expires.timeIntervalSinceNow >= 0;
}

- (id)objectForKey:(id)key expires:(NSDate *)expires withContent:(id(^)())content
{
    CKCacheContent *cacheContent = [_internalCache objectForKey:key];
    
    if (cacheContent.expires.timeIntervalSinceNow < 0.0) {
        [_internalCache removeObjectForKey:key];
        cacheContent = nil;
    }
    
    if (cacheContent == nil && content != nil) {
        id object = content();
        if (object != nil) {
            cacheContent = [CKCacheContent cacheContentWithObject:object expires:expires];
            [_internalCache setObject:cacheContent forKey:key];
        }
    }
    
    return cacheContent.object;
}


- (void)setObject:(id)object forKey:(id)key expires:(NSDate *)expires
{
    CKCacheContent *cacheContent = [CKCacheContent cacheContentWithObject:object expires:expires];
    [_internalCache setObject:cacheContent forKey:key];
}


- (void)removeObjectForKey:(id)key
{
    [_internalCache removeObjectForKey:key];
}

- (void)removeAllObjects
{
    [_internalCache removeAllObjects];
}

@end
