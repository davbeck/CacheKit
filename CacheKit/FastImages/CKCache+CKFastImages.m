//
//  CKCache+CKFastImages.m
//  FastImageCacheDemo
//
//  Created by David Beck on 7/24/15.
//  Copyright (c) 2015 Path. All rights reserved.
//

#import "CKCache+CKFastImages.h"

#import "CKFastImage.h"


#if TARGET_OS_IOS || TARGET_OS_TV


inline size_t FICByteAlign(size_t width, size_t alignment) {
	return ((width + (alignment - 1)) / alignment) * alignment;
}

inline size_t FICByteAlignForCoreAnimation(size_t bytesPerRow) {
	return FICByteAlign(bytesPerRow, 64);
}


@implementation CKCache (CKFastImages)

- (UIImage *)setImage:(UIImage *)image forKey:(NSString *)key expires:(NSDate *)expires {
	CKFastImage *imageInfo = [[CKFastImage alloc] initWithImage:image];
	
	[self setObject:imageInfo forKey:key expires:expires];
	
	return imageInfo.image;
}

- (UIImage *)setImageWithSize:(CGSize)size drawing:(void(^)(CGContextRef context))drawing forKey:(NSString *)key expires:(NSDate *)expires {
	CKFastImage *imageInfo = [[CKFastImage alloc] initWithSize:size scale:[UIScreen mainScreen].scale style:CKFastImageStyle32BitBGRA drawing:drawing];
	
	[self setObject:imageInfo forKey:key expires:expires];
	
	return imageInfo.image;
}

- (UIImage *)imageForKey:(NSString *)key {
	CKFastImage *imageInfo = [self objectForKey:key];
	
	if ([imageInfo isKindOfClass:[UIImage class]]) {
		return (UIImage *)imageInfo;
	} else if ([imageInfo isKindOfClass:[CKFastImage class]]) {
		return imageInfo.image;
	}
	
	return nil;
}

@end

#endif
