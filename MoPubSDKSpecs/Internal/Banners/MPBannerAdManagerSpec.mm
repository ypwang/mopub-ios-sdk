#import "MPBannerAdManager.h"
#import "MPBannerAdManagerDelegate.h"
#import "MPAdConfigurationFactory.h"
#import "FakeBannerCustomEvent.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPBannerAdManagerSpec)

describe(@"MPBannerAdManager", ^{
    __block MPBannerAdManager *manager;
    __block id<CedarDouble, MPBannerAdManagerDelegate> delegate;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPBannerAdManagerDelegate));
        manager = [[[MPBannerAdManager alloc] initWithDelegate:delegate] autorelease];
    });

    describe(@"loading requests", ^{
        it(@"should request the correct URL", ^{
            delegate stub_method("adUnitId").and_return(@"panther");
            delegate stub_method("keywords").and_return(@"liono");
            delegate stub_method("location").and_return([[[CLLocation alloc] initWithLatitude:30 longitude:20] autorelease]);
            delegate stub_method("isTesting").and_return(YES);

            [manager loadAd];

            NSString *URL = fakeProvider.lastFakeMPAdServerCommunicator.loadedURL.absoluteString;
            URL should contain(@"id=panther");
            URL should contain(@"q=liono");
            URL should contain(@"ll=30,20");
            URL should contain(@"http://testing.ads.mopub.com");
        });
    });

    describe(@"refresh timer edge cases", ^{
        context(@"when the requested ad unit loads successfully and it has a refresh interval", ^{
            it(@"should schedule the refresh timer with the given refresh interval", ^{
                [manager loadAd];
                FakeBannerCustomEvent *event = [[[FakeBannerCustomEvent alloc] initWithFrame:CGRectZero] autorelease];
                fakeProvider.fakeBannerCustomEvent = event;

                MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"FakeBannerCustomEvent"];
                configuration.refreshInterval = 20;
                [fakeProvider.lastFakeMPAdServerCommunicator receiveConfiguration:configuration];

                [event simulateLoadingAd];
                FakeMPTimer *timer = [fakeProvider lastFakeMPTimerWithSelector:@selector(refreshTimerDidFire)];
                timer.initialTimeInterval should equal(20);
                timer.isScheduled should equal(YES);
            });
        });

        context(@"when the requested ad unit loads successfully and it has no refresh interval", ^{
            it(@"should not schedule the refresh timer", ^{
                [manager loadAd];
                FakeBannerCustomEvent *event = [[[FakeBannerCustomEvent alloc] initWithFrame:CGRectZero] autorelease];
                fakeProvider.fakeBannerCustomEvent = event;

                MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"FakeBannerCustomEvent"];
                configuration.refreshInterval = -1;
                [fakeProvider.lastFakeMPAdServerCommunicator receiveConfiguration:configuration];

                [event simulateLoadingAd];
                [fakeProvider lastFakeMPTimerWithSelector:@selector(refreshTimerDidFire)] should be_nil;
            });
        });

        context(@"when the initial ad server request fails", ^{
            it(@"should schedule the default autorefresh timer", ^{
                [manager loadAd];
                [fakeProvider.lastFakeMPAdServerCommunicator failWithError:nil];
                FakeMPTimer *timer = [fakeProvider lastFakeMPTimerWithSelector:@selector(refreshTimerDidFire)];
                timer.initialTimeInterval should equal(60);
                timer.isScheduled should equal(YES);
            });
        });
    });

    describe(@"when the manager receives a malformed/unsupported configuration", ^{
        context(@"when the configuration has no ad type", ^{
            it(@"should start the refresh timer and try again later", ^{
                [manager loadAd];

                MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultBannerConfiguration];
                configuration.adType = MPAdTypeUnknown;
                [fakeProvider.lastFakeMPAdServerCommunicator receiveConfiguration:configuration];

                FakeMPTimer *timer = [fakeProvider lastFakeMPTimerWithSelector:@selector(refreshTimerDidFire)];
                timer.initialTimeInterval should equal(configuration.refreshInterval);
                timer.isScheduled should equal(YES);
                delegate should have_received(@selector(managerDidFailToLoadAd));
            });
        });

        context(@"when the configuration is an interstitial type", ^{
            it(@"should start the refresh timer and try again later", ^{
                [manager loadAd];

                MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultInterstitialConfiguration];
                configuration.refreshInterval = 30;
                [fakeProvider.lastFakeMPAdServerCommunicator receiveConfiguration:configuration];

                FakeMPTimer *timer = [fakeProvider lastFakeMPTimerWithSelector:@selector(refreshTimerDidFire)];
                timer.initialTimeInterval should equal(configuration.refreshInterval);
                timer.isScheduled should equal(YES);
                delegate should have_received(@selector(managerDidFailToLoadAd));
            });
        });

        context(@"when the configuration is the clear ad type", ^{
            it(@"should start the refresh timer and try again later", ^{
                [manager loadAd];

                MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultBannerConfigurationWithNetworkType:kAdTypeClear];
                [fakeProvider.lastFakeMPAdServerCommunicator receiveConfiguration:configuration];

                FakeMPTimer *timer = [fakeProvider lastFakeMPTimerWithSelector:@selector(refreshTimerDidFire)];
                timer.initialTimeInterval should equal(configuration.refreshInterval);
                timer.isScheduled should equal(YES);
                delegate should have_received(@selector(managerDidFailToLoadAd));
            });
        });

        context(@"when the configuration refers to an adapter that does not exist", ^{
            it(@"should start the failover waterfall", ^{
                [manager loadAd];

                FakeMPAdServerCommunicator *communicator = fakeProvider.lastFakeMPAdServerCommunicator;
                [communicator resetLoadedURL];

                MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"NSFluffyMonkeyPandas"];
                [communicator receiveConfiguration:configuration];

                communicator.loadedURL should equal(configuration.failoverURL);
                delegate should_not have_received(@selector(managerDidFailToLoadAd));
            });
        });
    });
});

SPEC_END
