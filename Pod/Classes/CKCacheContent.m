//
//  CKCacheContent.m
//  Pods
//
//  Created by David Beck on 10/13/14.
//
//

#import "CKCacheContent.h"


@interface CKCacheContent ()

@property (nonatomic, readwrite, copy) id object;
@property (nonatomic, readwrite, copy) NSDate *expires;

@end

@implementation CKCacheContent

+ (instancetype)cacheContentWithObject:(id)object expires:(NSDate *)expires
{
    CKCacheContent *content = [[self alloc] init];
    content.object = object;
    content.expires = expires;
    
    return content;
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        self.object = [decoder decodeObjectForKey:NSStringFromSelector(@selector(object))];
        self.expires = [decoder decodeObjectForKey:NSStringFromSelector(@selector(expires))];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.object forKey:NSStringFromSelector(@selector(object))];
    [encoder encodeObject:self.expires forKey:NSStringFromSelector(@selector(expires))];
}

- (id)copyWithZone:(NSZone *)zone
{
    CKCacheContent *cacheContent = [[[self class] alloc] init];
    cacheContent.object = self.object;
    cacheContent.expires = self.expires;
    
    return cacheContent;
}

- (BOOL)isEqual:(CKCacheContent *)object
{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[CKCacheContent class]]) {
        return NO;
    }
    
    return [self.object isEqual:object.object] && [self.expires isEqualToDate:object.expires];
}

- (NSUInteger)hash
{
    return [self.object hash] ^ self.expires.hash;
}

@end
