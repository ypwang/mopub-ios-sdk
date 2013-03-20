//
//  KIFTestScenario+Millennial.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestScenario+Millennial.h"
#import "UIView-KIFAdditions.h"

@implementation KIFTestStep (MillennialScenario)

+ (KIFTestStep *)stepToDismissMillennialInterstitial {
    return [KIFTestStep stepWithDescription:@"Dismiss millennial interstitial" executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {

        UIViewController *topMostViewController = [KIFHelper topMostViewController];
        [topMostViewController.view tapAtPoint:CGPointMake(5, 5)]; //tap the page curl to hide

        return KIFTestStepResultSuccess;
    }];
}

@end


@implementation KIFTestScenario (Millennial)

+ (KIFTestScenario *)scenarioForMillennialInterstitial
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that a Millennial interstitial ad works."];
    NSIndexPath *indexPath = [MPAdSection indexPathForAd:@"Millennial Phone Interstitial" inSection:@"Interstitial Ads"];
    [scenario addStep:[KIFTestStep stepToTapRowInTableViewWithAccessibilityLabel:@"Ad Table View"
                                                                     atIndexPath:indexPath]];

    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Load"]];
    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Show"]];
    [scenario addStep:[KIFTestStep stepToVerifyPresentationOfViewControllerClass:NSClassFromString(@"MMOverlayViewController")]];
    [scenario addStep:[KIFTestStep stepToDismissMillennialInterstitial]];
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"expired"]];
    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];

    return scenario;
}

@end
