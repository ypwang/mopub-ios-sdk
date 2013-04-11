#import "FakeBannerCustomEvent.h"
#import "MPAdView.h"
#import "MPAdConfigurationFactory.h"
using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPAdViewIntegrationSuite)

describe(@"MPAdViewIntegrationSuite", ^{
    __block FakeBannerCustomEvent *event;
    __block MPAdView *banner;
    __block id<CedarDouble, MPAdViewDelegate> delegate;
    __block FakeMPAdServerCommunicator *communicator;
    __block MPAdConfiguration *configuration;
    __block UIViewController *presentingController;
    __block FakeBannerCustomEvent *onscreenEvent;
    __block FakeMPTimer *refreshTimer;
    __block UIInterfaceOrientation currentOrientation;

    sharedExamplesFor(@"a banner that ignores loads", ^(NSDictionary *sharedContext) {
        it(@"should ignore load", ^{
            [communicator resetLoadedURL];
            [banner loadAd];

            fakeProvider.lastFakeMPAdServerCommunicator.loadedURL should be_nil;
        });
    });

    sharedExamplesFor(@"a banner that starts loading immediately", ^(NSDictionary *sharedContext) {
        it(@"should allow the ad to load", ^{
            [communicator resetLoadedURL];
            [banner loadAd];

            fakeProvider.lastFakeMPAdServerCommunicator.loadedURL.absoluteString should contain(@"custom_event");
        });
    });

    sharedExamplesFor(@"a banner that immediately refreshes", ^(NSDictionary *sharedContext) {
        it(@"should allow forcibly refreshing", ^{
            [delegate reset_sent_messages];
            [communicator resetLoadedURL];
            [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification
                                                                object:[UIApplication sharedApplication]];

            fakeProvider.lastFakeMPAdServerCommunicator.loadedURL.absoluteString should contain(@"custom_event");
        });
    });

    sharedExamplesFor(@"a banner that cancels the loading ad when forced to refresh", ^(NSDictionary *sharedContext) {
        it(@"should not inform the delegate, or display the ad, if the 'canceled' adapter successfully loads", ^{
            [delegate reset_sent_messages];
            [communicator resetLoadedURL];
            [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification
                                                                object:[UIApplication sharedApplication]];

            [event simulateLoadingAd];
            delegate.sent_messages should be_empty;
            banner.subviews.lastObject should_not equal(event.view);
        });
    });

    sharedExamplesFor(@"a banner that continues to listen to the onscreen ad when forced to refresh", ^(NSDictionary *sharedContext) {
        it(@"should not 'cancel' the onscreen adapter", ^{
            [delegate reset_sent_messages];
            [communicator resetLoadedURL];
            [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification
                                                                object:[UIApplication sharedApplication]];

            [onscreenEvent simulateUserTap];
            banner.subviews.lastObject should equal(onscreenEvent.view);
            verify_fake_received_selectors(delegate, @[@"willPresentModalViewForAd:"]);
        });
    });

    sharedExamplesFor(@"a banner that loads the failover URL", ^(NSDictionary *sharedContext) {
        it(@"should request the failover URL", ^{
            communicator.loadedURL.absoluteString should equal(@"http://ads.mopub.com/m/failURL");
        });

        it(@"should not tell the delegate anything", ^{
            delegate.sent_messages should be_empty;
        });

        context(@"when the user tries to load again", ^{itShouldBehaveLike(@"a banner that ignores loads");});
        context(@"when the user backgrounds or forcibly refreshes the ad", ^{itShouldBehaveLike(@"a banner that immediately refreshes");});

        context(@"if the failover URL returns clear", ^{
            __block MPAdConfiguration *newConfiguration;
            __block FakeMPTimer *refreshTimer;

            beforeEach(^{
                [delegate reset_sent_messages];

                newConfiguration = [MPAdConfigurationFactory defaultBannerConfigurationWithNetworkType:@"clear"];
                [communicator receiveConfiguration:newConfiguration];
                [communicator resetLoadedURL];

                refreshTimer = [fakeProvider lastFakeMPTimerWithSelector:@selector(refreshTimerDidFire)];
            });

            it(@"should tell the delegate that it failed", ^{
                verify_fake_received_selectors(delegate, @[@"adViewDidFailToLoadAd:"]);
            });

            it(@"should schedule a (new) refresh timer with the configuration's refresh interval", ^{
                refreshTimer.initialTimeInterval should equal(newConfiguration.refreshInterval);
                refreshTimer.isScheduled should equal(YES);
            });

            context(@"when the user tries to load again", ^{itShouldBehaveLike(@"a banner that starts loading immediately");});
            context(@"when the user backgrounds or forcibly refreshes the ad", ^{itShouldBehaveLike(@"a banner that immediately refreshes");});
        });
    });

    sharedExamplesFor(@"a banner that displays the latest custom event's view", ^(NSDictionary *sharedContext) {
        it(@"should put the ad view on screen", ^{
            banner.subviews should equal(@[event.view]);
        });

        it(@"should return the correct ad content size", ^{
            banner.adContentViewSize should equal(event.view.frame.size);
        });

        it(@"should track an impression", ^{
            fakeProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations.count should equal(1);
            fakeProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations.lastObject should equal(configuration);
        });

        it(@"should start the refresh timer", ^{
            FakeMPTimer *refreshTimer = [fakeProvider lastFakeMPTimerWithSelector:@selector(refreshTimerDidFire)];
            refreshTimer.isScheduled should equal(YES);
            refreshTimer.isValid should equal(YES);
            refreshTimer.isPaused should equal(NO);
        });

        it(@"should set the orientation on the ad", ^{
            event.orientation should equal(currentOrientation);
        });
    });

////////////////////////////////////////////////////////////////////////

    context(@"when loading an ad for the first time", ^{
        beforeEach(^{
            currentOrientation = UIInterfaceOrientationLandscapeRight;
            onscreenEvent = nil;
            event = [[[FakeBannerCustomEvent alloc] initWithFrame:CGRectMake(0, 0, 20, 30)] autorelease];
            fakeProvider.fakeBannerCustomEvent = event;

            presentingController = [[[UIViewController alloc] init] autorelease];
            delegate = nice_fake_for(@protocol(MPAdViewDelegate));
            delegate stub_method(@selector(viewControllerForPresentingModalView)).and_return(presentingController);

            banner = [[[MPAdView alloc] initWithAdUnitId:@"custom_event" size:MOPUB_BANNER_SIZE] autorelease];
            banner.delegate = delegate;
            [banner rotateToOrientation:currentOrientation];

            [banner loadAd];

            communicator = fakeProvider.lastFakeMPAdServerCommunicator;
            communicator.loadedURL.absoluteString should contain(@"custom_event");
        });

        context(@"when the user tries to load again", ^{itShouldBehaveLike(@"a banner that ignores loads");});
        context(@"when the user backgrounds or forcibly refreshes the ad", ^{itShouldBehaveLike(@"a banner that immediately refreshes");});

        context(@"when the communicator fails", ^{
            beforeEach(^{
                [communicator failWithError:[NSErrorFactory genericError]];
                refreshTimer = [fakeProvider lastFakeMPTimerWithSelector:@selector(refreshTimerDidFire)];
            });

            it(@"should schedule the default refresh timer", ^{
                refreshTimer.initialTimeInterval should equal(60);
                refreshTimer.isScheduled should equal(YES);
            });

            context(@"when the user tries to load again", ^{itShouldBehaveLike(@"a banner that starts loading immediately");});
            context(@"when the user backgrounds or forcibly refreshes the ad", ^{itShouldBehaveLike(@"a banner that immediately refreshes");});

            context(@"when the refresh timer fires", ^{
                it(@"should make a new ad request", ^{
                    [communicator resetLoadedURL];
                    [refreshTimer trigger];
                    communicator.loadedURL.absoluteString should contain(@"custom_event");
                });
            });
        });

        context(@"when the communicator succeeds", ^{
            beforeEach(^{
                configuration = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"FakeBannerCustomEvent"];
                configuration.customEventClassData = @{@"why": @"not"};
                configuration.refreshInterval = 12;
                [communicator receiveConfiguration:configuration];
            });

            it(@"should tell the custom event to load the ad, with the appropriate size", ^{
                event.size should equal(MOPUB_BANNER_SIZE);
                event.customEventInfo should equal(configuration.customEventClassData);
            });

            context(@"when told to rotate", ^{
                beforeEach(^{
                    [banner rotateToOrientation:UIInterfaceOrientationPortrait];
                });

                it(@"should tell the custom event", ^{
                    event.orientation should equal(UIInterfaceOrientationPortrait);
                });
            });

            context(@"when the user tries to load again", ^{itShouldBehaveLike(@"a banner that ignores loads");});
            context(@"when the user backgrounds or forcibly refreshes the ad", ^{
                itShouldBehaveLike(@"a banner that immediately refreshes");
                itShouldBehaveLike(@"a banner that cancels the loading ad when forced to refresh");
            });

            context(@"when the ad fails to load", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];
                    [communicator resetLoadedURL];
                    [event simulateFailingToLoad];
                });

                itShouldBehaveLike(@"a banner that loads the failover URL");
            });

            context(@"when the ad loads successfully", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];
                    [event simulateLoadingAd];
                    onscreenEvent = event;
                    refreshTimer = [fakeProvider lastFakeMPTimerWithSelector:@selector(refreshTimerDidFire)];
                });

                it(@"should tell the ad view delegate", ^{
                    verify_fake_received_selectors(delegate, @[@"adViewDidLoadAd:"]);
                });

                it(@"should schedule a refresh timer with the configuration's interval", ^{
                    refreshTimer.timeInterval should equal(12);
                    refreshTimer.isScheduled should equal(YES);
                });

                itShouldBehaveLike(@"a banner that displays the latest custom event's view");

                context(@"when the user tries to load again", ^{itShouldBehaveLike(@"a banner that starts loading immediately");});
                context(@"when the user backgrounds or forcibly refreshes the ad", ^{
                    itShouldBehaveLike(@"a banner that immediately refreshes");
                    itShouldBehaveLike(@"a banner that continues to listen to the onscreen ad when forced to refresh");
                });

                context(@"when the user taps the ad", ^{
                    beforeEach(^{
                        [delegate reset_sent_messages];
                        [event simulateUserTap];
                    });

                    it(@"should tell the delegate and track a click", ^{
                        verify_fake_received_selectors(delegate, @[@"willPresentModalViewForAd:"]);
                        fakeProvider.sharedFakeMPAnalyticsTracker.trackedClickConfigurations.count should equal(1);
                        fakeProvider.sharedFakeMPAnalyticsTracker.trackedClickConfigurations.lastObject should equal(configuration);
                    });

                    it(@"(the presented modal) should be presented with the correct view controller", ^{
                        event.presentingViewController should equal(presentingController);
                    });

                    context(@"when the user finishes playing with the ad", ^{
                        beforeEach(^{
                            [delegate reset_sent_messages];
                            [event simulateUserEndingInteraction];
                        });

                        it(@"should tell the delegate", ^{
                            verify_fake_received_selectors(delegate, @[@"didDismissModalViewForAd:"]);
                        });
                    });

                    context(@"when the user leaves the application from the ad", ^{
                        beforeEach(^{
                            [delegate reset_sent_messages];
                            [event simulateUserLeavingApplication];
                        });

                        it(@"should tell the delegate", ^{
                            verify_fake_received_selectors(delegate, @[@"willLeaveApplicationFromAd:"]);
                        });
                    });
                });

                describe(@"the refresh timer", ^{
                    context(@"when the refresh timer fires", ^{
                        beforeEach(^{
                            [communicator resetLoadedURL];
                            [delegate reset_sent_messages];
                            [refreshTimer trigger];
                            refreshTimer.isValid should equal(NO);
                        });

                        it(@"should start loading the next ad", ^{
                            communicator.loadedURL.absoluteString should contain(@"custom_event");
                        });

                        it(@"should keep informing the delegate about events of the onscreen adapter while loading", ^{
                            [event simulateUserTap];
                            verify_fake_received_selectors(delegate, @[@"willPresentModalViewForAd:"]);
                        });
                    });

                    context(@"when the user tries to load again", ^{
                        beforeEach(^{
                            [communicator resetLoadedURL];
                            [banner loadAd];
                        });

                        context(@"and then the refresh timer fires", ^{
                            it(@"should not restart the load (because it is already loading)", ^{
                                [communicator resetLoadedURL];
                                [refreshTimer trigger];
                                communicator.loadedURL should be_nil;
                            });
                        });
                    });
                });
            });
        });
    });

    context(@"when an ad is already loaded, and the refresh timer fires", ^{
        beforeEach(^{
            currentOrientation = UIInterfaceOrientationLandscapeLeft;
            onscreenEvent = nil;
            event = [[[FakeBannerCustomEvent alloc] initWithFrame:CGRectMake(0, 0, 20, 30)] autorelease];
            fakeProvider.fakeBannerCustomEvent = event;

            presentingController = [[[UIViewController alloc] init] autorelease];
            delegate = nice_fake_for(@protocol(MPAdViewDelegate));
            delegate stub_method(@selector(viewControllerForPresentingModalView)).and_return(presentingController);

            banner = [[[MPAdView alloc] initWithAdUnitId:@"custom_event" size:MOPUB_BANNER_SIZE] autorelease];
            banner.delegate = delegate;
            [banner rotateToOrientation:UIInterfaceOrientationLandscapeLeft];

            [banner loadAd];

            communicator = fakeProvider.lastFakeMPAdServerCommunicator;
            communicator.loadedURL.absoluteString should contain(@"custom_event");

            MPAdConfiguration *firstConfiguration = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"FakeBannerCustomEvent"];
            firstConfiguration.customEventClassData = @{@"why": @"not"};
            firstConfiguration.refreshInterval = 12;
            [communicator receiveConfiguration:firstConfiguration];

            [event simulateLoadingAd];
            onscreenEvent = event;

            [communicator resetLoadedURL];
            [[fakeProvider lastFakeMPTimerWithSelector:@selector(refreshTimerDidFire)] trigger];

            configuration = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"FakeBannerCustomEvent"];
            configuration.customEventClassData = @{@"fruit": @"loops"};
            configuration.refreshInterval = 17; // different refresh interval

            event = [[[FakeBannerCustomEvent alloc] initWithFrame:CGRectMake(0, 0, 40, 50)] autorelease];
            fakeProvider.fakeBannerCustomEvent = event;

            communicator.loadedURL.absoluteString should contain(@"custom_event");
            [communicator receiveConfiguration:configuration];
        });

        context(@"when the user loads", ^{itShouldBehaveLike(@"a banner that ignores loads");});
        context(@"when the user backgrounds or forcibly refreshes the ad", ^{
            itShouldBehaveLike(@"a banner that immediately refreshes");
            itShouldBehaveLike(@"a banner that cancels the loading ad when forced to refresh");
            itShouldBehaveLike(@"a banner that continues to listen to the onscreen ad when forced to refresh");
        });

        it(@"should tell the new custom event to load", ^{
            event.size should equal(MOPUB_BANNER_SIZE);
            event.customEventInfo should equal(@{@"fruit": @"loops"});
        });

        context(@"when told to rotate", ^{
            beforeEach(^{
                [banner rotateToOrientation:UIInterfaceOrientationLandscapeRight];
            });

            it(@"should tell both the onscreen and the offscreen custom event", ^{
                event.orientation should equal(UIInterfaceOrientationLandscapeRight);
                onscreenEvent.orientation should equal(UIInterfaceOrientationLandscapeRight);
            });
        });

        context(@"when the user has not interacted with the onscreen ad", ^{
            context(@"when the offscreen ad fails to load", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];
                    [communicator resetLoadedURL];
                    [event simulateFailingToLoad];
                });

                itShouldBehaveLike(@"a banner that loads the failover URL");
            });

            context(@"when the offscreen ad loads succesfully", ^{
                beforeEach(^{
                    [fakeProvider.sharedFakeMPAnalyticsTracker reset];
                    [delegate reset_sent_messages];
                    [event simulateLoadingAd];
                    onscreenEvent = event;
                });

                itShouldBehaveLike(@"a banner that displays the latest custom event's view");

                it(@"should tell the ad view delegate", ^{
                    verify_fake_received_selectors(delegate, @[@"adViewDidLoadAd:"]);
                });
            });
        });

        context(@"when the user has tapped the onscreen ad", ^{
            beforeEach(^{
                [onscreenEvent simulateUserTap];
            });

            context(@"when the offscreen ad fails to load", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];
                    [communicator resetLoadedURL];
                    [event simulateFailingToLoad];
                });

                itShouldBehaveLike(@"a banner that loads the failover URL");
            });

            context(@"when the offscreen ad loads successfully", ^{
                beforeEach(^{
                    [fakeProvider.sharedFakeMPAnalyticsTracker reset];
                    [delegate reset_sent_messages];
                    [event simulateLoadingAd];
                });

                it(@"should not display the offscreen ad just yet", ^{
                    delegate.sent_messages should be_empty;
                    banner.subviews should equal(@[onscreenEvent.view]);
                    banner.adContentViewSize should equal(onscreenEvent.view.frame.size);
                    fakeProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations should be_empty;
                });

                context(@"when the user tries to load again", ^{itShouldBehaveLike(@"a banner that ignores loads");});
                context(@"when the user backgrounds or forcibly refreshes the ad", ^{
                    itShouldBehaveLike(@"a banner that immediately refreshes");
                    itShouldBehaveLike(@"a banner that cancels the loading ad when forced to refresh");
                    itShouldBehaveLike(@"a banner that continues to listen to the onscreen ad when forced to refresh");
                });

                context(@"when the user has dismissed the onscreen ad's modal content", ^{
                    beforeEach(^{
                        [onscreenEvent simulateUserEndingInteraction];
                        onscreenEvent = event;
                    });

                    itShouldBehaveLike(@"a banner that displays the latest custom event's view");

                    it(@"should tell the ad view delegate", ^{
                        verify_fake_received_selectors(delegate, @[@"didDismissModalViewForAd:", @"adViewDidLoadAd:"]);
                    });

                    context(@"when the user tries to load again", ^{itShouldBehaveLike(@"a banner that starts loading immediately");});
                    context(@"when the user backgrounds or forcibly refreshes the ad", ^{
                        itShouldBehaveLike(@"a banner that immediately refreshes");
                        itShouldBehaveLike(@"a banner that continues to listen to the onscreen ad when forced to refresh");
                    });
                });

                context(@"when the user leaves the application via the onscreen ad", ^{
                    beforeEach(^{
                        [onscreenEvent simulateUserLeavingApplication];
                        [communicator resetLoadedURL];
                        [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification
                                                                            object:[UIApplication sharedApplication]];
                    });

                    it(@"should tell the ad view delegate", ^{
                        verify_fake_received_selectors(delegate, @[@"willLeaveApplicationFromAd:"]);
                    });

                    it(@"should start off a new communication request", ^{
                        communicator.loadedURL.absoluteString should contain(@"custom_event");
                    });

                    context(@"when the user dismisses the ad, before the new ad arrives", ^{
                        beforeEach(^{
                            [delegate reset_sent_messages];
                            [onscreenEvent simulateUserEndingInteraction];
                        });

                        it(@"should not replace the ad view or tell the delegate", ^{
                            banner.subviews should equal(@[onscreenEvent.view]);
                            verify_fake_received_selectors(delegate, @[@"didDismissModalViewForAd:"]);
                        });
                    });


                    context(@"when the associated ad finally arrives", ^{
                        beforeEach(^{
                            event = [[[FakeBannerCustomEvent alloc] initWithFrame:CGRectMake(0, 0, 100, 30)] autorelease];
                            fakeProvider.fakeBannerCustomEvent = event;
                            [communicator receiveConfiguration:configuration];
                            [delegate reset_sent_messages];
                            [event simulateLoadingAd];
                        });

                        it(@"should not display the ad", ^{
                            banner.subviews should equal(@[onscreenEvent.view]);
                            delegate.sent_messages should be_empty;
                        });

                        context(@"when the user finally dismisses the ad", ^{
                            beforeEach(^{
                                [onscreenEvent simulateUserEndingInteraction];
                            });

                            itShouldBehaveLike(@"a banner that displays the latest custom event's view");

                            it(@"should tell the ad view delegate", ^{
                                verify_fake_received_selectors(delegate, @[@"didDismissModalViewForAd:", @"adViewDidLoadAd:"]);
                            });
                        });
                    });
                });
            });
        });
    });

    context(@"when told to ignore auto refresh", ^{
        beforeEach(^{
            event = [[[FakeBannerCustomEvent alloc] initWithFrame:CGRectMake(0, 0, 20, 30)] autorelease];
            fakeProvider.fakeBannerCustomEvent = event;

            delegate = nice_fake_for(@protocol(MPAdViewDelegate));

            banner = [[[MPAdView alloc] initWithAdUnitId:@"custom_event" size:MOPUB_BANNER_SIZE] autorelease];
            banner.delegate = delegate;
            banner.ignoresAutorefresh = YES;

            [banner loadAd];

            communicator = fakeProvider.lastFakeMPAdServerCommunicator;
            communicator.loadedURL.absoluteString should contain(@"custom_event");
        });

        context(@"when the communicator fails", ^{
            beforeEach(^{
                [communicator failWithError:nil];
            });

            it(@"should nonetheless schedule a refresh timer (with the default time interval)", ^{
                FakeMPTimer *timer = [fakeProvider lastFakeMPTimerWithSelector:@selector(refreshTimerDidFire)];
                timer.isScheduled should equal(YES);
                timer.initialTimeInterval should equal(60);
            });
        });

        context(@"when the waterfall eventually fails to load", ^{
            beforeEach(^{
                configuration = [MPAdConfigurationFactory defaultBannerConfigurationWithNetworkType:kAdTypeClear];
                configuration.refreshInterval = 36;
                [communicator receiveConfiguration:configuration];
            });

            it(@"should nonetheless schedule a refresh timer (with the configuration's time interval)", ^{
                FakeMPTimer *timer = [fakeProvider lastFakeMPTimerWithSelector:@selector(refreshTimerDidFire)];
                timer.isScheduled should equal(YES);
                timer.initialTimeInterval should equal(36);
            });
        });

        context(@"when the ad succesfully loads", ^{
            beforeEach(^{
                configuration = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"FakeBannerCustomEvent"];
                configuration.refreshInterval = 36;
                [communicator receiveConfiguration:configuration];

                [event simulateLoadingAd];
            });

            it(@"should not schedule a refresh timer", ^{
                FakeMPTimer *timer = [fakeProvider lastFakeMPTimerWithSelector:@selector(refreshTimerDidFire)];
                timer should be_nil;
            });
        });
    });
});

SPEC_END
