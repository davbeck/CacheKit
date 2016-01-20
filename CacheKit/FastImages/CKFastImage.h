//
//  CKFastImage.h
//  FastImageCacheDemo
//
//  Created by David Beck on 7/24/15.
//  Copyright (c) 2015 Path. All rights reserved.
//

#import <Foundation/Foundation.h>


#if TARGET_OS_IOS || TARGET_OS_TV

#import <UIKit/UIKit.h>


typedef NS_ENUM(uint8_t, CKFastImageStyle) {
	CKFastImageStyle32BitBGRA = 0,
	CKFastImageStyle32BitBGR,
	CKFastImageStyle16BitBGR,
	CKFastImageStyle8BitGrayscale,
};


/** A wrapper for encoding and decoding images very fast
 
 You can use this class to encode `UIImage`s with the exact memory layout that it uses at runtime. Normally, when you save an image, either as a JPG, PNG or using NSCoding, it compresses the data into a format that is smaller on disk. When you create an image from that data, it doesn't inflate the data to it's natural layout until it is used. This causes issues where an image is created in a background thread, but the work of inflating it still happens on the main thread when the image is drawn. For caching, it wastes time decoding an image every time, and often the filesize improvements are negligable for small thumbnails.
 
 By drawing an image at the exact thumbnail size you display on screen and caching it, you can significantly speed up your app's scrolling and loading experience.
 */

@interface CKFastImage : NSObject <NSCoding>

/** Create a `CKFastImage` from an existing image.
 
 This method calls `initWithSize:scale:style:style:drawing:` and draws the image into the new context. For this reason, the `image` property will be a different object than the one passed into this method. Only the size and scale will be preserved. Any animations, resize settings or other properties on the image will be lost. The image that is generated will be inflated, and ready to draw, so you may see a performance improvement by using the generated image instead of the original passed to this method.
 
 If you have any adjustments to make to the image such as rounded corners of drop shadows, you should consider calling `initWithSize:scale:style:style:drawing:` so that those operations can be cached.
 
 @param image The image to encode.
 @return A new `CKFastImage` instance.
 */
- (instancetype)initWithImage:(UIImage *)image;


/** Create a `CKFastImage` from drawing code.
 
 You can get the generated image from this drawing using the `image` property. When an image is created with this method, the image property is set directly from the drawing and does not need to be decoded again.
 
 @param size The size of the image to create. This will be the size, in points of the context passed to `drawing`.
 @param scale The scale of the image to create. For instance, you could pass `-[UIScreen scale]` to match the devices scale. The context will be scaled using this value so that the drawing block will draw at this level of detail.
 @param style The color style of the image to draw. Use something besides `CKFastImageStyle32BitBGRA` to create smaller files if you don't need the highest color profile or are using images without alpha.
 @param drawing The drawing block that provides the content of the image. This is helpful to apply any kind of adjustments to the image like rounded corners or drop shadows, or to provide a completely custom drawing.
 @return A new `CKFastImage` instance.
 */
- (instancetype)initWithSize:(CGSize)size scale:(CGFloat)scale style:(CKFastImageStyle)style drawing:(void(^)(CGContextRef context))drawing;

/** Create a `CKFastImage` directly from bytes.
 
 Use this if you want to serialize an image in some way other than NSCoding.
 
 @warning `CKFastImage` does not copy the bytes you pass into this initializere. The bytes you pass in here will be freed when the object is deallocated. If you have a reference to a buffer that you do not control, make sure to memcpy them to a new buffer and pass that to this method.
 
 @param bytes The buffer containing image data.
 @return A new `CKFastImage` instance.
 */
- (instancetype)initWithBytesNoCopy:(void *)data length:(NSUInteger)length size:(CGSize)size scale:(CGFloat)scale style:(CKFastImageStyle)style __attribute((deprecated(("Use initWithData:size:scale:style: instead."))));

/** Create a `CKFastImage` directly from data.
 
 Use this if you want to serialize an image in some way other than NSCoding.
 
 @param bytes The buffer containing image data.
 @return A new `CKFastImage` instance.
 */
- (instancetype)initWithData:(NSData *)data size:(CGSize)size scale:(CGFloat)scale style:(CKFastImageStyle)style NS_DESIGNATED_INITIALIZER;


/** The bytes representing the image.
 
 You can use this to save the image in some form besides NSCoding.
 */
@property (nonatomic, readonly) NSData *data;


/** The image backed by `bytes`.
 
 If the `CKFastImage` was created from bytes directly, or decoded with NSCoding, this will be created the first time it is called.
 */
@property (nonatomic, readonly) UIImage *image;


/** The scale of the image.
 
 For instance, 2.0 for retina screens.
 */
@property (nonatomic, readonly) CGFloat scale;

/** The size, in points of the image.
 */
@property (nonatomic, readonly) CGSize size;

/** The color style of the image.
 
 If you have images that don't use the full color profile, for instance images without alpha, grayscale images, or really small images that don't use the full range of colors, you can use a different color style than `CKFastImageStyle32BitBGRA` to save space on disk as well as speed up drawing.
 */
@property (nonatomic, readonly) CKFastImageStyle style;

@end

#endif
