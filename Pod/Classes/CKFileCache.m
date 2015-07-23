//
//  CKFileCache.m
//  Pods
//
//  Created by David Beck on 10/13/14.
//
//

#import "CKFileCache.h"

#import "CKCacheContent.h"


@interface CKFileCache ()
{
    // we still use an internal NSCache to cache what we get from the file system
    // the file system is the truth though
    NSCache *_internalCache;
    NSURL *_directory;
    dispatch_queue_t _queue;
}

@end

@implementation CKFileCache

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
    NSAssert(name.length > 0, @"You must provide a name for %@. Use +sharedCache instead.", NSStringFromClass([self class]));
    
    self = [super initWithName:name];
    if (self) {
        NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        cacheDirectory = [cacheDirectory stringByAppendingPathComponent:[name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        _directory = [NSURL fileURLWithPath:cacheDirectory];
        
        NSLog(@"Creating CKFileCache in directory: %@", _directory.path);
        
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtURL:_directory withIntermediateDirectories:YES attributes:nil error:&error];
        if (error != nil) {
            NSLog(@"Error creating cache directory (%@): %@", _directory, error);
            return nil;
        }
        
        _internalCache = [NSCache new];
        _internalCache.name = name;
        
        _queue = dispatch_queue_create(name.UTF8String, DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must provide a name for %@. Use +sharedCache instead.", NSStringFromClass([self class])]
                                 userInfo:nil];
}

- (NSURL *)_URLForKey:(NSString *)key
{
    return [_directory URLByAppendingPathComponent:key isDirectory:NO];
}


- (BOOL)objectExistsForKey:(NSString *)key
{
    CKCacheContent *cacheContent = [_internalCache objectForKey:key];
    if (cacheContent != nil) {
        return cacheContent.expires.timeIntervalSinceNow >= 0;
    }
    
    return [self objectForKey:key] != nil;
}

- (id)objectForKey:(NSString *)key expires:(NSDate *)expires withContent:(id(^)())content
{
    __block CKCacheContent *cacheContent = [_internalCache objectForKey:key];
    
    if (cacheContent == nil) {
        dispatch_sync(_queue, ^{
            cacheContent = [NSKeyedUnarchiver unarchiveObjectWithFile:[self _URLForKey:key].path];
        });
    }
    
    if (cacheContent.expires != nil && cacheContent.expires.timeIntervalSinceNow < 0.0) {
        [self removeObjectForKey:key];
        cacheContent = nil;
    }
    
    if (cacheContent == nil && content != nil) {
        id object = content();
        if (object != nil) {
            cacheContent = [CKCacheContent cacheContentWithObject:object expires:expires];
            [_internalCache setObject:cacheContent forKey:key];
            
            dispatch_async(_queue, ^{
                [NSKeyedArchiver archiveRootObject:cacheContent toFile:[self _URLForKey:key].path];
            });
        }
    }
    
    return cacheContent.object;
}


- (void)setObject:(id)object forKey:(NSString *)key expires:(NSDate *)expires
{
    CKCacheContent *cacheContent = [CKCacheContent cacheContentWithObject:object expires:expires];
    [_internalCache setObject:cacheContent forKey:key];
    
    dispatch_async(_queue, ^{
        [NSKeyedArchiver archiveRootObject:cacheContent toFile:[self _URLForKey:key].path];
    });
}


- (void)removeObjectForKey:(NSString *)key
{
    [_internalCache removeObjectForKey:key];
    dispatch_async(_queue, ^{
        [[NSFileManager defaultManager] removeItemAtURL:[self _URLForKey:key] error:NULL];
    });
}

- (void)removeAllObjects
{
    [_internalCache removeAllObjects];
    dispatch_async(_queue, ^{
        [[NSFileManager defaultManager] removeItemAtURL:_directory error:NULL];
        [[NSFileManager defaultManager] createDirectoryAtURL:_directory withIntermediateDirectories:YES attributes:nil error:NULL];
    });
}

- (void)clearInternalCache
{
    [_internalCache removeAllObjects];
}

- (void)waitUntilFilesAreWritten
{
    dispatch_sync(_queue, ^{});
}

- (NSUInteger)currentFilesize {
	NSUInteger filesize = 0;
	
	NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:_directory.path];
	NSString *file = nil;
	while ((file = [enumerator nextObject])) {
		NSString *path = [_directory.path stringByAppendingPathComponent:file];
		NSError *error = nil;
		NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
		if (attributes == nil) {
			NSLog(@"Error reading file attributes: %@", error);
		}
		
		filesize += attributes.fileSize;
	}
	
	return filesize;
}

@end
