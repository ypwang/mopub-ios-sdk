//
//  MPSpecHelper.m
//  MoPubSDK
//
//  Created by pivotal on 3/12/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPSpecHelper.h"

static BOOL didNap = NO;

FakeMPInstanceProvider *fakeProvider;

@implementation MPSpecHelper

+ (void)beforeEach
{
    if (!didNap) {
        usleep(200000);
        didNap = YES;
    }

    fakeProvider = [[[FakeMPInstanceProvider alloc] init] autorelease];
}

@end
