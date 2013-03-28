//
//  MPManualAdViewController.h
//  MoPubSampleApp
//
//  Created by pivotal on 3/28/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MPInterstitialAdController.h"

@interface MPManualAdViewController : UIViewController <MPInterstitialAdControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *firstInterstitialTextField;
@property (weak, nonatomic) IBOutlet UIButton *firstInterstitialLoadButton;
@property (weak, nonatomic) IBOutlet UIButton *firstInterstitialShowButton;
@property (weak, nonatomic) IBOutlet UILabel *firstInterstitialStatusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *firstInterstitialActivityIndicator;

@property (weak, nonatomic) IBOutlet UITextField *secondInterstitialTextField;
@property (weak, nonatomic) IBOutlet UIButton *secondInterstitialLoadButton;
@property (weak, nonatomic) IBOutlet UIButton *secondInterstitialShowButton;
@property (weak, nonatomic) IBOutlet UILabel *secondInterstitialStatusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *secondInterstitialActivityIndicator;

@end
