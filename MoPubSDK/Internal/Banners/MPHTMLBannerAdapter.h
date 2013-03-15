//
//  MPHTMLBannerAdapter.h
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPBaseAdapter.h"

#import "MPAdWebViewDelegate.h"

@interface MPHTMLBannerAdapter : MPBaseAdapter <MPAdWebViewDelegate>
{
    MPAdWebView *_banner;
}

@end
