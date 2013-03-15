#import "MPHTMLInterstitialViewController.h"
#import "MPAdWebView.h"
#import "MPAdConfigurationFactory.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPHTMLInterstitialViewControllerSpec)

fdescribe(@"MPHTMLInterstitialViewController", ^{
    __block MPHTMLInterstitialViewController *controller;
    __block MPAdWebView *backingView;
    __block MPAdConfiguration *configuration;
    __block id<CedarDouble, MPHTMLInterstitialViewControllerDelegate> delegate;
    __block UIViewController *presentingViewController;

    beforeEach(^{
        presentingViewController = [[[UIViewController alloc] init] autorelease];
        configuration = [MPAdConfigurationFactory defaultInterstitialConfiguration];
        delegate = nice_fake_for(@protocol(MPHTMLInterstitialViewControllerDelegate));
        controller = [[[MPHTMLInterstitialViewController alloc] init] autorelease];
        controller.delegate = delegate;
        [controller loadConfiguration:configuration];
        backingView = (MPAdWebView *)controller.view.subviews.lastObject;

        [presentingViewController presentViewController:controller animated:NO completion:nil];
    });

    describe(@"when loading a configuration", ^{
        it(@"should have a black background", ^{
            controller.view.backgroundColor should equal([UIColor blackColor]);
        });

        it(@"should set its backing view", ^{
            backingView should be_instance_of([MPAdWebView class]);
        });

        it(@"should tell the backing view to load the configuration", ^{
            backingView.webView.loadedHTMLString should equal(@"Publisher's Interstitial");
        });
    });

    describe(@"custom method delegate", ^{
        it(@"should be able to set it", ^{
            NSObject *delegate = [[[NSObject alloc] init] autorelease];
            [controller setCustomMethodDelegate:delegate];
            controller.customMethodDelegate should equal(delegate);
            backingView.customMethodDelegate should equal(delegate);
        });
    });

    describe(@"when it will be presented", ^{
        beforeEach(^{
            [controller willPresentInterstitial];
        });

        it(@"should set its backing view's alpha to 0", ^{
            backingView.alpha should equal(0);
        });

        it(@"should tell its delegate interstitialWillAppear:", ^{
            delegate should have_received(@selector(interstitialWillAppear:)).with(controller);
        });

        describe(@"after being presented", ^{
            beforeEach(^{
                [controller didPresentInterstitial];
            });

            it(@"should tell the backing view that it was presented", ^{
                backingView.dismissed should equal(NO);
                backingView.webView.executedJavaScripts[0] should equal(@"webviewDidAppear();");
                backingView.alpha should equal(1);
            });

            it(@"should tell its delegate interstitialDidAppear:", ^{
                delegate should have_received(@selector(interstitialDidAppear:)).with(controller);
            });
        });
    });

    describe(@"when it will be dismissed", ^{
        beforeEach(^{
            [controller willDismissInterstitial];
        });

        it(@"should inform the backing view", ^{
            backingView.dismissed should equal(YES);
        });

        it(@"should tell its delegate interstitialWillDisappear:", ^{
            delegate should have_received(@selector(interstitialWillDisappear:)).with(controller);
        });

        describe(@"after being dismissed", ^{
            beforeEach(^{
                [controller didDismissInterstitial];
            });

            it(@"should tell its delegate interstitialDidDisappear:", ^{
                delegate should have_received(@selector(interstitialDidDisappear:)).with(controller);
            });
        });
    });

    describe(@"MPAdWebViewDelegate methods", ^{
        it(@"should be the presenting controller", ^{
            controller.viewControllerForPresentingModalView should equal(controller);
        });

        it(@"should forward adDidFinishLoadingAd:", ^{
            [controller adDidFinishLoadingAd:backingView];
            delegate should have_received(@selector(interstitialDidLoadAd:)).with(controller);
        });

        it(@"should forward adDidFailToLoadAd:", ^{
            [controller adDidFailToLoadAd:backingView];
            delegate should have_received(@selector(interstitialDidFailToLoadAd:)).with(controller);
        });

        it(@"should forward adActionWillBegin:", ^{
            [controller adActionWillBegin:backingView];
            delegate should have_received(@selector(interstitialWasTapped:)).with(controller);
        });

        it(@"should forward adActionWillLeaveApplication: and dismiss itself", ^{
            [controller adActionWillLeaveApplication:backingView];
            delegate should have_received(@selector(interstitialWillLeaveApplication:)).with(controller);
            presentingViewController.presentedViewController should be_nil;
        });
    });
});

SPEC_END
