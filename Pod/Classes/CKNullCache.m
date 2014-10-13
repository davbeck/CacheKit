//
//  CKNullCache.m
//  Pods
//
//  Created by David Beck on 10/13/14.
//
//

#import "CKNullCache.h"

@implementation CKNullCache

+ (instancetype)sharedCache
{
    static id sharedInstance;
    static dispatch_once_t done;
    dispatch_once(&done, ^{
        sharedInstance = [[self alloc] initWithName:@"SharedCache"];
    });
    
    return sharedInstance;
}

- (instancetype)initWithName:(NSString *)name
{
    self = [super initWithName:name];
    if (self) {
    }
    
    return self;
}


- (BOOL)objectExistsForKey:(NSString *)key
{
    return NO;
}

- (id)objectForKey:(NSString *)key expires:(NSDate *)expires withContent:(id(^)())content
{
    if (content != nil) {
        return content();
    }
    
    return nil;
}


- (void)setObject:(id)object forKey:(NSString *)key expires:(NSDate *)expires
{
}


- (void)removeObjectForKey:(NSString *)key
{
}

- (void)removeAllObjects
{
}

@end
