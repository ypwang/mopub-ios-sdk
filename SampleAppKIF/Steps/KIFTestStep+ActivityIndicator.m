//
//  KIFTestStep+ActivityIndicator.m
//  MoPubSampleApp
//
//  Created by pivotal on 3/18/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestStep+ActivityIndicator.h"

@implementation KIFTestStep (ActivityIndicator)

+ (id)stepToWaitUntilActivityIndicatorIsNotAnimating
{
    return [KIFTestStep stepWithDescription:@"Verify Spinner has stopped spinning." executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {
        NSArray *indicators = [KIFHelper findViewsOfClass:[UIActivityIndicatorView class]];
        for (UIActivityIndicatorView *indicator in indicators) {
            if (indicator.isAnimating) {
                KIFTestWaitCondition(NO, error, @"Spinner is still animating");
            }
        }
        return KIFTestStepResultSuccess;
    }];
}

@end
