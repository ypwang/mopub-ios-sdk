#import "MPInterstitialAdController.h"
#import "MPAdConfigurationFactory.h"
#import "FakeIMAdInterstitial.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(InMobiInterstitialIntegrationSuite)

describe(@"InMobiInterstitialIntegrationSuite", ^{
    __block id<MPInterstitialAdControllerDelegate, CedarDouble> delegate;
    __block MPInterstitialAdController *interstitial = nil;
    __block UIViewController *presentingController;
    __block FakeIMAdInterstitial *inMobi;
    __block FakeMPAdServerCommunicator *communicator;
    __block MPAdConfiguration *configuration;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPInterstitialAdControllerDelegate));

        interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"inmobi_interstitial"];
        interstitial.delegate = delegate;

        presentingController = [[[UIViewController alloc] init] autorelease];

        // request an Ad
        [interstitial loadAd];
        communicator = fakeProvider.lastFakeMPAdServerCommunicator;
        communicator.loadedURL.absoluteString should contain(@"inmobi_interstitial");

        // prepare the fake and tell the injector about it
        inMobi = [[[FakeIMAdInterstitial alloc] init] autorelease];
        fakeProvider.fakeIMAdInterstitial = inMobi;

        // receive the configuration -- this will create an adapter which will use our fake interstitial
        configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"InMobiInterstitialCustomEvent"];
        [communicator receiveConfiguration:configuration];

        // clear out the communicator so we can make future assertions about it
        [communicator reset];

        setUpInterstitialSharedContext(communicator, delegate, interstitial, @"inmobi_interstitial", inMobi, configuration.failoverURL);
    });

    context(@"while the ad is loading", ^{
        it(@"should configure InMobi properly and start fetching the interstitial", ^{
            inMobi.imAppId should equal(@"YOUR_INMOBI_APP_ID");
            inMobi.request should be_instance_of([IMAdRequest class]);
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
            [inMobi simulateLoadingAd];
        });

        it(@"should tell the delegate and -ready should return YES", ^{
            verify_fake_received_selectors(delegate, @[@"interstitialDidLoadAd:"]);
            interstitial.ready should equal(YES);
        });

        context(@"and the user tries to load again", ^{ itShouldBehaveLike(anInterstitialThatHasAlreadyLoaded); });

        context(@"and the user shows the ad", ^{
            context(@"and the ad will show succesfully", ^{
                beforeEach(^{
                    inMobi.willPresentSuccessfully = YES;
                    [delegate reset_sent_messages];
                    fakeProvider.lastFakeMPAnalyticsTracker.trackedImpressionConfigurations.count should equal(0);
                    [interstitial showFromViewController:presentingController];
                });

                it(@"should track an impression and tell the custom event to show", ^{
                    verify_fake_received_selectors(delegate, @[@"interstitialWillAppear:", @"interstitialDidAppear:"]);
                    inMobi.presentingViewController should equal(presentingController);
                    fakeProvider.lastFakeMPAnalyticsTracker.trackedImpressionConfigurations.count should equal(1);
                });

                context(@"when the user interacts with the ad", ^{
                    beforeEach(^{
                        [delegate reset_sent_messages];
                    });

                    it(@"should track only one click, no matter how many interactions there are, and shouldn't tell the delegate anything", ^{
                        [inMobi simulateUserTap];
                        fakeProvider.lastFakeMPAnalyticsTracker.trackedClickConfigurations.count should equal(1);

                        [inMobi simulateUserTap];
                        fakeProvider.lastFakeMPAnalyticsTracker.trackedClickConfigurations.count should equal(1);

                        delegate.sent_messages.count should equal(0);
                    });
                });

                context(@"and the user tries to load again", ^{ itShouldBehaveLike(anInterstitialThatHasAlreadyLoaded); });

                context(@"when the ad is dismissed", ^{
                    beforeEach(^{
                        [delegate reset_sent_messages];
                        [inMobi simulateUserDismissingAd];
                        verify_fake_received_selectors(delegate, @[@"interstitialWillDisappear:"]);
                        [inMobi simulateInterstitialFinishedDisappearing];
                        verify_fake_received_selectors(delegate, @[@"interstitialDidDisappear:"]);
                    });

                    it(@"should tell the delegate and should no longer be ready", ^{
                        interstitial.ready should equal(NO);
                    });

                    context(@"and the user tries to load again", ^{ itShouldBehaveLike(anInterstitialThatStartsLoadingAnAdUnit); });
                    context(@"and the user tries to show the ad", ^{ itShouldBehaveLike(anInterstitialThatPreventsShowing); });
                });
            });

            context(@"INMOBI SAD PATH: and the ad will fail to show", ^{
                beforeEach(^{
                    inMobi.willPresentSuccessfully = NO;
                    [delegate reset_sent_messages];
                    fakeProvider.lastFakeMPAnalyticsTracker.trackedImpressionConfigurations.count should equal(0);
                    [interstitial showFromViewController:presentingController];
                });

                it(@"should not track any impressions", ^{
                    fakeProvider.lastFakeMPAnalyticsTracker.trackedImpressionConfigurations should be_empty;
                });

                it(@"should not tell InMobi to show", ^{
                    inMobi.presentingViewController should be_nil;
                });

                itShouldBehaveLike(anInterstitialThatLoadsTheFailoverURL);
            });

        });
    });

    context(@"when the ad fails to load", ^{
        beforeEach(^{
            [delegate reset_sent_messages];
            [inMobi simulateFailingToLoad];
        });

        itShouldBehaveLike(anInterstitialThatLoadsTheFailoverURL);
    });
});

SPEC_END
