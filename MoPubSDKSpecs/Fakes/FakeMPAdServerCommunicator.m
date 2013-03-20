//
//  FakeMPAdServerCommunicator.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeMPAdServerCommunicator.h"

@implementation FakeMPAdServerCommunicator

- (void)loadURL:(NSURL *)URL
{
    self.loading = YES;
    self.loadedURL = URL;
}

- (void)cancel
{
    self.loading = NO;
    self.cancelled = YES;
}

- (void)receiveConfiguration:(MPAdConfiguration *)configuration
{
    self.loading = NO;
    [self.delegate communicatorDidReceiveAdConfiguration:configuration];
}

- (void)failWithError:(NSError *)error
{
    self.loading = NO;
    [self.delegate communicatorDidFailWithError:error];
}

- (void)reset
{
    self.cancelled = NO;
    self.loading = NO;
    self.loadedURL = nil;
}

@end
