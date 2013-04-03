//
//  FakeMMBannerAdView.h
//  MoPub
//
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
