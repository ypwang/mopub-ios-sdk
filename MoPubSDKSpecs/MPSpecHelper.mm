//
//  MPSpecHelper.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPSpecHelper.h"
#import "MPInterstitialAdController.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

static BOOL beforeAllDidRun = NO;

FakeMPInstanceProvider *fakeProvider;

void verify_fake_received_selectors(id<CedarDouble> fake, NSArray *selectors)
{
    fake.sent_messages.count should equal(selectors.count);

    for (int i = 0; i < [[fake sent_messages] count]; i++) {
        [[fake sent_messages][i] selector] should equal(NSSelectorFromString(selectors[i]));
    }

    [fake reset_sent_messages];
}


@implementation MPSpecHelper

+ (void)beforeEach
{
    if (!beforeAllDidRun) {
        usleep(200000);
        beforeAllDidRun = YES;
        [MMAdView setLogLevel:MMLOG_LEVEL_OFF];
    }

    fakeProvider = [[[FakeMPInstanceProvider alloc] init] autorelease];
}

+ (void)afterEach
{
    [[MPInterstitialAdController sharedInterstitialAdControllers] removeAllObjects];
}

@end
