//
//  MPAdDestinationDisplayAgent.h
//  MoPubSDK
//
//  Created by pivotal on 3/12/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPURLResolver.h"
#import "MPAdWebViewDelegate.h"
#import "MPProgressOverlayView.h"
#import "MPAdBrowserController.h"
#import "MPStoreKitProvider.h"

@interface MPAdDestinationDisplayAgent : NSObject <MPURLResolverDelegate, MPProgressOverlayViewDelegate, MPAdBrowserControllerDelegate, MPSKStoreProductViewControllerDelegate>

@property (nonatomic, assign) MPAdWebView *adWebView;

+ (MPAdDestinationDisplayAgent *)agentWithURLResolver:(MPURLResolver *)resolver
                                             delegate:(id<MPAdWebViewDelegate>)delegate;

- (void)displayDestinationForURL:(NSURL *)URL;

@end
