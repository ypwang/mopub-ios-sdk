#import "FakeBannerCustomEvent.h"
#import "MPAdView.h"
#import "MPAdConfigurationFactory.h"
using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(CustomEventBannerIntegrationSuiteSpec)

describe(@"CustomEventBannerIntegrationSuite", ^{
    __block FakeBannerCustomEvent *event;
    __block MPAdView *banner;
    __block id<CedarDouble, MPAdViewDelegate> delegate;
    __block FakeMPAdServerCommunicator *communicator;
    __block MPAdConfiguration *configuration;
    __block UIViewController *presentingController;
    __block FakeMPTimer *refreshTimer;
    __block FakeBannerCustomEvent *onscreenEvent;
    
    sharedExamplesFor(@"a banner that ignores loads", ^(NSDictionary *sharedContext) {
        __block BOOL hasRefreshTimer;
        __block BOOL initialRefreshTimerState;
        
        beforeEach(^{
            hasRefreshTimer = !!refreshTimer;
            initialRefreshTimerState = refreshTimer.isValid;
            [communicator reset];
            [banner loadAd];
        });
        
        it(@"should ignore load", ^{
            fakeProvider.lastFakeMPAdServerCommunicator.loadedURL should be_nil;
        });
        
        it(@"should leave the refresh timer alone (if present)", ^{
            if (hasRefreshTimer) {
                refreshTimer.isValid should equal(initialRefreshTimerState);
            }
        });
    });
    
    sharedExamplesFor(@"a banner that starts loading immediately", ^(NSDictionary *sharedContext) {
        beforeEach(^{
            [communicator reset];
            [banner loadAd];
        });
        
        it(@"should allow the ad to load", ^{
            fakeProvider.lastFakeMPAdServerCommunicator.loadedURL.absoluteString should contain(@"custom_event");
        });
        
        it(@"should invalidate the refresh timer", ^{
            refreshTimer.isValid should equal(NO);
        });
    });

    sharedExamplesFor(@"a banner that immediately refreshes", ^(NSDictionary *sharedContext) {
        beforeEach(^{
            [delegate reset_sent_messages];
            [communicator reset];
        });
        
        context(@"when the user forcibly refreshes", ^{
            beforeEach(^{
                [banner forceRefreshAd];
            });
            
            it(@"should allow forcibly refreshing", ^{
                fakeProvider.lastFakeMPAdServerCommunicator.loadedURL.absoluteString should contain(@"custom_event");
            });
            
            it(@"should invalidate the refresh timer (if present)", ^{
                if (refreshTimer) {
                    refreshTimer.isValid should equal(NO);
                }
            });
        });

        context(@"when the user backgrounds/foregrounds", ^{
            beforeEach(^{
                [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification
                                                                    object:[UIApplication sharedApplication]];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification
                                                                    object:[UIApplication sharedApplication]];
            });
            
            it(@"should allow forcibly refreshing", ^{
                fakeProvider.lastFakeMPAdServerCommunicator.loadedURL.absoluteString should contain(@"custom_event");
            });
            
            it(@"should invalidate the refresh timer", ^{
                if (refreshTimer) {
                    refreshTimer.isValid should equal(NO);
                }
            });
        });
    });
    
    sharedExamplesFor(@"a banner that cancels the loading ad when forced to refresh", ^(NSDictionary *sharedContext) {
        beforeEach(^{
            [delegate reset_sent_messages];
            [communicator reset];
        });
        
        context(@"when the user forcibly refreshes", ^{
            beforeEach(^{
                [banner forceRefreshAd];
            });
            
            it(@"should not inform the delegate, or display the ad, if the 'canceled' adapter successfully loads", ^{
                [event simulateLoadingAd];
                delegate.sent_messages should be_empty;
                if (onscreenEvent) {
                    banner.subviews should equal(@[onscreenEvent.view]);
                } else {
                    banner.subviews should be_empty;
                }
            });
        });
        
        context(@"when the user backgrounds/foregrounds", ^{
            beforeEach(^{
                [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification
                                                                    object:[UIApplication sharedApplication]];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification
                                                                    object:[UIApplication sharedApplication]];
            });
            
            it(@"should not inform the delegate, or display the ad, if the 'canceled' adapter successfully loads", ^{
                [event simulateLoadingAd];
                delegate.sent_messages should be_empty;
                if (onscreenEvent) {
                    banner.subviews should equal(@[onscreenEvent.view]);
                } else {
                    banner.subviews should be_empty;
                }
            });
        });
    });
    
    sharedExamplesFor(@"a banner that continues to listen to the onscreen ad when forced to refresh", ^(NSDictionary *sharedContext) {
        beforeEach(^{
            [delegate reset_sent_messages];
            [communicator reset];
        });
        
        context(@"when the user forcibly refreshes", ^{
            beforeEach(^{
                [banner forceRefreshAd];
            });
            
            it(@"should not 'cancel' the onscreen adapter", ^{
                [onscreenEvent simulateUserTap];
                verify_fake_received_selectors(delegate, @[@"willPresentModalViewForAd:"]);
            });
        });
        
        context(@"when the user backgrounds/foregrounds", ^{
            beforeEach(^{
                [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification
                                                                    object:[UIApplication sharedApplication]];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification
                                                                    object:[UIApplication sharedApplication]];
            });
            
            it(@"should not 'cancel' the onscreen adapter", ^{
                [onscreenEvent simulateUserTap];
                verify_fake_received_selectors(delegate, @[@"willPresentModalViewForAd:"]);
            });
        });
    });
    
    sharedExamplesFor(@"a banner that loads the failover URL", ^(NSDictionary *sharedContext) {
        it(@"should request the failover URL", ^{
            communicator.loadedURL.absoluteString should equal(@"http://ads.mopub.com/m/failURL");
        });
        
        it(@"should not tell the delegate anything", ^{
            delegate.sent_messages should be_empty;
        });
        
        it(@"should not schedule the refresh timer", ^{
            refreshTimer.isScheduled should equal(NO);
            refreshTimer.isValid should equal(NO);
        });
        
        context(@"when the user tries to load", ^{itShouldBehaveLike(@"a banner that ignores loads");});
        context(@"when the user backgrounds or forcibly refreshes the ad", ^{itShouldBehaveLike(@"a banner that immediately refreshes");});
        
        context(@"if the failover URL returns clear", ^{
            __block MPAdConfiguration *newConfiguration;
            
            beforeEach(^{
                [delegate reset_sent_messages];
                
                newConfiguration = [MPAdConfigurationFactory defaultBannerConfigurationWithNetworkType:@"clear"];
                [communicator receiveConfiguration:newConfiguration];
                [communicator reset];
                
                [fakeProvider lastFakeMPTimerWithSelector:@selector(forceRefreshAd)] should_not be_same_instance_as(refreshTimer);
                refreshTimer.isValid should equal(NO);
                refreshTimer = [fakeProvider lastFakeMPTimerWithSelector:@selector(forceRefreshAd)];
            });
            
            it(@"should tell the delegate that it failed", ^{
                verify_fake_received_selectors(delegate, @[@"adViewDidFailToLoadAd:"]);
            });
            
            it(@"should schedule a (new) refresh timer with the configuration's refresh interval", ^{
                refreshTimer.initialTimeInterval should equal(newConfiguration.refreshInterval);
                refreshTimer.isScheduled should equal(YES);
            });
            
            context(@"when the user tries to load", ^{itShouldBehaveLike(@"a banner that starts loading immediately");});
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
            fakeProvider.lastFakeMPAnalyticsTracker.trackedImpressionConfigurations.count should equal(1);
            fakeProvider.lastFakeMPAnalyticsTracker.trackedImpressionConfigurations.lastObject should equal(configuration);
        });
        
        it(@"should start the refresh timer", ^{
            refreshTimer.isScheduled should equal(YES);
            refreshTimer.isValid should equal(YES);
            refreshTimer.isPaused should equal(NO);
        });
    });

////////////////////////////////////////////////////////////////////////
    
    context(@"when loading an ad for the first time", ^{
        beforeEach(^{
            refreshTimer = nil;
            onscreenEvent = nil;
            event = [[[FakeBannerCustomEvent alloc] initWithFrame:CGRectMake(0, 0, 20, 30)] autorelease];
            fakeProvider.fakeBannerCustomEvent = event;
            
            presentingController = [[[UIViewController alloc] init] autorelease];
            delegate = nice_fake_for(@protocol(MPAdViewDelegate));
            delegate stub_method(@selector(viewControllerForPresentingModalView)).and_return(presentingController);
            
            banner = [[[MPAdView alloc] initWithAdUnitId:@"custom_event" size:MOPUB_BANNER_SIZE] autorelease];
            banner.delegate = delegate;

            [banner loadAd];
            
            communicator = fakeProvider.lastFakeMPAdServerCommunicator;
            communicator.loadedURL.absoluteString should contain(@"custom_event");
        });

        context(@"when the user tries to load", ^{itShouldBehaveLike(@"a banner that ignores loads");});
        context(@"when the user backgrounds or forcibly refreshes the ad", ^{itShouldBehaveLike(@"a banner that immediately refreshes");});
        
        context(@"when the communicator fails", ^{
            beforeEach(^{
                [communicator failWithError:[NSErrorFactory genericError]];
                refreshTimer = [fakeProvider lastFakeMPTimerWithSelector:@selector(forceRefreshAd)];
            });
            
            it(@"should schedule the default refresh timer", ^{
                refreshTimer.initialTimeInterval should equal(60);
                refreshTimer.isScheduled should equal(YES);
            });
            
            context(@"when the user tries to load", ^{itShouldBehaveLike(@"a banner that starts loading immediately");});
            context(@"when the user backgrounds or forcibly refreshes the ad", ^{itShouldBehaveLike(@"a banner that immediately refreshes");});
            
            context(@"when the refresh timer fires", ^{
                it(@"should make a new ad request", ^{
                    [communicator reset];
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
                refreshTimer = [fakeProvider lastFakeMPTimerWithSelector:@selector(forceRefreshAd)];
            });
            
            it(@"should tell the custom event to load the ad, with the appropriate size", ^{
                event.size should equal(MOPUB_BANNER_SIZE);
                event.customEventInfo should equal(configuration.customEventClassData);
            });
            
            it(@"should have a refresh timer with the configuration's interval, but not schedule it yet", ^{
                refreshTimer.timeInterval should equal(12);
                refreshTimer.isScheduled should equal(NO);
            });
            
            context(@"when told to rotate", ^{
                xit(@"should tell the custom event", ^{
                    
                });
            });
            
            context(@"when the user tries to load", ^{itShouldBehaveLike(@"a banner that ignores loads");});
            context(@"when the user backgrounds or forcibly refreshes the ad", ^{
                itShouldBehaveLike(@"a banner that immediately refreshes");
                itShouldBehaveLike(@"a banner that cancels the loading ad when forced to refresh");
            });
            
            context(@"when the ad fails to load", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];
                    [communicator reset];
                    [event simulateFailingToLoad];
                });
                
                itShouldBehaveLike(@"a banner that loads the failover URL");                
            });
            
            context(@"when the ad loads successfully", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];
                    [event simulateLoadingAd];
                    onscreenEvent = event;
                });
                                
                it(@"should tell the ad view delegate", ^{
                    verify_fake_received_selectors(delegate, @[@"adViewDidLoadAd:"]);
                });

                itShouldBehaveLike(@"a banner that displays the latest custom event's view");
                
                context(@"while the refresh timer is running", ^{
                    context(@"when the user tries to load", ^{itShouldBehaveLike(@"a banner that starts loading immediately");});
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
                            fakeProvider.lastFakeMPAnalyticsTracker.trackedClickConfigurations.count should equal(1);
                            fakeProvider.lastFakeMPAnalyticsTracker.trackedClickConfigurations.lastObject should equal(configuration);
                        });
                        
                        it(@"(the presented modal) should be presented with the correct view controller", ^{
                            event.presentingViewController should equal(presentingController);
                        });
                        
                        it(@"should pause its refresh timer", ^{
                            refreshTimer.isScheduled should equal(YES);
                            refreshTimer.isValid should equal(YES);
                            refreshTimer.isPaused should equal(YES);
                        });
                        
                        context(@"when the user tries to load", ^{itShouldBehaveLike(@"a banner that starts loading immediately");});                        
                        context(@"when the user backgrounds or forcibly refreshes the ad", ^{
                            itShouldBehaveLike(@"a banner that immediately refreshes");
                            itShouldBehaveLike(@"a banner that continues to listen to the onscreen ad when forced to refresh");
                        });
                        
                        context(@"when the user finishes playing with the ad", ^{
                            beforeEach(^{
                                [delegate reset_sent_messages];
                                [event simulateUserEndingInteraction];
                            });
                            
                            it(@"should tell the delegate", ^{
                                verify_fake_received_selectors(delegate, @[@"didDismissModalViewForAd:"]);
                            });
                            
                            it(@"should resume the refresh timer", ^{
                                refreshTimer.isScheduled should equal(YES);
                                refreshTimer.isValid should equal(YES);
                                refreshTimer.isPaused should equal(NO);
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
                            
                            it(@"should not resume the refresh timer", ^{
                                refreshTimer.isScheduled should equal(YES);
                                refreshTimer.isValid should equal(YES);
                                refreshTimer.isPaused should equal(YES);
                            });                            
                        });
                    });
                    
                    context(@"when the refresh timer fires", ^{
                        beforeEach(^{
                            [communicator reset];
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
                });
            });
        });
    });
    
    context(@"when an ad is already loaded, and the refresh timer fires", ^{
        beforeEach(^{
            refreshTimer = nil;
            onscreenEvent = nil;
            event = [[[FakeBannerCustomEvent alloc] initWithFrame:CGRectMake(0, 0, 20, 30)] autorelease];
            fakeProvider.fakeBannerCustomEvent = event;
            
            presentingController = [[[UIViewController alloc] init] autorelease];
            delegate = nice_fake_for(@protocol(MPAdViewDelegate));
            delegate stub_method(@selector(viewControllerForPresentingModalView)).and_return(presentingController);
            
            banner = [[[MPAdView alloc] initWithAdUnitId:@"custom_event" size:MOPUB_BANNER_SIZE] autorelease];
            banner.delegate = delegate;
            
            [banner loadAd];
            
            communicator = fakeProvider.lastFakeMPAdServerCommunicator;
            communicator.loadedURL.absoluteString should contain(@"custom_event");
            
            MPAdConfiguration *firstConfiguration = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"FakeBannerCustomEvent"];
            firstConfiguration.customEventClassData = @{@"why": @"not"};
            firstConfiguration.refreshInterval = 12;
            [communicator receiveConfiguration:firstConfiguration];
            
            [event simulateLoadingAd];
            onscreenEvent = event;
            
            [communicator reset];
            [[fakeProvider lastFakeMPTimerWithSelector:@selector(forceRefreshAd)] trigger];
            
            configuration = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"FakeBannerCustomEvent"];
            configuration.customEventClassData = @{@"fruit": @"loops"};
            configuration.refreshInterval = 17; // different refresh interval
            
            event = [[[FakeBannerCustomEvent alloc] initWithFrame:CGRectMake(0, 0, 40, 50)] autorelease];
            fakeProvider.fakeBannerCustomEvent = event;
        });
        
        it(@"should tell the communicator to request a new ad", ^{
            communicator.loadedURL.absoluteString should contain(@"custom_event");
        });
        
        context(@"when the user loads", ^{itShouldBehaveLike(@"a banner that ignores loads");});
        context(@"when the user backgrounds or forcibly refreshes the ad", ^{
            itShouldBehaveLike(@"a banner that immediately refreshes");
            itShouldBehaveLike(@"a banner that continues to listen to the onscreen ad when forced to refresh");
        });
        
        context(@"when the user taps the onscreen ad", ^{
            beforeEach(^{
                [onscreenEvent simulateUserTap];
            });
            
            context(@"when the communicator succeeds", ^{
                beforeEach(^{
                    [communicator receiveConfiguration:configuration];
                });
                
                it(@"should tell the new custom event to load", ^{
                    event.size should equal(MOPUB_BANNER_SIZE);
                    event.customEventInfo should equal(@{@"fruit": @"loops"});
                });
            });
        });
        
        context(@"when the communicator fails", ^{
            beforeEach(^{
                [communicator failWithError:[NSErrorFactory genericError]];
                refreshTimer = [fakeProvider lastFakeMPTimerWithSelector:@selector(forceRefreshAd)];
            });
            
            it(@"should schedule the default refresh timer", ^{
                refreshTimer.initialTimeInterval should equal(60);
                refreshTimer.isScheduled should equal(YES);
            });
            
            context(@"when the user tries to load", ^{itShouldBehaveLike(@"a banner that starts loading immediately");});
            context(@"when the user backgrounds or forcibly refreshes the ad", ^{itShouldBehaveLike(@"a banner that immediately refreshes");});
            
            context(@"when the refresh timer fires", ^{
                it(@"should make a new ad request", ^{
                    [communicator reset];
                    [refreshTimer trigger];
                    communicator.loadedURL.absoluteString should contain(@"custom_event");
                });
            });
        });
        
        context(@"when the communicator succeeds", ^{
            beforeEach(^{
                [communicator receiveConfiguration:configuration];
                refreshTimer = [fakeProvider lastFakeMPTimerWithSelector:@selector(forceRefreshAd)];
            });
            
            it(@"should tell the new custom event to load", ^{
                event.size should equal(MOPUB_BANNER_SIZE);
                event.customEventInfo should equal(@{@"fruit": @"loops"});
            });
            
            it(@"should have a refresh timer, but not schedule it", ^{
                refreshTimer.isScheduled should equal(NO);
                refreshTimer.initialTimeInterval should equal(17);
            });
            
            context(@"when told to rotate", ^{
                xit(@"should tell the custom event", ^{
                    
                });
            });
            
            context(@"when the user tries to load", ^{itShouldBehaveLike(@"a banner that ignores loads");});
            context(@"when the user backgrounds or forcibly refreshes the ad", ^{
                itShouldBehaveLike(@"a banner that immediately refreshes");
                itShouldBehaveLike(@"a banner that cancels the loading ad when forced to refresh");
                itShouldBehaveLike(@"a banner that continues to listen to the onscreen ad when forced to refresh");
            });
            
            context(@"when the user has not interacted with the onscreen ad", ^{
                context(@"when the offscreen ad fails to load", ^{
                    beforeEach(^{
                        [delegate reset_sent_messages];
                        [communicator reset];
                        [event simulateFailingToLoad];
                    });
                    
                    itShouldBehaveLike(@"a banner that loads the failover URL");
                });
                
                context(@"when the offscreen ad loads succesfully", ^{
                    beforeEach(^{
                        [fakeProvider.lastFakeMPAnalyticsTracker reset];
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
                        [communicator reset];
                        [event simulateFailingToLoad];
                    });
                    
                    itShouldBehaveLike(@"a banner that loads the failover URL");
                });
                
                context(@"when the offscreen ad loads successfully", ^{
                    beforeEach(^{
                        [fakeProvider.lastFakeMPAnalyticsTracker reset];
                        [delegate reset_sent_messages];
                        [event simulateLoadingAd];
                    });
                    
                    it(@"should not display the offscreen ad just yet", ^{
                        delegate.sent_messages should be_empty;
                        banner.subviews should equal(@[onscreenEvent.view]);
                        banner.adContentViewSize should equal(onscreenEvent.view.frame.size);
                        fakeProvider.lastFakeMPAnalyticsTracker.trackedImpressionConfigurations should be_empty;
                        refreshTimer.isScheduled should equal(NO);
                    });
                    
                    context(@"when the user tries to load", ^{itShouldBehaveLike(@"a banner that ignores loads");});
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
                        
                        context(@"when the user tries to load", ^{itShouldBehaveLike(@"a banner that starts loading immediately");});
                        context(@"when the user backgrounds or forcibly refreshes the ad", ^{
                            itShouldBehaveLike(@"a banner that immediately refreshes");
                            itShouldBehaveLike(@"a banner that continues to listen to the onscreen ad when forced to refresh");
                        });
                    });
                    
                    context(@"when the user leaves the application via the onscreen ad", ^{
                        beforeEach(^{
                            [onscreenEvent simulateUserLeavingApplication];
                        });
                        
                        it(@"should tell the ad view delegate", ^{
                            verify_fake_received_selectors(delegate, @[@"willLeaveApplicationFromAd:"]);
                        });
                        
                        context(@"when the user leaves then returns to the application", ^{
                            beforeEach(^{
                                [communicator reset];
                                [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification
                                                                                    object:[UIApplication sharedApplication]];
                                
                                [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification
                                                                                    object:[UIApplication sharedApplication]];
                            });
                            
                            it(@"should start off a new communication request", ^{
                                communicator.loadedURL.absoluteString should contain(@"custom_event");
                            });
                            
                            context(@"when the associated ad finally arrives", ^{
                                beforeEach(^{
                                    event = [[[FakeBannerCustomEvent alloc] initWithFrame:CGRectMake(0, 0, 100, 30)] autorelease];
                                    fakeProvider.fakeBannerCustomEvent = event;
                                    [communicator receiveConfiguration:configuration];
                                    refreshTimer = [fakeProvider lastFakeMPTimerWithSelector:@selector(forceRefreshAd)];
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
        });
    });
    
///////////////////////////////////////////////////////////////////////////////////////////////
//
//    context(@"when loading an ad with auto-refresh turned off", ^{
//        //SHARED: AN AD LOAD THAT DOES NOT REFRESH {
//            it(@"should tell the custom event to load the ad, with the appropriate size", ^{
//
//            });
//
//            context(@"when the ad loads successfully", ^{
//                it(@"should tell the ad view delegate", ^{
//
//                });
//
//                it(@"should put the ad view on screen", ^{
//
//                });
//
//                it(@"should track an impression", ^{
//
//                });
//
//                it(@"should cancel the timeout timer", ^{
//
//                });
//
//                it(@"should *NOT* start the refresh timer", ^{
//
//                });
//            });
//
//            context(@"when the ad fails to load", ^{
//                //SHARED: THE FAILOVER DANCE WITH THE DEFAULT TIMEOUT
//            });
//        //}
//
//        context(@"when the application foregrounds", ^{
//            it(@"should not refresh the ad", ^{
//
//            });
//        });
//    });
//
//    context(@"when loading an ad that has no refresh timeout configured", ^{
//        //SHARED: AN AD LOAD THAT DOES NOT REFRESH
//    });
});

SPEC_END
