//
//  KIFTestScenario+StoreKitScenario.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestScenario+StoreKitScenario.h"
#import "MPSampleAppTestScenario.h"
#import "KIFTestStep.h"
#import <StoreKit/StoreKit.h>

@implementation KIFTestStep (StoreKitScenario)

+ (id)stepToVerifyAndHideStoreKit
{
    return [KIFTestStep stepWithDescription:@"Verify StoreKit is on-screen." executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {

        UIViewController *topViewController = [KIFHelper topMostViewController];
        KIFTestWaitCondition([topViewController isKindOfClass:[SKStoreProductViewController class]], error, @"Failed to find store kit");

        [KIFHelper waitForViewControllerToStopAnimating:topViewController];
        [topViewController.presentingViewController dismissViewControllerAnimated:NO
                                                                       completion:nil];
        return KIFTestStepResultSuccess;
    }];
}

@end

@implementation KIFTestScenario (StoreKitScenario)

+ (id)scenarioForBannerAdWithStoreKitLink
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that a banner ad with a StoreKit link works."];
    [scenario addStep:[KIFTestStep stepToTapRowInTableViewWithAccessibilityLabel:@"Banner Ad Table View"
                                                                     atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]];
    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];
    [scenario addStep:[KIFTestStep stepToTapLink:@"App Store Link"]];
    [scenario addStep:[KIFTestStep stepToVerifyAndHideStoreKit]];
    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];

    return scenario;
}

@end
