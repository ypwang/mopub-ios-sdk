#import "InMobiBannerCustomEvent.h"
#import "FakeIMAdView.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(InMobiBannerCustomEventSpec)

describe(@"InMobiBannerCustomEvent", ^{
    __block id<CedarDouble, MPBannerCustomEventDelegate> delegate;
    __block InMobiBannerCustomEvent *event;
    __block UIViewController *viewController;
    __block FakeIMAdView *banner;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPBannerCustomEventDelegate));

        event = [[[InMobiBannerCustomEvent alloc] init] autorelease];
        event.delegate = delegate;

        banner = [[[FakeIMAdView alloc] initWithFrame:CGRectZero] autorelease];
        fakeProvider.fakeIMAdView = banner;

        viewController = [[[UIViewController alloc] init] autorelease];
        delegate stub_method("viewControllerForPresentingModalView").and_return(viewController);
    });

    it(@"should allow automatic metrics tracking", ^{
        event.enableAutomaticImpressionAndClickTracking should equal(YES);
    });

    context(@"when requesting an ad with a valid size", ^{
        it(@"should configure the ad correctly, tell it to fech and not tell the delegate anything just yet", ^{
            [event requestAdWithSize:MOPUB_BANNER_SIZE customEventInfo:nil];
            banner.loadedRequest should_not be_nil;
            banner.imAppId should equal(@"YOUR_INMOBI_APP_ID");
            banner.imAdSize should equal(IM_UNIT_320x50);
            banner.frame should equal(CGRectMake(0, 0, 320, 50));
            banner.rootViewController should equal(viewController);
            banner.refreshInterval should equal(REFRESH_INTERVAL_OFF);
            delegate should_not have_received(@selector(bannerCustomEvent:didLoadAd:));
            delegate should_not have_received(@selector(bannerCustomEvent:didFailToLoadAdWithError:));
        });

        it(@"should support the rectangular size", ^{
            [event requestAdWithSize:MOPUB_MEDIUM_RECT_SIZE customEventInfo:nil];
            banner.frame should equal(CGRectMake(0, 0, 300, 250));
            banner.imAdSize should equal(IM_UNIT_300x250);
        });

        it(@"should support the leaderboard size", ^{
            [event requestAdWithSize:MOPUB_LEADERBOARD_SIZE customEventInfo:nil];
            banner.frame should equal(CGRectMake(0, 0, 728, 90));
            banner.imAdSize should equal(IM_UNIT_728x90);
        });
    });

    context(@"when requesting an ad with an invalid size", ^{
        beforeEach(^{
            [event requestAdWithSize:CGSizeMake(1, 2) customEventInfo:nil];
        });

        it(@"should (immediately) tell the delegate that it failed", ^{
            delegate should have_received(@selector(bannerCustomEvent:didFailToLoadAdWithError:)).with(event).and_with(nil);
        });
    });
});

SPEC_END
