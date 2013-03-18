#import "MPBannerAdInfo.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPBannerAdInfoSpec)

describe(@"MPBannerAdInfo", ^{
    __block MPBannerAdInfo *info;

    it(@"should have a convenience method for creating info objects", ^{
        info = [MPBannerAdInfo infoWithTitle:@"whoop" ID:@"hey"];
        info.title should equal(@"whoop");
        info.ID should equal(@"hey");
    });
});

SPEC_END
