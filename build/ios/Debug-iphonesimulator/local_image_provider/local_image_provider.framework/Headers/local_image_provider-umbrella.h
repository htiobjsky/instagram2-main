#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "LocalImageProviderPlugin.h"

FOUNDATION_EXPORT double local_image_providerVersionNumber;
FOUNDATION_EXPORT const unsigned char local_image_providerVersionString[];

