//
//  FakeMMBannerAdView.h
//  MoPubSDK
//
//  Created by pivotal on 4/3/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMAdView.h"

@interface FakeMMBannerAdView : NSObject

@property (nonatomic, assign) id<MMAdDelegate> delegate;
@property (nonatomic, assign) MMAdType type;
@property (nonatomic, assign) NSString *apid;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) UIViewController *rootViewController;
@property (nonatomic, assign) BOOL hasRefreshed;

- (MMAdView *)masquerade;

@end
