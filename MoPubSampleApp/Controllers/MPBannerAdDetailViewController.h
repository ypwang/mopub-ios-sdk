//
//  MPBannerAdDetailViewController.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPAdView.h"

@class MPBannerAdInfo;

@interface MPBannerAdDetailViewController : UIViewController <MPAdViewDelegate>

@property (assign, nonatomic) IBOutlet UILabel *titleLabel;
@property (assign, nonatomic) IBOutlet UILabel *IDLabel;
@property (assign, nonatomic) IBOutlet UIView *adViewContainer;
@property (assign, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

- (id)initWithBannerAdInfo:(MPBannerAdInfo *)info;

@end
