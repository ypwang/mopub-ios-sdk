//
//  MPInstanceProvider.m
//  MoPubSDK
//
//  Created by pivotal on 3/15/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPInstanceProvider.h"
#import "MPAdWebView.h"
#import "MPAdDestinationDisplayAgent.h"
#import "MPURLResolver.h"
#import "MPAdWebViewAgent.h"

@implementation MPInstanceProvider

static MPInstanceProvider *sharedProvider = nil;

+ (MPInstanceProvider *)sharedProvider
{
    if (!sharedProvider) {
        sharedProvider = [[MPInstanceProvider alloc] init];
    }
    return sharedProvider;
}

- (MPAdWebViewAgent *)buildMPAdWebViewAgentWithAdWebViewFrame:(CGRect)frame delegate:(id<MPAdWebViewAgentDelegate>)delegate
{
    return [[[MPAdWebViewAgent alloc] initWithAdWebViewFrame:frame delegate:delegate] autorelease];
}

- (MPAdWebView *)buildMPAdWebViewWithFrame:(CGRect)frame delegate:(id<UIWebViewDelegate>)delegate
{
    MPAdWebView *webView = [[[MPAdWebView alloc] initWithFrame:frame] autorelease];
    webView.delegate = delegate;
    return webView;
}

- (MPAdDestinationDisplayAgent *)buildMPAdDestinationDisplayAgentWithDelegate:(id<MPAdDestinationDisplayAgentDelegate>)delegate
{
    return [MPAdDestinationDisplayAgent agentWithDelegate:delegate];
}

- (MPURLResolver *)buildMPURLResolver
{
    return [MPURLResolver resolver];
}

@end

