//
//  MPFeatureDetector.h
//  MoPubSDK
//
//  Created by pivotal on 3/13/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_6_0
#import <StoreKit/StoreKit.h>
#endif


@class SKStoreProductViewController;

@interface MPStoreKitProvider : NSObject

+ (BOOL)deviceHasStoreKit;
+ (SKStoreProductViewController *)buildController;

@end

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_6_0
@protocol MPSKStoreProductViewControllerDelegate <SKStoreProductViewControllerDelegate>
#else
@protocol MPSKStoreProductViewControllerDelegate
#endif
@end
