//
//  CKSQLiteCache.h
//  Pods
//
//  Created by David Beck on 10/13/14.
//
//

#import "CKCache.h"

@interface CKSQLiteCache : CKCache

+ (instancetype)sharedCache;

/** Clear the internal in memory cache
 
 This is primarily for testing purposes.
 */
- (void)clearInternalCache;

@end
