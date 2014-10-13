//
//  CKSQLiteCache.m
//  Pods
//
//  Created by David Beck on 10/13/14.
//
//

#import "CKSQLiteCache.h"

#import <FMDB/FMDB.h>

#import "CKCacheContent.h"


@interface CKSQLiteCache ()
{
    // we still use an internal NSCache to cache what we get from the file system
    // the file system is the truth though
    NSCache *_internalCache;
    FMDatabaseQueue *_queue;
}

@end

@implementation CKSQLiteCache

+ (instancetype)sharedCache
{
    static id sharedInstance;
    static dispatch_once_t done;
    dispatch_once(&done, ^{
        sharedInstance = [[self alloc] initWithName:@"SharedCache"];
    });
    
    return sharedInstance;
}

- (void)dealloc
{
    [_queue close];
}

- (instancetype)initWithName:(NSString *)name
{
    NSAssert(name.length > 0, @"You must provide a name for %@. Use +sharedCache instead.", NSStringFromClass([self class]));
    
    self = [super initWithName:name];
    if (self) {
        NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if (error != nil) {
            NSLog(@"Error creating cache directory (%@): %@", cacheDirectory, error);
            return nil;
        }
        
        cacheDirectory = [cacheDirectory stringByAppendingPathComponent:[name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        cacheDirectory = [cacheDirectory stringByAppendingPathExtension:@"sqlite"];
        NSLog(@"Creating CKSQLiteCache at: %@", cacheDirectory);
        
        _queue = [FMDatabaseQueue databaseQueueWithPath:cacheDirectory];
        [_queue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:@"CREATE TABLE IF NOT EXISTS objects (key TEXT PRIMARY KEY, object BLOB, expires INTEGER);"];
        }];
        
        _internalCache = [NSCache new];
        _internalCache.name = name;
    }
    
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must provide a name for %@. Use +sharedCache instead.", NSStringFromClass([self class])]
                                 userInfo:nil];
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
        [_queue inDatabase:^(FMDatabase *db) {
            //expires == null?
            FMResultSet *s = [db executeQuery:@"SELECT object, expires FROM objects WHERE key = ? AND (expires IS NULL OR expires > ?);", key, @([NSDate new].timeIntervalSince1970)];
            if ([s next]) {
                id object = [NSKeyedUnarchiver unarchiveObjectWithData:[s dataForColumn:@"object"]];
                NSDate *expires = nil;
                if (![s columnIsNull:@"expires"]) {
                    expires = [NSDate dateWithTimeIntervalSince1970:[s doubleForColumn:@"expires"]];
                }
                cacheContent = [CKCacheContent cacheContentWithObject:object expires:expires];
            }
        }];
        
        if (cacheContent != nil) {
            [_internalCache setObject:cacheContent forKey:key];
        }
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
            
            NSData *objectData = [NSKeyedArchiver archivedDataWithRootObject:object];
            [_queue inDatabase:^(FMDatabase *db) {
                [db executeUpdate:@"INSERT OR REPLACE INTO objects (key, object, expires) VALUES (?, ?, ?)", key, objectData, expires];
            }];
        }
    }
    
    return cacheContent.object;
}


- (void)setObject:(id)object forKey:(NSString *)key expires:(NSDate *)expires
{
    CKCacheContent *cacheContent = [CKCacheContent cacheContentWithObject:object expires:expires];
    [_internalCache setObject:cacheContent forKey:key];
    
    NSData *objectData = [NSKeyedArchiver archivedDataWithRootObject:object];
    [_queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"INSERT OR REPLACE INTO objects (key, object, expires) VALUES (?, ?, ?)", key, objectData, expires];
    }];
}


- (void)removeObjectForKey:(NSString *)key
{
    [_internalCache removeObjectForKey:key];
    [_queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"DELETE FROM objects WHERE key = ?", key];
    }];
}

- (void)removeAllObjects
{
    [_internalCache removeAllObjects];
    [_queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"DELETE FROM objects"];
    }];
}

- (void)removeExpiredObjects
{
    [_queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"DELETE FROM objects WHERE expires IS NOT NULL AND expires < ?", @([[NSDate date] timeIntervalSince1970])];
    }];
}

- (void)clearInternalCache
{
    [_internalCache removeAllObjects];
}

@end
