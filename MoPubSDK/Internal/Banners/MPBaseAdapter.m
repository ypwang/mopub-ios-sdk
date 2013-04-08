//
//  MPBaseAdapter.m
//  MoPub
//
//  Created by Nafis Jamal on 1/19/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import "MPBaseAdapter.h"

#import "MPAdConfiguration.h"
#import "MPLogging.h"
#import "MPInstanceProvider.h"
#import "MPAnalyticsTracker.h"

@interface MPBaseAdapter ()

@property (nonatomic, retain) NSMutableURLRequest *metricsURLRequest;
@property (nonatomic, retain) MPAnalyticsTracker *analyticsTracker;
@property (nonatomic, retain) MPAdConfiguration *configuration;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MPBaseAdapter

@synthesize delegate = _delegate;
@synthesize analyticsTracker = _analyticsTracker;
@synthesize configuration = _configuration;

- (id)initWithAdapterDelegate:(id<MPAdapterDelegate>)delegate
{
    if (self = [super init]) {
        self.delegate = delegate;
        self.analyticsTracker = [[MPInstanceProvider sharedProvider] buildMPAnalyticsTracker];
    }
    return self;
}

- (void)dealloc
{
    [self unregisterDelegate];
    self.analyticsTracker = nil;
    self.configuration = nil;
    
    [_metricsURLRequest release];
    [super dealloc];
}

- (void)unregisterDelegate
{
    self.delegate = nil;
}

#pragma mark - Requesting Ads

- (void)getAdWithConfiguration:(MPAdConfiguration *)configuration
{
    // To be implemented by subclasses.
    [self doesNotRecognizeSelector:_cmd];
}

- (void)_getAdWithConfiguration:(MPAdConfiguration *)configuration
{
    self.configuration = configuration;

    [self retain];
    [self getAdWithConfiguration:configuration];
    [self release];
}

#pragma mark - Rotation

- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation
{
    // Do nothing by default. Subclasses can override.
    MPLogDebug(@"rotateToOrientation %d called for adapter %@ (%p)",
          newOrientation, NSStringFromClass([self class]), self);
}

#pragma mark - Metrics

- (void)trackImpression
{
    [self.analyticsTracker trackImpressionForConfiguration:self.configuration];
}

- (void)trackClick
{
    [self.analyticsTracker trackClickForConfiguration:self.configuration];
}

@end
