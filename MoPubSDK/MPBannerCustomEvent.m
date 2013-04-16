//
//  MPBannerCustomEvent.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPBannerCustomEvent.h"

@implementation MPBannerCustomEvent

@synthesize delegate;


- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    // The default implementation of this method does nothing. Subclasses must override this method
    // and implement code to load a banner here.
}

- (void)didDisplayAd
{
    // TODO: DOCUMENT ME!
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    //DOCUMENT: This will automatically track clicks and impressions and only track them once per ad.
    //IF YOU OVERRIDE THIS AND RETURN NO YOU WILL HAVE TO TRACK CLICKS/IMPRESSIONS YOURSELF.  NOTE FOR
    //ACCURATE METRICS YOU SHOULD CALL THE TRACKING METHODS JUDICIOUSLY
    return YES;
}

- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation
{
    // TODO: DOCUMENT ME!
}

@end
