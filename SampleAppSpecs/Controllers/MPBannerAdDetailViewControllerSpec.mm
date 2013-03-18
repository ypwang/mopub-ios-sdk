#import "MPBannerAdDetailViewController.h"
#import "MPBannerAdInfo.h"
#import "FakeMPAdView.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPBannerAdDetailViewControllerSpec)

describe(@"MPBannerAdDetailViewController", ^{
    __block MPBannerAdDetailViewController *controller;
    __block MPBannerAdInfo *bannerAdInfo;
    __block FakeMPAdView *adView;

    beforeEach(^{
        bannerAdInfo = [MPBannerAdInfo infoWithTitle:@"foo" ID:@"bar"];
        controller = [[[MPBannerAdDetailViewController alloc] initWithBannerAdInfo:bannerAdInfo] autorelease];
        controller.view should_not be_nil;

        adView = fakeProvider.lastFakeAdView;
    });

    it(@"should configure its labels", ^{
        controller.titleLabel.text should equal(@"foo");
        controller.IDLabel.text should equal(@"bar");
    });

    describe(@"its ad view", ^{
        it(@"should have an ad unit ID and delegate set", ^{
            adView.adUnitId should equal(@"bar");
            adView.delegate should equal(controller);
        });

        it(@"should be added to the ad view container", ^{
            controller.adViewContainer.subviews.lastObject should equal(adView);
        });
    });

    describe(@"MPAdViewDelegate methods", ^{
        it(@"should return a view controller for presenting modal views", ^{
            [adView.delegate viewControllerForPresentingModalView] should equal(controller);
        });
    });

    context(@"when its view has appeared", ^{
        beforeEach(^{
            adView.wasLoaded should equal(NO);
            [controller viewDidAppear:NO];
        });

        it(@"should tell the ad view to load", ^{
            adView.wasLoaded should equal(YES);
        });
    });
});

SPEC_END
