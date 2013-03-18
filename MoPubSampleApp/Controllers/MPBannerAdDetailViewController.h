//
//  MPBannerAdDetailViewController.h
//  MoPubSampleApp
//
//  Created by pivotal on 3/18/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPAdView.h"

@class MPBannerAdInfo;

@interface MPBannerAdDetailViewController : UIViewController <MPAdViewDelegate>

@property (assign, nonatomic) IBOutlet UILabel *titleLabel;
@property (assign, nonatomic) IBOutlet UILabel *IDLabel;
@property (assign, nonatomic) IBOutlet UIView *adViewContainer;

- (id)initWithBannerAdInfo:(MPBannerAdInfo *)info;

@end
