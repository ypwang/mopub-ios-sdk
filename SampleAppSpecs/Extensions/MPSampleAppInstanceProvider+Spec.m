//
//  MPSampleAppInstanceProvider+Spec.m
//  MoPubSampleApp
//
//  Created by pivotal on 3/18/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

@implementation MPSampleAppInstanceProvider (Spec)

+ (MPSampleAppInstanceProvider *)sharedProvider
{
    return fakeProvider;
}

@end
