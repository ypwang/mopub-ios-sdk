//
//  MPInstanceProvider+Spec.m
//  MoPubSDK
//
//  Created by pivotal on 3/15/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPInstanceProvider.h"

@implementation MPInstanceProvider (Spec)

+ (MPInstanceProvider *)sharedProvider
{
    return fakeProvider;
}

@end
