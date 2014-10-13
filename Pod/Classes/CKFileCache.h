//
//  CKFileCache.h
//  Pods
//
//  Created by David Beck on 10/13/14.
//
//

#import "CKCache.h"


/** CKCache that stores it's objects on the file system
 
 Objects are persisted to the cache directory using this cache. In addition, there is an in
 memory NSCache for quick access.
 
 All file system access is performed on a serial queue. Writes are done asynchronously and
 reads are performed synchronously. This means that a large object write will return 
 immediately, but if you try to read that object before it has been written to disk, you will
 have to wait until it has finished.
 
 Notice: Objects must conform to the `NSCoding` protocol.
 */
@interface CKFileCache : CKCache

/** A shared file cache.
 
 You can use this cache for general content you want stored on disk. Make sure your keys are
 unique across your app by prefixing them with class names or other unique data.
 
 @return A singleton instance of a file cache.
 */
+ (instancetype)sharedCache;

/** Clear the internal in memory cache
 
 This is primarily for testing purposes.
 */
- (void)clearInternalCache;

/** Wait for file operations to complete
 
 This method waits until all the file operations have been completed before returning. Use this
 to ensure that all files are written to disk before continuing.
 
 Note that any file operations added after this is called may not be completed when this method
 returns.
 */
- (void)waitUntilFilesAreWritten;

@end
