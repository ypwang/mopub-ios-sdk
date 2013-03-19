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

+ (id)stepToVerifyPresenceOfStoreKit
{
    return [KIFTestStep stepWithDescription:@"Verify StoreKit is on-screen." executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {

        UIViewController *topViewController = [KIFHelper topMostViewController];
        KIFTestWaitCondition([topViewController isKindOfClass:[SKStoreProductViewController class]], error, @"Failed to find store kit");

        [KIFHelper waitForViewControllerToStopAnimating:topViewController];
        return KIFTestStepResultSuccess;
    }];
}

+ (id)stepToDismissStoreKit
{
    return [KIFTestStep stepWithDescription:@"Dismiss StoreKit." executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {

        SKStoreProductViewController *topViewController = (SKStoreProductViewController *)[KIFHelper topMostViewController];
        [topViewController.delegate productViewControllerDidFinish:topViewController];
        [KIFHelper waitForViewControllerToStopAnimating:topViewController];

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
    [scenario addStep:[KIFTestStep stepToTapLink:@"LinkMaker"]];
    [scenario addStep:[KIFTestStep stepToVerifyPresenceOfStoreKit]];
    [scenario addStep:[KIFTestStep stepToDismissStoreKit]];
    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];

    return scenario;
}

+ (id)scenarioForBannerAdWithInvalidStoreKitLink
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that a banner ad with a StoreKit link to an invalid item does not explode."];
    [scenario addStep:[KIFTestStep stepToTapRowInTableViewWithAccessibilityLabel:@"Banner Ad Table View"
                                                                     atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]];
    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];
    [scenario addStep:[KIFTestStep stepToTapLink:@"Invalid iTunes Item"]];
    [scenario addStep:[KIFTestStep stepToVerifyPresenceOfStoreKit]];
    [scenario addStep:[KIFTestStep stepToTapScreenAtPoint:CGPointMake(160, 290)]];
    [scenario addStep:[KIFTestStep stepToDismissStoreKit]];
    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];

    return scenario;
}

@end
