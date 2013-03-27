#import "MPAdConfigurationFactory.h"
#import "MPInterstitialAdController.h"
#import "FakeChartboost.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ChartboostInterstitialIntegrationSuite)

describe(@"ChartboostInterstitialIntegrationSuite", ^{
    __block id<MPInterstitialAdControllerDelegate, CedarDouble> delegate;
    __block MPInterstitialAdController *interstitial = nil;
    __block UIViewController *presentingController;
    __block FakeChartboost *chartboost;
    __block FakeMPAdServerCommunicator *communicator;
    __block MPAdConfiguration *configuration;

    beforeEach(^{
        // Because MPInterstitialAdController has a shared pool, we need to clear it before each run.
        [MPInterstitialAdController removeSharedInterstitialAdController:interstitial];

        delegate = nice_fake_for(@protocol(MPInterstitialAdControllerDelegate));

        interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"chartboost_interstitial"];
        interstitial.delegate = delegate;

        presentingController = [[[UIViewController alloc] init] autorelease];

        // request an Ad
        [interstitial loadAd];
        communicator = fakeProvider.lastFakeMPAdServerCommunicator;
        communicator.loadedURL.absoluteString should contain(@"chartboost_interstitial");

        // prepare the fake and tell the injector about it
        chartboost = [[[FakeChartboost alloc] init] autorelease];
        fakeProvider.fakeChartboost = chartboost;

        // receive the configuration -- this will create an adapter which will use our fake interstitial
        configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"ChartboostInterstitialCustomEvent"];
        configuration.customEventClassData = @{@"appId": @"myAppId",
                                               @"appSignature": @"myAppSignature"};
        [communicator receiveConfiguration:configuration];

        // clear out the communicator so we can make future assertions about it
        [communicator reset];

        setUpInterstitialSharedContext(communicator, delegate, interstitial, @"chartboost_interstitial", chartboost, configuration.failoverURL);
    });

    context(@"while the ad is loading", ^{
        it(@"should configure Chartboost properly, start the session and start caching the interstitial", ^{
            chartboost.appId should equal(@"myAppId");
            chartboost.appSignature should equal(@"myAppSignature");
            chartboost.didStartSession should equal(YES);
            chartboost.didStartCaching should equal(YES);
        });

        it(@"should not tell the delegate anything, nor should it be ready", ^{
            delegate.sent_messages should be_empty;
            interstitial.ready should equal(NO);
        });

        context(@"and the user tries to load again", ^{ itShouldBehaveLike(anInterstitialThatPreventsLoading); });
        context(@"and the user tries to show the ad", ^{ itShouldBehaveLike(anInterstitialThatPreventsShowing); });
    });

    context(@"when the ad successfully loads", ^{
        beforeEach(^{
            [delegate reset_sent_messages];
            [chartboost simulateLoadingAd];
        });

        it(@"should tell the delegate and -ready should return YES", ^{
            verify_fake_received_selectors(delegate, @[@"interstitialDidLoadAd:"]);
            interstitial.ready should equal(YES);
        });

        context(@"and the user tries to load again", ^{ itShouldBehaveLike(anInterstitialThatHasAlreadyLoaded); });

        context(@"and the user shows the ad", ^{
            beforeEach(^{
                chartboost.hasCachedInterstitial = YES;
                [delegate reset_sent_messages];
                fakeProvider.lastFakeMPAnalyticsTracker.trackedImpressionConfigurations.count should equal(0);
                [interstitial showFromViewController:presentingController];
            });

            it(@"should track an impression and tell the custom event to show", ^{
                verify_fake_received_selectors(delegate, @[@"interstitialWillAppear:", @"interstitialDidAppear:"]);
                chartboost.presentingViewController should_not be_nil;
                fakeProvider.lastFakeMPAnalyticsTracker.trackedImpressionConfigurations.count should equal(1);
            });

            context(@"when the user interacts with the ad", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];
                });

                it(@"should track a click and should tell the delegate that it was dismissed", ^{
                    [chartboost simulateUserTap];
                    verify_fake_received_selectors(delegate, @[@"interstitialWillDisappear:", @"interstitialDidDisappear:"]);
                    fakeProvider.lastFakeMPAnalyticsTracker.trackedClickConfigurations.count should equal(1);
                });
            });

            context(@"and the user tries to load again", ^{ itShouldBehaveLike(anInterstitialThatHasAlreadyLoaded); });

            context(@"when the ad is dismissed", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];
                    [chartboost simulateUserDismissingAd];
                });

                it(@"should tell the delegate and should no longer be ready", ^{
                    verify_fake_received_selectors(delegate, @[@"interstitialWillDisappear:", @"interstitialDidDisappear:"]);
                    interstitial.ready should equal(NO);
                });

                context(@"and the user tries to load again", ^{ itShouldBehaveLike(anInterstitialThatStartsLoadingAnAdUnit); });
                context(@"and the user tries to show the ad", ^{ itShouldBehaveLike(anInterstitialThatPreventsShowing); });
            });
        });

        context(@"CHARTBOOST SAD PATH: when the interstitial uncaches *before* it is shown", ^{
            beforeEach(^{
                [delegate reset_sent_messages];
                chartboost.hasCachedInterstitial = NO;
                [interstitial showFromViewController:presentingController];
            });

            it(@"should not track any impressions", ^{
                fakeProvider.lastFakeMPAnalyticsTracker.trackedImpressionConfigurations should be_empty;
            });

            it(@"should not tell Chartboost to show", ^{
                chartboost.presentingViewController should be_nil;
            });

            itShouldBehaveLike(anInterstitialThatLoadsTheFailoverURL);
        });
    });

    context(@"when the ad fails to load", ^{
        beforeEach(^{
            [delegate reset_sent_messages];
            [chartboost simulateFailingToLoad];
        });

        itShouldBehaveLike(anInterstitialThatLoadsTheFailoverURL);
    });
});

SPEC_END
