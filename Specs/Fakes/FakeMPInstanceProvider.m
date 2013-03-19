//
//  FakeMPInstanceProvider.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeMPInstanceProvider.h"

@implementation FakeMPInstanceProvider

- (id)returnFake:(id)fake orCall:(IDReturningBlock)block
{
    if (fake) {
        return fake;
    } else {
        return block();
    }
}
- (MPAdWebViewAgent *)buildMPAdWebViewAgentWithAdWebViewFrame:(CGRect)frame delegate:(id<MPAdWebViewAgentDelegate>)delegate
{
    return [self returnFake:self.fakeMPAdWebViewAgent
                     orCall:^{
                         return [super buildMPAdWebViewAgentWithAdWebViewFrame:frame
                                                                      delegate:delegate];
                     }];
}

- (MPAdWebView *)buildMPAdWebViewWithFrame:(CGRect)frame delegate:(id<UIWebViewDelegate>)delegate
{
    return [self returnFake:self.fakeMPAdWebViewAgent
                     orCall:^{
                         return [super buildMPAdWebViewWithFrame:frame
                                                        delegate:delegate];
                     }];
}

- (MPAdDestinationDisplayAgent *)buildMPAdDestinationDisplayAgentWithDelegate:(id<MPAdDestinationDisplayAgentDelegate>)delegate
{
    return [self returnFake:self.fakeMPAdDestinationDisplayAgent
                     orCall:^{
                         return [super buildMPAdDestinationDisplayAgentWithDelegate:delegate];
                     }];
}

- (MPURLResolver *)buildMPURLResolver
{
    return [self returnFake:self.fakeMPURLResolver
                     orCall:^{
                         return [super buildMPURLResolver];
                     }];
}

@end
