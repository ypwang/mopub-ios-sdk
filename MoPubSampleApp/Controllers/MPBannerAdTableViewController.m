//
//  MPBannerAdTableViewController.m
//  MoPubSampleApp
//
//  Created by pivotal on 3/18/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPBannerAdTableViewController.h"
#import "MPBannerAdInfo.h"
#import "MPBannerAdDetailViewController.h"

@interface MPBannerAdTableViewController ()

@property (nonatomic, strong) NSArray *bannerAds;

@end

@implementation MPBannerAdTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithBannerAds:(NSArray *)bannerAds
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.bannerAds = bannerAds;
    }
    return self;
}

- (MPBannerAdInfo *)infoAtIndexPath:(NSIndexPath *)indexPath
{
    return self.bannerAds[indexPath.row];
}

- (void)viewDidLoad
{
    self.title = @"Banners";
    [self.tableView reloadData];
    [super viewDidLoad];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.bannerAds count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [[self infoAtIndexPath:indexPath] title];
    cell.detailTextLabel.text = [[self infoAtIndexPath:indexPath] ID];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MPBannerAdDetailViewController *detailController = [[MPBannerAdDetailViewController alloc] initWithBannerAdInfo:[self infoAtIndexPath:indexPath]];
    [self.navigationController pushViewController:detailController animated:YES];
}

@end
