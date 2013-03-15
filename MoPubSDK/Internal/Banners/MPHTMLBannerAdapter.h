//
//  MPHTMLBannerAdapter.h
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPBaseAdapter.h"
#import "MPAdWebViewAgent.h"

@interface MPHTMLBannerAdapter : MPBaseAdapter <MPAdWebViewAgentDelegate>

@property (nonatomic, retain) MPAdWebViewAgent *bannerAgent;

@end
