#import "MPInterstitialAdController.h"
#import "FakeInterstitialCustomEvent.h"
#import "MPAdConfigurationFactory.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(CustomEventInterstitialIntegrationSuite)

describe(@"CustomEventInterstitialIntegrationSuite", ^{
    __block id<MPInterstitialAdControllerDelegate, CedarDouble> delegate;
    __block MPInterstitialAdController *interstitial = nil;
    __block UIViewController *presentingController;
    __block FakeInterstitialCustomEvent *fakeInterstitialCustomEvent;
    __block FakeMPAdServerCommunicator *communicator;
    __block MPAdConfiguration *configuration;

    beforeEach(^{
        // Because MPInterstitialAdController has a shared pool, we need to clear it before each run.
        [MPInterstitialAdController removeSharedInterstitialAdController:interstitial];

        delegate = nice_fake_for(@protocol(MPInterstitialAdControllerDelegate));

        interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"custom_event_interstitial"];
        interstitial.delegate = delegate;

        presentingController = [[[UIViewController alloc] init] autorelease];

        [interstitial loadAd];
        communicator = fakeProvider.lastFakeMPAdServerCommunicator;
        communicator.loadedURL.absoluteString should contain(@"custom_event_interstitial");

        fakeInterstitialCustomEvent = [[[FakeInterstitialCustomEvent alloc] init] autorelease];
        fakeProvider.fakeInterstitialCustomEvent = fakeInterstitialCustomEvent;

        configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"FakeInterstitialCustomEvent"];
        configuration.customEventClassData = @{@"hello": @"world"};
        [communicator receiveConfiguration:configuration];

        // clear out the communicator so we can make future assertions about it
        [communicator reset];

        setUpInterstitialSharedContext(communicator, delegate, interstitial, @"custom_event_interstitial", fakeInterstitialCustomEvent, configuration.failoverURL);
    });

    context(@"while the ad is loading", ^{
        it(@"should tell the custom event to load, passing in the correct custom event info", ^{
            fakeInterstitialCustomEvent.customEventInfo should equal(configuration.customEventClassData);
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
            [fakeInterstitialCustomEvent simulateLoadingAd];
        });

        it(@"should tell the delegate and -ready should return YES", ^{
            verify_fake_received_selectors(delegate, @[@"interstitialDidLoadAd:"]);
            interstitial.ready should equal(YES);
        });

        context(@"and the user tries to load again", ^{ itShouldBehaveLike(anInterstitialThatHasAlreadyLoaded); });

        context(@"and the user shows the ad", ^{
            beforeEach(^{
                [delegate reset_sent_messages];
                fakeProvider.lastFakeMPAnalyticsTracker.trackedImpressionConfigurations.count should equal(0);
                [interstitial showFromViewController:presentingController];
            });

            it(@"should track an impression and tell the custom event to show", ^{
                verify_fake_received_selectors(delegate, @[@"interstitialWillAppear:", @"interstitialDidAppear:"]);
                fakeInterstitialCustomEvent.presentingViewController should equal(presentingController);
                fakeProvider.lastFakeMPAnalyticsTracker.trackedImpressionConfigurations.count should equal(1);
            });

            context(@"when the user interacts with the ad", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];
                });

                xit(@"should track only one click, no matter how many interactions there are, and shouldn't tell the delegate anything", ^{
                    //TODO: track the click impression in the adapter.  this test will fail until we do that.
                    [fakeInterstitialCustomEvent simulateUserInteraction];
                    fakeProvider.lastFakeMPAnalyticsTracker.trackedClickConfigurations.count should equal(1);
                    [fakeInterstitialCustomEvent simulateUserInteraction];
                    fakeProvider.lastFakeMPAnalyticsTracker.trackedClickConfigurations.count should equal(1);

                    delegate.sent_messages should be_empty;
                });
            });

            context(@"and the user tries to load again", ^{ itShouldBehaveLike(anInterstitialThatHasAlreadyLoaded); });

            context(@"and the user tries to show (again)", ^{
                __block UIViewController *newPresentingController;

                beforeEach(^{
                    [delegate reset_sent_messages];
                    [fakeProvider.lastFakeMPAnalyticsTracker reset];

                    newPresentingController = [[[UIViewController alloc] init] autorelease];
                    [interstitial showFromViewController:newPresentingController];
                });

                it(@"should tell the custom event to show and send the delegate messages again", ^{
                    // XXX: The "ideal" behavior here is to ignore any -show messages after the first one, until the
                    // underlying ad is dismissed. However, given the risk that some third-party or custom event
                    // network could give us a silent failure when presenting (and therefore never dismiss), it might
                    // be best just to allow multiple calls to go through.

                    fakeInterstitialCustomEvent.presentingViewController should equal(newPresentingController);
                    verify_fake_received_selectors(delegate, @[@"interstitialWillAppear:", @"interstitialDidAppear:"]);
                    fakeProvider.lastFakeMPAnalyticsTracker.trackedImpressionConfigurations.count should equal(0);
                });
            });

            context(@"when the ad is dismissed", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];
                    [fakeInterstitialCustomEvent simulateUserDismissingAd];
                });

                it(@"should tell the delegate and should no longer be ready", ^{
                    verify_fake_received_selectors(delegate, @[@"interstitialWillDisappear:", @"interstitialDidDisappear:"]);
                    interstitial.ready should equal(NO);
                });

                context(@"and the user tries to load again", ^{ itShouldBehaveLike(anInterstitialThatStartsLoadingAnAdUnit); });
                context(@"and the user tries to show the ad", ^{ itShouldBehaveLike(anInterstitialThatPreventsShowing); });
            });
        });
    });

    context(@"when the ad fails to load", ^{
        beforeEach(^{
            [delegate reset_sent_messages];
            [fakeInterstitialCustomEvent simulateFailingToLoad];
        });

        itShouldBehaveLike(anInterstitialThatLoadsTheFailoverURL);
    });
});

SPEC_END
