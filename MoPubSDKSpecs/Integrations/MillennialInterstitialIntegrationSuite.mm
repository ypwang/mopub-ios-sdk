#import "MPInterstitialAdController.h"
#import "MPAdConfigurationFactory.h"
#import "FakeMPAdServerCommunicator.h"
#import "FakeMMInterstitialAdView.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MillennialInterstitialIntegrationSuite)

describe(@"MillennialInterstitialIntegrationSuite", ^{
    __block id<MPInterstitialAdControllerDelegate, CedarDouble> delegate;
    __block MPInterstitialAdController *interstitial = nil;
    __block UIViewController *presentingController;
    __block FakeMMInterstitialAdView *fakeMMInterstitialAdView;
    __block FakeMPAdServerCommunicator *communicator;
    __block MPAdConfiguration *configuration;

    beforeEach(^{
        // Because MPInterstitialAdController has a shared pool, we need to clear it before each run.
        [MPInterstitialAdController removeSharedInterstitialAdController:interstitial];

        delegate = nice_fake_for(@protocol(MPInterstitialAdControllerDelegate));

        interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"MM_interstitial"];
        interstitial.delegate = delegate;

        presentingController = [[[UIViewController alloc] init] autorelease];

        // request an Ad
        [interstitial loadAd];
        communicator = fakeProvider.lastFakeMPAdServerCommunicator;
        communicator.loadedURL.absoluteString should contain(@"MM_interstitial");

        // prepare the fake and tell the injector about it
        fakeMMInterstitialAdView = [[[FakeMMInterstitialAdView alloc] init] autorelease];
        fakeProvider.fakeMMAdViewInterstitial = fakeMMInterstitialAdView;

        setUpInterstitialSharedContext(communicator, delegate, interstitial, @"MM_interstitial", fakeMMInterstitialAdView, [NSURL URLWithString:@"http://ads.mopub.com/m/failURL"]);
    });

    context(@"when the Millennial apid is valid", ^{
        beforeEach(^{
            [delegate reset_sent_messages];

            NSDictionary *headers = @{
                                      kAdTypeHeaderKey: @"millennial_full",
                                      kNativeSDKParametersHeaderKey: @"{\"adUnitID\":\"millenialist\"}"
                                      };
            configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithHeaders:headers
                                                                                       HTMLString:nil];
        });

        context(@"when an ad is already cached", ^{
            beforeEach(^{
                [delegate reset_sent_messages];

                fakeMMInterstitialAdView.hasCachedAd = YES;

                [communicator receiveConfiguration:configuration];
                [communicator reset];
            });

            it(@"should tell the delegate that it has loaded an ad, and it should be ready", ^{
                verify_fake_received_selectors(delegate, @[@"interstitialDidLoadAd:"]);
                interstitial.ready should equal(YES);
            });

            context(@"if the user tries to load again", ^{ itShouldBehaveLike(anInterstitialThatHasAlreadyLoaded); });
            //"Show" tests are below
        });

        context(@"when an ad is not already cached", ^{
            beforeEach(^{
                [delegate reset_sent_messages];

                fakeMMInterstitialAdView.hasCachedAd = NO;

                [communicator receiveConfiguration:configuration];
                [communicator reset];
            });

            it(@"should tell the ad to fetch, not tell the delegate anything, and should not be ready", ^{
                fakeMMInterstitialAdView.askedToFetchAd should equal(YES);
                [delegate sent_messages] should be_empty;
                interstitial.ready should equal(NO);
            });

            context(@"if the user tries to load again", ^{ itShouldBehaveLike(anInterstitialThatPreventsLoading); });
            context(@"if the user tries to show the ad", ^{ itShouldBehaveLike(anInterstitialThatPreventsShowing); });

            context(@"when the ad is cached successfully", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];

                    [fakeMMInterstitialAdView simulateSuccessfullyCachingAd];
                });

                it(@"should tell the delegate that it has loaded an ad, and it should be ready", ^{
                    verify_fake_received_selectors(delegate, @[@"interstitialDidLoadAd:"]);
                    interstitial.ready should equal(YES);
                });

                context(@"if the user tries to load again", ^{ itShouldBehaveLike(anInterstitialThatHasAlreadyLoaded); });
                //"Show" tests are below
            });

            context(@"when the ad fails to cache", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];

                    [fakeMMInterstitialAdView simulateFailingToCacheAd];
                });

                itShouldBehaveLike(anInterstitialThatLoadsTheFailoverURL);
            });
        });

        context(@"when the Millennial ad claims to be cached and the interstitial is ready", ^{
            beforeEach(^{
                [delegate reset_sent_messages];
                fakeMMInterstitialAdView.hasCachedAd = YES;
                [communicator receiveConfiguration:configuration];
                [communicator reset];

                verify_fake_received_selectors(delegate, @[@"interstitialDidLoadAd:"]);
                interstitial.ready should equal(YES);
            });

            context(@"and it is actually cached", ^{
                context(@"and the user tries to load the ad", ^{ itShouldBehaveLike(anInterstitialThatHasAlreadyLoaded); });
                context(@"when the user tries to show the ad", ^{
                    beforeEach(^{
                        [delegate reset_sent_messages];
                        [fakeProvider.lastFakeMPAnalyticsTracker reset];
                    });

                    context(@"and displays successfully", ^{
                        beforeEach(^{
                            fakeMMInterstitialAdView.willSuccessfullyDisplayAd = YES;
                            [interstitial showFromViewController:presentingController];
                        });

                        it(@"should display the ad, tell the delegate that the ad will and did appear, and it should track an impression", ^{
                            fakeMMInterstitialAdView.presentingViewController should equal(presentingController);
                            verify_fake_received_selectors(delegate, @[@"interstitialWillAppear:", @"interstitialDidAppear:"]);
                            fakeProvider.lastFakeMPAnalyticsTracker.trackedImpressionConfigurations.count should equal(1);
                            interstitial.ready should equal(YES);
                        });

                        context(@"and the user tries to load the ad", ^{ itShouldBehaveLike(anInterstitialThatHasAlreadyLoaded); });
                        context(@"and the user tries to show the ad (again)", ^{
                            beforeEach(^{
                                [delegate reset_sent_messages];
                                [fakeProvider.lastFakeMPAnalyticsTracker reset];
                                fakeMMInterstitialAdView.presentingViewController = nil;
                                [interstitial showFromViewController:presentingController];
                            });

                            it(@"should display the ad again (sadly), without tracking a new impression", ^{
                                fakeMMInterstitialAdView.presentingViewController should equal(presentingController);
                                verify_fake_received_selectors(delegate, @[@"interstitialWillAppear:", @"interstitialDidAppear:"]);
                                fakeProvider.lastFakeMPAnalyticsTracker.trackedImpressionConfigurations should be_empty;
                                interstitial.ready should equal(YES);
                            });
                        });

                        context(@"and the user dismisses the ad", ^{
                            beforeEach(^{
                                [delegate reset_sent_messages];
                                [fakeMMInterstitialAdView simulateDismissingAd];
                            });

                            it(@"should tell the delegate, and not be ready", ^{
                                verify_fake_received_selectors(delegate, @[@"interstitialWillDisappear:", @"interstitialDidDisappear:", @"interstitialDidExpire:"]);
                                interstitial.ready should equal(NO);
                            });

                            context(@"and the user tries to load the ad", ^{ itShouldBehaveLike(anInterstitialThatStartsLoadingAnAdUnit); });
                            context(@"and the user tries to show the ad (again)", ^{ itShouldBehaveLike(anInterstitialThatPreventsShowing); });
                        });
                    });

                    context(@"and fails to display", ^{
                        beforeEach(^{
                            fakeMMInterstitialAdView.willSuccessfullyDisplayAd = NO;
                            [interstitial showFromViewController:presentingController];
                        });

                        it(@"should expire the ad, not track an impression, and should not be ready", ^{
                            verify_fake_received_selectors(delegate, @[@"interstitialDidExpire:"]);
                            interstitial.ready should equal(NO);
                            fakeProvider.lastFakeMPAnalyticsTracker.trackedImpressionConfigurations should be_empty;
                        });

                        context(@"and the user tries to load the ad", ^{ itShouldBehaveLike(anInterstitialThatStartsLoadingAnAdUnit); });
                        context(@"and the user tries to show the ad (again)", ^{ itShouldBehaveLike(anInterstitialThatPreventsShowing); });
                    });
                });
            });

            context(@"MILLENNIAL SAD PATH: but it actually is not cached", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];
                    fakeMMInterstitialAdView.hasCachedAd = NO; //mwahaha
                });

                it(@"should think it's still ready! (sad...)", ^{
                    interstitial.ready should equal(YES);
                });

                context(@"and the user tries to load the ad", ^{ itShouldBehaveLike(anInterstitialThatHasAlreadyLoaded); });
                context(@"and the user tries to show the ad", ^{
                    beforeEach(^{
                        [delegate reset_sent_messages];
                        [interstitial showFromViewController:presentingController];
                    });

                    it(@"should not show the ad, should tell the delegate the ad has expired, should not be ready and should not track an impression", ^{
                        fakeMMInterstitialAdView.presentingViewController should be_nil;
                        verify_fake_received_selectors(delegate, @[@"interstitialDidExpire:"]);
                        interstitial.ready should equal(NO);
                        fakeProvider.lastFakeMPAnalyticsTracker.trackedImpressionConfigurations should be_empty;
                    });

                    context(@"and the user tries to load the ad", ^{ itShouldBehaveLike(anInterstitialThatStartsLoadingAnAdUnit); });
                    context(@"and the user tries to show the ad again", ^{ itShouldBehaveLike(anInterstitialThatPreventsShowing); });
                });
            });
        });
    });

    context(@"when the Millennial apid is not valid", ^{
        beforeEach(^{
            [delegate reset_sent_messages];

            NSDictionary *headers = @{
                                      kAdTypeHeaderKey: @"millennial_full"
                                      };
            configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithHeaders:headers
                                                                                       HTMLString:nil];

            [communicator receiveConfiguration:configuration];
        });

        itShouldBehaveLike(anInterstitialThatLoadsTheFailoverURL);
    });
});

SPEC_END
