//
//  MPAdDestinationDisplayAgent.h
//  MoPubSDK
//
//  Created by pivotal on 3/12/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPURLResolver.h"
#import "MPProgressOverlayView.h"
#import "MPAdBrowserController.h"
#import "MPStoreKitProvider.h"

@protocol MPAdDestinationDisplayAgentDelegate;

@interface MPAdDestinationDisplayAgent : NSObject <MPURLResolverDelegate, MPProgressOverlayViewDelegate, MPAdBrowserControllerDelegate, MPSKStoreProductViewControllerDelegate>

@property (nonatomic, assign) id<MPAdDestinationDisplayAgentDelegate> delegate;

+ (MPAdDestinationDisplayAgent *)agentWithURLResolver:(MPURLResolver *)resolver;

- (void)displayDestinationForURL:(NSURL *)URL;

@end

@protocol MPAdDestinationDisplayAgentDelegate <NSObject>

- (UIViewController *)viewControllerForPresentingModalView;
- (void)displayAgentWillPresentModal;
- (void)displayAgentWillLeaveApplication;
- (void)displayAgentDidDismissModal;

@end
