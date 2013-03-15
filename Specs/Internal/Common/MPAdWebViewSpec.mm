#import "MPAdWebView.h"
#import "MPAdConfigurationFactory.h"
#import "MPAdDestinationDisplayAgent.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@protocol SassyProtocol <NSObject>
- (void)mySassyMethod:(NSDictionary *)sass;
@end

@protocol VerySassyProtocol <SassyProtocol>
- (void)mySassyMethod;
@end

SPEC_BEGIN(MPAdWebViewSpec)

describe(@"MPAdWebView", ^{
    __block MPAdWebView *view;
    __block id<CedarDouble, MPAdWebViewDelegate> delegate;
    __block MPAdDestinationDisplayAgent<CedarDouble> *destinationDisplayAgent;
    __block MPAdConfiguration *configuration;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPAdWebViewDelegate));
        destinationDisplayAgent = nice_fake_for([MPAdDestinationDisplayAgent class]);
        view = [[[MPAdWebView alloc] initWithFrame:CGRectMake(0, 0, 30, 20)
                                          delegate:delegate
                           destinationDisplayAgent:destinationDisplayAgent] autorelease];
        configuration = [MPAdConfigurationFactory defaultBannerConfiguration];
    });

    describe(@"on init, setting up the webview", ^{
        it(@"should allow inline media playback without user action", ^{
            view.webView.allowsInlineMediaPlayback should equal(YES);
            view.webView.mediaPlaybackRequiresUserAction should equal(NO);
        });
    });

    describe(@"when the configuration is loaded", ^{
        subjectAction(^{ [view loadConfiguration:configuration]; });

        describe(@"setting the frame", ^{
            context(@"when the frame sizes are valid", ^{
                it(@"should set its frame", ^{
                    view.frame.size.width should equal(320);
                    view.frame.size.height should equal(50);
                });
            });

            context(@"when the frame sizes are invalid", ^{
                beforeEach(^{
                    configuration.preferredSize = CGSizeMake(0, 0);
                });

                it(@"should not set its frame", ^{
                    view.frame.size.width should equal(30);
                    view.frame.size.height should equal(20);
                });
            });
        });

        describe(@"setting scrollability", ^{
            context(@"when the configuration says no", ^{
                beforeEach(^{
                    configuration.scrollable = NO;
                });

                it(@"should disable scrolling", ^{
                    view.webView.scrollView.scrollEnabled should equal(NO);
                });
            });

            context(@"when the configuration says yes", ^{
                beforeEach(^{
                    configuration.scrollable = YES;
                });

                it(@"should enable scrolling", ^{
                    view.webView.scrollView.scrollEnabled should equal(YES);
                });
            });
        });

        describe(@"loading webview data", ^{
            it(@"should load the ad's HTML data into the webview", ^{
                view.webView.loadedHTMLString should equal(@"Publisher's Ad");
            });
        });
    });

    describe(@"handling webview navigation", ^{
        __block NSURL *URL;

        subjectAction(^{ [view loadConfiguration:configuration]; });

        context(@"when isDismissed", ^{
            it(@"should never load anything", ^{
                view.dismissed = YES;
                NSURL *URL = [NSURL URLWithString:@"mopub://close"];
                [view webView:view.webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);
                delegate should_not have_received(@selector(adDidClose:)).with(view);
            });
        });

        context(@"when the URL scheme is mopub://", ^{
            context(@"when the host is 'close'", ^{
                it(@"should tell the delegate that adDidClose:", ^{
                    NSURL *URL = [NSURL URLWithString:@"mopub://close"];
                    [view webView:view.webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);
                    delegate should have_received(@selector(adDidClose:)).with(view);
                });
            });

            context(@"when the host is 'finishLoad'", ^{
                it(@"should tell the delegate that adDidFinishLoadingAd:", ^{
                    NSURL *URL = [NSURL URLWithString:@"mopub://finishLoad"];
                    [view webView:view.webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);
                    delegate should have_received(@selector(adDidFinishLoadingAd:)).with(view);
                });
            });

            context(@"when the host is 'failLoad'", ^{
                it(@"should tell the delegate that adDidFailToLoadAd:", ^{
                    NSURL *URL = [NSURL URLWithString:@"mopub://failLoad"];
                    [view webView:view.webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);
                    delegate should have_received(@selector(adDidFailToLoadAd:)).with(view);
                });
            });

            context(@"when the host is 'custom'", ^{
                beforeEach(^{
                    URL = [NSURL URLWithString:@"mopub://custom?fnc=mySassyMethod&data=%7B%22foo%22%3A3%7D"];
                });

                context(@"when the custom method delegate responds to -mySassyMethod (no arguments)", ^{
                    it(@"should call -mySassyMethod on the custom method delegate", ^{
                        id<CedarDouble, VerySassyProtocol> customMethodDelegate = nice_fake_for(@protocol(VerySassyProtocol));
                        view.customMethodDelegate = customMethodDelegate;
                        [view webView:view.webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);

                        customMethodDelegate should have_received("mySassyMethod");
                    });
                });

                context(@"when the custom method delegate responds to -mySassyMethod: but not -mySassyMethod", ^{
                    it(@"should call -mySassyMethod: on the custom method delegate and pass in data", ^{
                        id<CedarDouble, VerySassyProtocol> customMethodDelegate = nice_fake_for(@protocol(SassyProtocol));
                        view.customMethodDelegate = customMethodDelegate;
                        [view webView:view.webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);

                        customMethodDelegate should have_received("mySassyMethod:").with(@{@"foo": @3});
                    });
                });

                context(@"when the custom method delegate responds to neither method", ^{
                    it(@"should not blow up", ^{
                        id customMethodDelegate = [[[NSObject alloc] init] autorelease];
                        view.customMethodDelegate = customMethodDelegate;
                        [view webView:view.webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);
                    });
                });
            });

            context(@"when the host is something else", ^{
                beforeEach(^{
                    URL = [NSURL URLWithString:@"mopub://other"];
                });

                it(@"should not blow up and prevent the web view from handling the URL", ^{
                    [view webView:view.webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);
                });
            });
        });

        context(@"when the scheme is not mopub", ^{
            beforeEach(^{
                URL = [NSURL URLWithString:@"http://yay.com"];
            });

            context(@"when navigation should not be intercepted", ^{
                beforeEach(^{
                    configuration.shouldInterceptLinks = NO;
                });

                it(@"should tell the webview to load the URL", ^{
                    [view webView:view.webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(YES);
                });
            });

            context(@"when navigation should be intercepted", ^{
                beforeEach(^{
                    configuration.shouldInterceptLinks = YES;
                });

                context(@"when the navigation type is a click", ^{
                    it(@"should ask an ad destination display agent to handle the URL, prepended with a click tracker", ^{
                        NSURL *expectedRedirectURL = [NSURL URLWithString:@"http://ads.mopub.com/m/clickThroughTracker?a=1&r=http%3A%2F%2Fyay.com"];

                        [view webView:view.webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeLinkClicked] should equal(NO);
                        destinationDisplayAgent should have_received(@selector(displayDestinationForURL:)).with(expectedRedirectURL);
                    });
                });

                context(@"when the navigation type is Other", ^{
                    context(@"when the URL has the 'click detection' URL prefix", ^{
                        beforeEach(^{
                            URL = [NSURL URLWithString:@"http://publisher.com/foo"];
                        });

                        it(@"should ask an ad destination display agent to handle the URL, prepended with a click tracker", ^{
                            NSURL *expectedRedirectURL = [NSURL URLWithString:@"http://ads.mopub.com/m/clickThroughTracker?a=1&r=http%3A%2F%2Fpublisher.com%2Ffoo"];

                            [view webView:view.webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);
                            destinationDisplayAgent should have_received(@selector(displayDestinationForURL:)).with(expectedRedirectURL);
                        });
                    });

                    context(@"otherwise", ^{
                        it(@"should tell the webview to load the URL", ^{
                            URL = [NSURL URLWithString:@"http://not-publisher.com/foo"];

                            [view webView:view.webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(YES);
                            destinationDisplayAgent should_not have_received(@selector(displayDestinationForURL:));
                        });
                    });
                });

                context(@"when the navigation type is something else", ^{
                    it(@"should tell the webview to load the URL", ^{
                        [view webView:view.webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeReload] should equal(YES);
                        destinationDisplayAgent should_not have_received(@selector(displayDestinationForURL:));
                    });
                });

                context(@"when the click tracker is missing", ^{
                    beforeEach(^{
                        configuration.clickTrackingURL = nil;
                    });

                    it(@"should ask an ad destination display agent to handle the URL, without prepending the click tracker", ^{
                        [view webView:view.webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeLinkClicked] should equal(NO);
                        destinationDisplayAgent should have_received(@selector(displayDestinationForURL:)).with(URL);
                    });
                });
            });
        });
    });

    describe(@"when orientations change", ^{
        subjectAction(^{ [view loadConfiguration:configuration]; });

        it(@"should tell the web view via javascript", ^{
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
            [view rotateToOrientation:UIInterfaceOrientationLandscapeRight];
            NSString *JS = [view.webView executedJavaScripts][0];
            JS should contain(@"return 90");
            JS = [view.webView executedJavaScripts][1];
            JS should contain(@"width=320");
        });
    });

    describe(@"invoking JS", ^{
        subjectAction(^{ [view loadConfiguration:configuration]; });

        it(@"should support MPAdWebViewEventAdDidAppear", ^{
            [view invokeJavaScriptForEvent:MPAdWebViewEventAdDidAppear];
            [view.webView executedJavaScripts][0] should equal(@"webviewDidAppear();");
        });

        it(@"should support MPAdWebViewEventAdDidDisappear", ^{
            [view invokeJavaScriptForEvent:MPAdWebViewEventAdDidDisappear];
            [view.webView executedJavaScripts][0] should equal(@"webviewDidClose();");
        });
    });
});

SPEC_END
