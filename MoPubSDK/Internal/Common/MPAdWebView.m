//
//  MPAdWebView.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPAdWebView.h"

#import "MPAdConfiguration.h"
#import "MPGlobal.h"
#import "MPLogging.h"
#import "CJSONDeserializer.h"
#import "MPAdDestinationDisplayAgent.h"

NSString * const kMoPubURLScheme = @"mopub";
NSString * const kMoPubCloseHost = @"close";
NSString * const kMoPubFinishLoadHost = @"finishLoad";
NSString * const kMoPubFailLoadHost = @"failLoad";
NSString * const kMoPubCustomHost = @"custom";

@interface MPAdWebView ()

@property (nonatomic, retain) MPAdConfiguration *configuration;
@property (nonatomic, readwrite, retain) UIWebView *webView;
@property (nonatomic, retain) MPAdDestinationDisplayAgent *destinationDisplayAgent;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MPAdWebView

@synthesize configuration = _configuration;
@synthesize webView = _webView;
@synthesize delegate = _delegate;
@synthesize customMethodDelegate = _customMethodDelegate;

- (id)initWithFrame:(CGRect)frame
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithFrame:(CGRect)frame delegate:(id<MPAdWebViewDelegate>)delegate destinationDisplayAgent:(MPAdDestinationDisplayAgent *)agent
{
    //DONE
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;

        CGRect webViewFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        _webView = [[UIWebView alloc] initWithFrame:webViewFrame];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _webView.backgroundColor = [UIColor clearColor];
        _webView.delegate = self;
        _webView.opaque = NO;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_4_0
        if ([_webView respondsToSelector:@selector(allowsInlineMediaPlayback)]) {
            [_webView setAllowsInlineMediaPlayback:YES];
            [_webView setMediaPlaybackRequiresUserAction:NO];
        }
#endif

        [self addSubview:_webView];

        self.delegate = delegate;
        self.destinationDisplayAgent = agent;
        self.destinationDisplayAgent.adWebView = self;
    }
    return self;
}

- (void)dealloc
{
    //DONE
    [_configuration release];

    _webView.delegate = nil;
    [_webView removeFromSuperview];
    [_webView release];

    self.destinationDisplayAgent = nil;

    [super dealloc];
}

#pragma mark - Public

- (void)loadConfiguration:(MPAdConfiguration *)configuration
{
    //DONE
    self.configuration = configuration;

    if ([configuration hasPreferredSize]) {
        [self setFrameFromConfiguration:configuration];
    }

    [_webView mp_setScrollable:configuration.scrollable];
    [self loadData:configuration.adResponseData MIMEType:@"text/html" textEncodingName:@"utf-8"
           baseURL:nil];
}

- (NSString *)htmlForLinks:(NSArray *)links
{
    NSString *output = @"<html><body>";
    for (NSString *link in links) {
        output = [output stringByAppendingFormat:@"<a href=\"%@\">%@</a><br>", link, link];
    }
    output = [output stringByAppendingString:@"</body></html>"];
    return output;
}

- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType
textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL
{
    //DONE
    NSString *HTMLString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    [_webView loadHTMLString:HTMLString baseURL:baseURL];
}

- (void)invokeJavaScriptForEvent:(MPAdWebViewEvent)event
{
    //DONE
    switch (event) {
        case MPAdWebViewEventAdDidAppear:
            [_webView stringByEvaluatingJavaScriptFromString:@"webviewDidAppear();"];
            break;
        case MPAdWebViewEventAdDidDisappear:
            [_webView stringByEvaluatingJavaScriptFromString:@"webviewDidClose();"];
            break;
        default:
            break;
    }
}

#pragma mark - Internal

- (void)setFrameFromConfiguration:(MPAdConfiguration *)configuration
{
    //DONE
    if (configuration.preferredSize.width <= 0 || configuration.preferredSize.height <= 0) {
        return;
    }

    CGRect frame = self.frame;
    frame.size.width = configuration.preferredSize.width;
    frame.size.height = configuration.preferredSize.height;
    self.frame = frame;
}


- (NSString *)clickDetectionURLPrefix
{
    //MOVE TO configuration
    if ([self.configuration.interceptURLPrefix absoluteString]) {
        return [self.configuration.interceptURLPrefix absoluteString];
    } else {
        return @"";
    }
}

- (NSString *)clickTrackingURL
{
    //DONE
    return [self.configuration.clickTrackingURL absoluteString];
}

#pragma mark - Rotation

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation
{
    //DONE
    [self forceRedraw];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    //DONE
    if (self.isDismissed) {
        return NO;
    }

    NSURL *URL = [request URL];

    if ([[URL scheme] isEqualToString:kMoPubURLScheme]) {
        [self performActionForMoPubSpecificURL:URL];
        return NO;
    } else if ([self shouldShowClickBrowserForURL:URL navigationType:navigationType]) {
        NSString *encodedURLString = [[URL absoluteString] URLEncodedString];
        NSURL *redirectedURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@&r=%@",
                                                     self.clickTrackingURL,
                                                     encodedURLString]];

        [self.destinationDisplayAgent displayDestinationForURL:redirectedURL];
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - MoPub-specific URL handlers

- (void)performActionForMoPubSpecificURL:(NSURL *)URL
{
    //DONE
    MPLogDebug(@"MPAdWebView - loading MoPub URL: %@", URL);
    NSString *host = [URL host];
    if ([host isEqualToString:kMoPubCloseHost] &&
        [self.delegate respondsToSelector:@selector(adDidClose:)]) {
        [self.delegate adDidClose:self];
    } else if ([host isEqualToString:kMoPubFinishLoadHost] &&
               [self.delegate respondsToSelector:@selector(adDidFinishLoadingAd:)]) {
        [self.delegate adDidFinishLoadingAd:self];
    } else if ([host isEqualToString:kMoPubFailLoadHost] &&
               [self.delegate respondsToSelector:@selector(adDidFailToLoadAd:)]) {
        [self.delegate adDidFailToLoadAd:self];
    } else if ([host isEqualToString:kMoPubCustomHost]) {
        [self handleMoPubCustomURL:URL];
    } else {
        MPLogWarn(@"MPAdWebView - unsupported MoPub URL: %@", [URL absoluteString]);
    }
}

- (void)handleMoPubCustomURL:(NSURL *)URL
{
    //DONE
    NSDictionary *queryParameters = [self dictionaryFromQueryString:[URL query]];
    NSString *selectorName = [queryParameters objectForKey:@"fnc"];
    NSString *dataString = [queryParameters objectForKey:@"data"];

    CJSONDeserializer *deserializer = [CJSONDeserializer deserializerWithNullObject:NULL];
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dataDictionary = [deserializer deserializeAsDictionary:data error:&error];

    NSString *oneArgumentSelectorName = [selectorName stringByAppendingString:@":"];
    SEL oneArgumentSelector = NSSelectorFromString(oneArgumentSelectorName);
    SEL zeroArgumentSelector = NSSelectorFromString(selectorName);

    if ([self.customMethodDelegate respondsToSelector:zeroArgumentSelector]) {
        [self.customMethodDelegate performSelector:zeroArgumentSelector];
    } else if ([self.customMethodDelegate respondsToSelector:oneArgumentSelector]) {
        [self.customMethodDelegate performSelector:oneArgumentSelector withObject:dataDictionary];
    } else {
        MPLogError(@"Custom method delegate does not implement custom selectors %@ or %@.",
                   selectorName, oneArgumentSelectorName);
    }
}

- (BOOL)shouldShowClickBrowserForURL:(NSURL *)URL
                      navigationType:(UIWebViewNavigationType)navigationType
{
    //DONE
    if (!(self.configuration.shouldInterceptLinks)) {
        return NO;
    } else if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        return YES;
    } else if (navigationType == UIWebViewNavigationTypeOther) {
        return [[URL absoluteString] hasPrefix:[self clickDetectionURLPrefix]];
    } else {
        return NO;
    }
}

#pragma mark - Utility

- (NSDictionary *)dictionaryFromQueryString:(NSString *)query
{
    //WILL MOVE
    NSMutableDictionary *queryDict = [[NSMutableDictionary alloc] initWithCapacity:1];
    NSArray *queryElements = [query componentsSeparatedByString:@"&"];
    for (NSString *element in queryElements) {
        NSArray *keyVal = [element componentsSeparatedByString:@"="];
        NSString *key = [keyVal objectAtIndex:0];
        NSString *value = [keyVal lastObject];
        [queryDict setObject:[value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                      forKey:key];
    }
    return [queryDict autorelease];
}

- (void)forceRedraw
{
    //DONE
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    int angle = -1;
    switch (orientation)
    {
        case UIDeviceOrientationPortrait: angle = 0; break;
        case UIDeviceOrientationLandscapeLeft: angle = 90; break;
        case UIDeviceOrientationLandscapeRight: angle = -90; break;
        case UIDeviceOrientationPortraitUpsideDown: angle = 180; break;
        default: break;
    }

    if (angle == -1) return;

    // UIWebView doesn't seem to fire the 'orientationchange' event upon rotation, so we do it here.
    NSString *orientationEventScript = [NSString stringWithFormat:
                                        @"window.__defineGetter__('orientation',function(){return %d;});"
                                        @"(function(){ var evt = document.createEvent('Events');"
                                        @"evt.initEvent('orientationchange',true,true);window.dispatchEvent(evt);})();",
                                        angle];
    [_webView stringByEvaluatingJavaScriptFromString:orientationEventScript];

    // XXX: If the UIWebView is rotated off-screen (which may happen with interstitials), its
    // content may render off-center upon display. We compensate by setting the viewport meta tag's
    // 'width' attribute to be the size of the webview.
    NSString *viewportUpdateScript = [NSString stringWithFormat:
                                      @"document.querySelector('meta[name=viewport]')"
                                      @".setAttribute('content', 'width=%f;', false);",
                                      _webView.frame.size.width];
    [_webView stringByEvaluatingJavaScriptFromString:viewportUpdateScript];
}

@end
