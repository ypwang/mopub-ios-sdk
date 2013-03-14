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
        view = [[[MPAdWebView alloc] initWithFrame:CGRectMake(0, 0, 50, 50) delegate:delegate destinationDisplayAgent:destinationDisplayAgent] autorelease];
        configuration = [MPAdConfigurationFactory defaultBannerConfiguration];
    });

    describe(@"on init, setting up the webview", ^{
        xit(@"should allow inline media playback without user action", ^{

        });
    });

    describe(@"when the configuration is loaded", ^{
        describe(@"setting the frame", ^{
            context(@"when the frame sizes are valid", ^{
                xit(@"should set its frame", ^{

                });
            });

            context(@"when the frame sizes are invalid", ^{
                it(@"should not set its frame", ^{

                });
            });
        });

        describe(@"setting scrollability", ^{
            it(@"should set scrolling enabled when the configuration says so", ^{

            });
        });

        describe(@"loading webview data", ^{
            it(@"should load the ad's HTML data into the webview", ^{

            });
        });
    });

    describe(@"handling webview navigation", ^{
        __block NSURL *URL;

        subjectAction(^{ [view loadConfiguration:configuration]; });

        context(@"when isDismissed", ^{
            xit(@"should never load anything", ^{

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
            });
        });
    });

    describe(@"when orientations change", ^{
        xit(@"should tell the web view via javascript", ^{
            /*
             fake out the statusBarOrientation
             call rotateToOrientation:
             verify that the webview received some javascript that looks right-ish
             also verify that webview.frame.size.width got passed in to javascript
             */
        });
    });

    describe(@"invoking JS", ^{
        xit(@"should support MPAdWebViewEventAdDidAppear", ^{

        });

        it(@"should support MPAdWebViewEventAdDidDisappear", ^{

        });
    });
});

SPEC_END
