//
//  CacheKit.h
//  Pods
//
//  Created by David Beck on 10/13/14.
//

#import <Foundation/Foundation.h>

//! Project version number for CacheKit.
FOUNDATION_EXPORT double CacheKitVersionNumber;

//! Project version string for CacheKit.
FOUNDATION_EXPORT const unsigned char CacheKitVersionString[];


#import "CKCache.h"
#import "CKMemoryCache.h"
#import "CKFileCache.h"
#import "CKSQLiteCache.h"
#import "CKNullCache.h"

#if TARGET_OS_IOS || TARGET_OS_TV

#import "CKCache+CKFastImages.h"
#import "CKFastImage.h"

#endif
