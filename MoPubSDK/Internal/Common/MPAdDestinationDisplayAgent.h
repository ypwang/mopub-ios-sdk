//
//  MPAdDestinationDisplayAgent.h
//  MoPubSDK
//
//  Created by pivotal on 3/12/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPURLResolver.h"

@protocol MPAdWebViewDelegate;

@interface MPAdDestinationDisplayAgent : NSObject <MPURLResolverDelegate>

+ (MPAdDestinationDisplayAgent *)agentWithDelegate:(id<MPAdWebViewDelegate>)delegate;

- (void)displayDestinationForURL:(NSURL *)URL;

@end
