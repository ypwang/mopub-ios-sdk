//
//  MPAdDestinationDisplayAgent.m
//  MoPubSDK
//
//  Created by pivotal on 3/12/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPAdDestinationDisplayAgent.h"
#import "MPAdWebView.h"

@implementation MPAdDestinationDisplayAgent

+ (MPAdDestinationDisplayAgent *)agentWithDelegate:(id<MPAdWebViewDelegate>)delegate
{
    return nil;
}

- (void)displayDestinationForURL:(NSURL *)URL
{

}

#pragma mark - <MPURLResolverDelegate>

- (void)showWebViewWithHTMLString:(NSString *)HTMLString baseURL:(NSURL *)URL
{
    
}

- (void)showStoreKitProductWithParameter:(NSString *)parameter fallbackURL:(NSURL *)URL
{
    
}

- (void)openURLInApplication:(NSURL *)URL
{
    
}

- (void)failedToResolveURLWithError:(NSError *)error
{
    
}

@end
