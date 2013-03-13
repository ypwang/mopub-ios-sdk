//
//  FakeMPURLResolver.m
//  MoPubSDK
//
//  Created by pivotal on 3/13/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeMPURLResolver.h"

@implementation FakeMPURLResolver

- (void)startResolvingWithURL:(NSURL *)URL delegate:(id<MPURLResolverDelegate>)delegate
{
    self.URL = URL;
}

- (void)cancel
{
    self.didCancel = YES;
}

@end
