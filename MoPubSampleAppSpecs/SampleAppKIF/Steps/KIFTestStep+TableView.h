//
//  KIFTestStep+TableView.h
//  MoPubSampleApp
//
//  Created by pivotal on 3/26/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestStep.h"

@interface KIFTestStep (TableView)

+ (id)stepToActuallyTapRowInTableViewWithAccessibilityLabel:(NSString*)tableViewLabel atIndexPath:(NSIndexPath *)indexPath;

@end
