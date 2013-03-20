#import "MPHTMLInterstitialAdapter.h"
#import "MPAdConfigurationFactory.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPHTMLInterstitialAdapterSpec)

describe(@"MPHTMLInterstitialAdapter", ^{
    __block id<CedarDouble, MPBaseInterstitialAdapterDelegate> delegate;
    __block MPHTMLInterstitialAdapter *adapter;
    __block MPAdConfiguration *configuration;
    __block MPHTMLInterstitialViewController<CedarDouble> *controller;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPBaseInterstitialAdapterDelegate));
        controller = nice_fake_for([MPHTMLInterstitialViewController class]);
        fakeProvider.fakeMPHTMLInterstitialViewController = controller;
        adapter = [[[MPHTMLInterstitialAdapter alloc] initWithDelegate:delegate] autorelease];
        configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithNetworkType:@"html"];
        [adapter _getAdWithConfiguration:configuration];
    });

    context(@"when asked to get an ad for a configuration", ^{
        it(@"should tell the interstitial view controller to load the configuration", ^{
            controller should have_received(@selector(loadConfiguration:)).with(configuration);
        });
    });

    context(@"when asked to show the interstitial", ^{
        __block UIViewController *presentingController;

        beforeEach(^{
            presentingController = [[[UIViewController alloc] init] autorelease];
            [adapter showInterstitialFromViewController:presentingController];
        });

        it(@"should tell the interstitial view controller to show the interstitial", ^{
            controller should have_received(@selector(presentInterstitialFromViewController:)).with(presentingController);
        });
    });

    describe(@"MPHTMLInterstitialViewControllerDelegate methods", ^{
        it(@"should pass these through to its delegate", ^{
            [adapter interstitialDidLoadAd:controller];
            delegate should have_received(@selector(adapterDidFinishLoadingAd:)).with(adapter);

            [adapter interstitialDidFailToLoadAd:controller];
            delegate should have_received(@selector(adapter:didFailToLoadAdWithError:)).with(adapter).and_with(nil);

            [adapter interstitialWillAppear:controller];
            delegate should have_received(@selector(interstitialWillAppearForAdapter:)).with(adapter);

            [adapter interstitialDidAppear:controller];
            delegate should have_received(@selector(interstitialDidAppearForAdapter:)).with(adapter);

            [adapter interstitialWillDisappear:controller];
            delegate should have_received(@selector(interstitialWillDisappearForAdapter:)).with(adapter);

            [adapter interstitialDidDisappear:controller];
            delegate should have_received(@selector(interstitialDidDisappearForAdapter:)).with(adapter);

            [adapter interstitialWillLeaveApplication:controller];
            delegate should have_received(@selector(interstitialWillLeaveApplicationForAdapter:)).with(adapter);

            //Impression and click tracking is handled by JS in the webview.  We should not track it ourselves.
            fakeProvider.lastFakeMPAnalyticsTracker.trackedImpressionConfigurations should be_empty;
            fakeProvider.lastFakeMPAnalyticsTracker.trackedClickConfigurations should be_empty;
        });
    });
});

SPEC_END
