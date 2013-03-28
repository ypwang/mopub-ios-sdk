//
//  MPManualAdViewController.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPManualAdViewController.h"
#import "MPSampleAppInstanceProvider.h"

@interface MPManualAdViewController ()

@property (nonatomic, strong) MPInterstitialAdController *firstInterstitial;
@property (nonatomic, strong) MPInterstitialAdController *secondInterstitial;

@end

@implementation MPManualAdViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Manual";
    self.firstInterstitialShowButton.hidden = YES;
    self.secondInterstitialShowButton.hidden = YES;
}

- (IBAction)didTapFirstInterstitialLoadButton:(id)sender
{
    self.firstInterstitialLoadButton.enabled = NO;
    self.firstInterstitialStatusLabel.text = @"";
    [self.firstInterstitialActivityIndicator startAnimating];
    self.firstInterstitialShowButton.hidden = YES;

    self.firstInterstitial = [[MPSampleAppInstanceProvider sharedProvider] buildMPInterstitialAdControllerWithAdUnitID:self.firstInterstitialTextField.text];
    self.firstInterstitial.delegate = self;
    [self.firstInterstitial loadAd];
}

- (IBAction)didTapFirstInterstitialShowButton:(id)sender
{
    [self.firstInterstitial showFromViewController:self];
}

- (IBAction)didTapSecondInterstitialLoadButton:(id)sender
{
    self.secondInterstitialLoadButton.enabled = NO;
    self.secondInterstitialStatusLabel.text = @"";
    [self.secondInterstitialActivityIndicator startAnimating];
    self.secondInterstitialShowButton.hidden = YES;

    self.secondInterstitial = [[MPSampleAppInstanceProvider sharedProvider] buildMPInterstitialAdControllerWithAdUnitID:self.secondInterstitialTextField.text];
    self.secondInterstitial.delegate = self;
    [self.secondInterstitial loadAd];
}

- (IBAction)didTapSecondInterstitialShowButton:(id)sender
{
    [self.secondInterstitial showFromViewController:self];
}

#pragma mark - <MPInterstitialAdControllerDelegate>

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial
{
    if (interstitial == self.firstInterstitial) {
        [self.firstInterstitialActivityIndicator stopAnimating];
        self.firstInterstitialShowButton.hidden = NO;
        self.firstInterstitialLoadButton.enabled = YES;
    } else if (interstitial == self.secondInterstitial) {
        [self.secondInterstitialActivityIndicator stopAnimating];
        self.secondInterstitialShowButton.hidden = NO;
        self.secondInterstitialLoadButton.enabled = YES;
    }
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial
{
    if (interstitial == self.firstInterstitial) {
        [self.firstInterstitialActivityIndicator stopAnimating];
        self.firstInterstitialLoadButton.enabled = YES;
        self.firstInterstitialStatusLabel.text = @"Failed";
    } else if (interstitial == self.secondInterstitial) {
        [self.secondInterstitialActivityIndicator stopAnimating];
        self.secondInterstitialLoadButton.enabled = YES;
        self.secondInterstitialStatusLabel.text = @"Failed";
    }
}

- (void)interstitialDidExpire:(MPInterstitialAdController *)interstitial
{
    if (interstitial == self.firstInterstitial) {
        self.firstInterstitialStatusLabel.text = @"Expired";
        self.firstInterstitialShowButton.hidden = YES;
        self.firstInterstitialLoadButton.enabled = YES;
    } else if (interstitial == self.secondInterstitial) {
        self.secondInterstitialStatusLabel.text = @"Expired";
        self.secondInterstitialShowButton.hidden = YES;
        self.secondInterstitialLoadButton.enabled = YES;
    }
}

- (void)interstitialDidDisappear:(MPInterstitialAdController *)interstitial
{
    if (interstitial == self.firstInterstitial) {
        self.firstInterstitialShowButton.hidden = YES;
        self.firstInterstitialLoadButton.enabled = YES;
    } else if (interstitial == self.secondInterstitial) {
        self.secondInterstitialShowButton.hidden = YES;
        self.secondInterstitialLoadButton.enabled = YES;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

@end
