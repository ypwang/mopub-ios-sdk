//
//  MPSampleAppTestScenario.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPSampleAppTestScenario.h"
#import "KIFTestStep.h"

static BOOL slowDown = YES;

@implementation MPSampleAppTestScenario

- (void)addStep:(KIFTestStep *)step
{
    [super addStep:step];
    if (slowDown) {
        [super addStep:[KIFTestStep stepToWaitForTimeInterval:0.5 description:@"Waiting for half a second."]];
    }
}

@end
