#import "MPBannerAdTableViewController.h"
#import "MPBannerAdInfo.h"
#import "MPBannerAdDetailViewController.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPBannerAdTableViewControllerSpec)

describe(@"MPBannerAdTableViewController", ^{
    __block UINavigationController *navigationController;
    __block MPBannerAdTableViewController *controller;
    __block UITableView *tableView;
    __block NSArray *bannerAds;

    beforeEach(^{
        bannerAds = @[
                      [MPBannerAdInfo infoWithTitle:@"test1" ID:@"id1"],
                      [MPBannerAdInfo infoWithTitle:@"test2" ID:@"id2"],
                      [MPBannerAdInfo infoWithTitle:@"test3" ID:@"id3"],
                      ];
        controller = [[MPBannerAdTableViewController alloc] initWithBannerAds:bannerAds];
        controller.view should_not be_nil;
        tableView = controller.tableView;

        navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    });

    it(@"should have 1 section", ^{
        tableView.numberOfSections should equal(1);
    });

    it(@"should have 3 rows in its section", ^{
        [tableView numberOfRowsInSection:0] should equal(3);
    });

    it(@"should configure its cells with titles and detail text", ^{
        [[tableView.visibleCells[0] textLabel] text] should equal(@"test1");
        [[tableView.visibleCells[1] textLabel] text] should equal(@"test2");
        [[tableView.visibleCells[2] textLabel] text] should equal(@"test3");

        [[tableView.visibleCells[0] detailTextLabel] text] should equal(@"id1");
        [[tableView.visibleCells[1] detailTextLabel] text] should equal(@"id2");
        [[tableView.visibleCells[2] detailTextLabel] text] should equal(@"id3");
    });

    context(@"when a cell is clicked", ^{
        it(@"should push a detail view controller onto the navigation stack", ^{
            [controller tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            navigationController.topViewController should be_instance_of([MPBannerAdDetailViewController class]);

            MPBannerAdDetailViewController *detailController = (MPBannerAdDetailViewController *)navigationController.topViewController;
            detailController.view should_not be_nil;
            detailController.titleLabel.text should equal(@"test1");
            detailController.IDLabel.text should equal(@"id1");
        });
    });
});

SPEC_END
