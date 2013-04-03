#import "MPAdView.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPAdViewSpec)

describe(@"MPAdView", ^{
    __block MPAdView *adView;

    describe(@"loadAd", ^{
        it(@"should tell its manager to begin loading", ^{
            adView = [[[MPAdView alloc] initWithAdUnitId:@"foo" size:MOPUB_BANNER_SIZE] autorelease];
            adView.keywords = @"hi=4";
            adView.location = [[[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(20, 20)
                                                             altitude:10
                                                   horizontalAccuracy:100
                                                     verticalAccuracy:200
                                                            timestamp:[NSDate date]] autorelease];
            adView.testing = YES;
            [adView loadAd];

            NSString *requestedPath = fakeProvider.lastFakeMPAdServerCommunicator.loadedURL.absoluteString;
            requestedPath should contain(@"id=foo");
            requestedPath should contain(@"&q=hi=4");
            requestedPath should contain(@"&ll=20,20");
            requestedPath should contain(@"&lla=100");
            requestedPath should contain(@"http://testing.ads.mopub.com");
        });
    });
});

SPEC_END
