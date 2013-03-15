//
//  MPInstanceProvider.h
//  MoPubSDK
//
//  Created by pivotal on 3/15/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MPAdWebViewAgent;
@class MPAdWebView;
@class MPAdDestinationDisplayAgent;
@class MPURLResolver;

@protocol MPAdWebViewAgentDelegate;
@protocol MPAdDestinationDisplayAgentDelegate;

@interface MPInstanceProvider : NSObject

+ (MPInstanceProvider *)sharedProvider;

- (MPAdWebViewAgent *)buildMPAdWebViewAgentWithAdWebViewFrame:(CGRect)frame
                                                     delegate:(id<MPAdWebViewAgentDelegate>)delegate;
- (MPAdWebView *)buildMPAdWebViewWithFrame:(CGRect)frame
                                  delegate:(id<UIWebViewDelegate>)delegate;
- (MPAdDestinationDisplayAgent *)buildMPAdDestinationDisplayAgentWithDelegate:(id<MPAdDestinationDisplayAgentDelegate>)delegate;
- (MPURLResolver *)buildMPURLResolver;

@end
