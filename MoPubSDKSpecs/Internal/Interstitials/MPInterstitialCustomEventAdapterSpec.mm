#import "MPInterstitialCustomEventAdapter.h"
#import "MPAdConfigurationFactory.h"
#import "FakeInterstitialCustomEvent.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

//TODO: when MPInterstitialAdController makes it to Specs, replace this with an import
@class MPInterstitialAdController;

@protocol BobTheBuilderProtocol <NSObject>
- (void)buildGuy:(MPInterstitialAdController *)controller;
@end

@protocol VerilyBobTheBuilderProtocol <BobTheBuilderProtocol>
- (void)buildGuy;
@end

SPEC_BEGIN(MPInterstitialCustomEventAdapterSpec)

describe(@"MPInterstitialCustomEventAdapter", ^{
    __block MPInterstitialCustomEventAdapter *adapter;
    __block id<CedarDouble, MPBaseInterstitialAdapterDelegate> delegate;
    __block MPAdConfiguration *configuration;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPBaseInterstitialAdapterDelegate));
        adapter = [[MPInterstitialCustomEventAdapter alloc] initWithDelegate:delegate];
        configuration = [MPAdConfigurationFactory defaultInterstitialConfiguration];
    });

    context(@"when asked to get an ad for a configuration", ^{
        context(@"when the configuration has a custom event class", ^{
            context(@"when the requested custom event class does not exist", ^{
                beforeEach(^{
                    configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"NSMonkeyToastEndocrineParadigmBean"];
                });

                it(@"should tell the delegate that it failed", ^{
                    [adapter getAdWithConfiguration:configuration];
                    delegate should have_received(@selector(adapter:didFailToLoadAdWithError:)).with(adapter).and_with(nil);
                });
            });

            context(@"when the requested custom event class exists", ^{
                beforeEach(^{
                    configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"FakeInterstitialCustomEvent"];
                    configuration.customEventClassData = @{@"Zoology":@"Is for zoologists"};
                });

                it(@"should create a new instance of the class and request the interstitial", ^{
                    [adapter getAdWithConfiguration:configuration];
                    FakeInterstitialCustomEvent *event = [FakeInterstitialCustomEvent lastInterstitialCustomEvent];
                    event.delegate should equal(adapter);
                    event.customEventInfo should equal(configuration.customEventClassData);
                });
            });
        });

        context(@"when the configuration has no custom event class", ^{
            beforeEach(^{
                configuration.customEventClass = nil;
            });

            context(@"when the configuration has a custom event selector", ^{
                beforeEach(^{
                    configuration.customSelectorName = @"buildGuy";
                });

                context(@"when the interstitial delegate implements the zero-argument selector", ^{
                    it(@"should perform the selector on the interstitial delegate", ^{
                        id<CedarDouble, VerilyBobTheBuilderProtocol> bob = nice_fake_for(@protocol(VerilyBobTheBuilderProtocol));
                        delegate stub_method("interstitialDelegate").and_return(bob);
                        [adapter getAdWithConfiguration:configuration];
                        bob should have_received(@selector(buildGuy));
                    });
                });

                context(@"when the interstitial delegate implements the one-argument selector", ^{
                    it(@"should perform the selector on the interstitial delegate", ^{
                        id<CedarDouble, BobTheBuilderProtocol> bob = nice_fake_for(@protocol(BobTheBuilderProtocol));
                        NSObject *controllerProxy = [[[NSObject alloc] init] autorelease];

                        delegate stub_method("interstitialDelegate").and_return(bob);
                        delegate stub_method("interstitialAdController").and_return(controllerProxy);

                        [adapter getAdWithConfiguration:configuration];

                        bob should have_received(@selector(buildGuy:)).with(controllerProxy);
                    });
                });

                context(@"when the interstitial delegate does not implement the selector", ^{
                    it(@"should tell the delegate that it failed", ^{
                        NSObject *cake = [[[NSObject alloc] init] autorelease];

                        delegate stub_method("interstitialDelegate").and_return(cake);
                        [adapter getAdWithConfiguration:configuration];
                        delegate should have_received(@selector(adapter:didFailToLoadAdWithError:)).with(adapter).and_with(nil);
                    });
                });
            });

            context(@"when the configuration also does not have a custom event selector", ^{
                beforeEach(^{
                    configuration.customSelectorName = nil;
                });

                it(@"should tell the delegate that it failed", ^{
                    [adapter getAdWithConfiguration:configuration];
                    delegate should have_received(@selector(adapter:didFailToLoadAdWithError:)).with(adapter).and_with(nil);
                });
            });
        });
    });

    context(@"when asked to show the interstitial", ^{
        __block FakeInterstitialCustomEvent *event;
        __block UIViewController *controller;

        beforeEach(^{
            configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"FakeInterstitialCustomEvent"];
            [adapter getAdWithConfiguration:configuration];
            event = [FakeInterstitialCustomEvent lastInterstitialCustomEvent];
            controller = [[[UIViewController alloc] init] autorelease];
            [adapter showInterstitialFromViewController:controller];
        });

        it(@"should ask the custom event class", ^{
            event.rootViewController should equal(controller);
        });
    });

    describe(@"MPInterstitialCustomEventDelegate methods", ^{
        describe(@"when the custom event loads an ad", ^{
            it(@"should tell its delegate", ^{
                [adapter interstitialCustomEvent:nil didLoadAd:nil];
                delegate should have_received(@selector(adapterDidFinishLoadingAd:)).with(adapter);
            });
        });

        describe(@"when the custom event fails to load an ad", ^{
            it(@"should tell its delegate", ^{
                NSError *error = [[[NSError alloc] init] autorelease];
                [adapter interstitialCustomEvent:nil didFailToLoadAdWithError:error];
                delegate should have_received(@selector(adapter:didFailToLoadAdWithError:)).with(adapter).and_with(error);
            });
        });

        describe(@"when the custom event is about to show an ad", ^{
            it(@"should tell its delegate", ^{
                [adapter interstitialCustomEventWillAppear:nil];
                delegate should have_received(@selector(interstitialWillAppearForAdapter:)).with(adapter);
                delegate should have_received(@selector(interstitialDidAppearForAdapter:)).with(adapter);

                [delegate.sent_messages[0] selector] should equal(@selector(interstitialWillAppearForAdapter:));
                [delegate.sent_messages[1] selector] should equal(@selector(interstitialDidAppearForAdapter:));
            });
        });

        describe(@"when the custom event has dismissed an ad", ^{
            it(@"should tell its delegate", ^{
                [adapter interstitialCustomEventDidDisappear:nil];
                delegate should have_received(@selector(interstitialWillDisappearForAdapter:)).with(adapter);
                delegate should have_received(@selector(interstitialDidDisappearForAdapter:)).with(adapter);

                [delegate.sent_messages[0] selector] should equal(@selector(interstitialWillDisappearForAdapter:));
                [delegate.sent_messages[1] selector] should equal(@selector(interstitialDidDisappearForAdapter:));
            });
        });

        describe(@"when the custom event is about to leave the application", ^{
            it(@"should tell its delegate", ^{
                [adapter interstitialCustomEventWillLeaveApplication:nil];
                delegate should have_received(@selector(interstitialWillLeaveApplicationForAdapter:)).with(adapter);
            });
        });
    });
});

SPEC_END
