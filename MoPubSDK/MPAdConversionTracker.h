//
//  MPAdConversionTracker.h
//  MoPub
//
//  Created by Andrew He on 2/4/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPGlobal.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_5_0
@interface MPAdConversionTracker : NSObject <NSURLConnectionDataDelegate>
#else
@interface MPAdConversionTracker : NSObject
#endif

+ (MPAdConversionTracker *)sharedConversionTracker;

/*
 * Notify MoPub that the current user has opened the application corresponding to appID.
 */
- (void)reportApplicationOpenForApplicationID:(NSString *)appID;

@end
