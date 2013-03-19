#import "MPInterstitialAdDetailViewController.h"
#import "MPAdInfo.h"
#import "FakeMPInterstitialAdController.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPInterstitialAdDetailViewControllerSpec)

describe(@"MPInterstitialAdDetailViewController", ^{
    __block MPInterstitialAdDetailViewController *controller;
    __block MPAdInfo *interstitialAdInfo;
    __block FakeMPInterstitialAdController *interstitial;

    beforeEach(^{
        interstitialAdInfo = [MPAdInfo infoWithTitle:@"foo" ID:@"bar" type:MPAdInfoInterstitial];
        controller = [[[MPInterstitialAdDetailViewController alloc] initWithAdInfo:interstitialAdInfo] autorelease];
        controller.view should_not be_nil;

        interstitial = fakeProvider.lastFakeInterstitialAdController;
    });

    it(@"should configure its labels and buttons", ^{
        controller.titleLabel.text should equal(@"foo");
        controller.IDLabel.text should equal(@"bar");
        controller.showButton.hidden should equal(YES);
        controller.spinner.isAnimating should equal(NO);
    });

    describe(@"its interstitial", ^{
        it(@"should have an ad unit ID and delegate set", ^{
            interstitial.adUnitId should equal(@"bar");
            interstitial.delegate should equal(controller);
        });
    });

    context(@"when the load button is tapped", ^{
        beforeEach(^{
            [controller.loadButton tap];
        });

        it(@"should disable the load button", ^{
            controller.loadButton.enabled should equal(NO);
        });

        it(@"should tell the ad view to load", ^{
            interstitial.wasLoaded should equal(YES);
        });

        it(@"should have a spinner and hide the show button", ^{
            controller.spinner.isAnimating should equal(YES);
            controller.showButton.hidden should equal(YES);
        });

        context(@"when the interstitial arrives", ^{
            beforeEach(^{
                [interstitial.delegate interstitialDidLoadAd:interstitial];
            });

            it(@"should hide the spinner and un-hide the show button", ^{
                controller.spinner.isAnimating should equal(NO);
                controller.showButton.hidden should equal(NO);
            });

            it(@"should re-enable the load button", ^{
                controller.loadButton.enabled should equal(YES);
            });

            context(@"when the user taps show", ^{
                beforeEach(^{
                    [controller.showButton tap];
                });

                it(@"should present the interstitial", ^{
                    interstitial.presenter should equal(controller);
                });
            });
        });
    });
});

SPEC_END
