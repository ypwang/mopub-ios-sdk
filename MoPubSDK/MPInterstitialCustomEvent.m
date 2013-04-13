//
//  MPInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPInterstitialCustomEvent.h"

@implementation MPInterstitialCustomEvent

@synthesize delegate;

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    // The default implementation of this method does nothing. Subclasses must override this method
    // and implement code to load an interstitial here.
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    //DOCUMENT: This will automatically track clicks and impressions and only track them once per ad.
    //IF YOU OVERRIDE THIS AND RETURN NO YOU WILL HAVE TO TRACK CLICKS/IMPRESSIONS YOURSELF.  NOTE FOR
    //ACCURATE METRICS YOU SHOULD CALL THE TRACKING METHODS JUDICIOUSLY
    return YES;
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    // The default implementation of this method does nothing. Subclasses must override this method
    // and implement code to display an interstitial here.
}

- (void)customEventDidUnload
{
    // Your subclass can implement this method if it needs to perform any cleanup, or simply do
    // the cleanup work in -dealloc. If you override this method, make sure to call
    // [super customEventDidUnload].

    self.delegate = nil;
}

@end
