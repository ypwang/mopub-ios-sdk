//
//  MPSpecHelper.m
//  MoPubSDK
//
//  Created by pivotal on 3/12/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPSpecHelper.h"

static BOOL didNap = NO;

@implementation MPSpecHelper

+ (void)beforeEach
{
    if (!didNap) {
        usleep(200000); //0.2 seconds
        didNap = YES;
    }
}

@end
