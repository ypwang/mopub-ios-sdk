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

- (void)customEventDidUnload
{
    // Your subclass can implement this method if it needs to perform any cleanup, or simply do
    // the cleanup work in -dealloc. If you override this method, make sure to call
    // [super customEventDidUnload].
    
    self.delegate = nil;
}

@end
