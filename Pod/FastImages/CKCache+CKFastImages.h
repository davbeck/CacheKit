//
//  CKCache+CKFastImages.h
//  FastImageCacheDemo
//
//  Created by David Beck on 7/24/15.
//  Copyright (c) 2015 Path. All rights reserved.
//

#import "CKCache.h"

@interface CKCache (CKFastImages)

/** Add an image to the cache using `CKFastImage`.
 
 When you use this method, it encodes the image much faster than using `UIImage`s implimentation of NSCoding. For more info, see `CKFastImage`.
 
 @param image The image to save to the cache.
 @param key The key to store the object as.
 @param expires When the content object should expire.
 @return The inflated image, which is similar to the original but matches what you would get from `imageForKey:`.
 */
- (UIImage *)setImage:(UIImage *)image forKey:(NSString *)key expires:(NSDate *)expires;

/** Add an image to the cache using `CKFastImage`.
 
 When you use this method, it encodes the image much faster than using `UIImage`s implimentation of NSCoding. For more info, see `CKFastImage`.
 
 The scale of the main screen is used for the generated image. You can get more fine grained control of how the image is encoded using `CKFastImage` directly and using `setObject:forKey:`. You can still use `imageForKey:` to decode the image.
 
 @param size The size of the image to draw into.
 @param drawing The block to execute to draw the image.
 @param key The key to store the object as.
 @param expires When the content object should expire.
 @return The drawn image, ready to be used for drawing.
 */
- (UIImage *)setImageWithSize:(CGSize)size drawing:(void(^)(CGContextRef context))drawing forKey:(NSString *)key expires:(NSDate *)expires;

/** Decode an image that was encoded with `CKFastImage`.
 
 The image that you get back from `CKFastImage` (and by extention, this method) is already inflated and ready for drawing without delay.
 
 @param key The key to look up the object with.
 @return The image for the given key, or nil if it doesn't exist in the cache.
 */
- (UIImage *)imageForKey:(NSString *)key;

@end
