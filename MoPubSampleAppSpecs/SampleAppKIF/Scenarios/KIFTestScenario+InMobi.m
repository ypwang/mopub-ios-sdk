//
//  KIFTestScenario+InMobi.m
//  MoPubSampleApp
//
//  Created by pivotal on 3/26/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestScenario+InMobi.h"

@implementation KIFTestScenario (InMobi)

+ (KIFTestScenario *)scenarioForInMobiInterstitial
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that an InMobi interstitial ad works."];
    NSIndexPath *indexPath = [MPAdSection indexPathForAd:@"InMobi Interstitial" inSection:@"Interstitial Ads"];
    [scenario addStep:[KIFTestStep stepToTapRowInTableViewWithAccessibilityLabel:@"Ad Table View"
                                                                     atIndexPath:indexPath]];

    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Load"]];
    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Show"]];
    [scenario addStep:[KIFTestStep stepToWaitForPresenceOfViewWithClassName:@"GSFullscreenAdView"]];
    [scenario addStep:[KIFTestStep stepToPerformBlock:^{
        // We can't get KIF to tap on Greystripe's webview, so instead, we grab the controller and tell it to go away
        id gsFullScreenAdViewController = [KIFHelper topMostViewController];
        [gsFullScreenAdViewController dismissAnimated:YES];
    }]];
    [scenario addStep:[KIFTestStep stepToWaitForAbsenseOfViewWithClassName:@"GSFullscreenAdView"]];

    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];

    return scenario;
}

@end
