//
//  ViewController.h
//  CPM-Week-2-iOS
//
//  Created by Jeremy Fox on 8/12/13.
//  Copyright (c) 2013 rentpath. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *filterControl;
- (IBAction)valueChanged:(UISegmentedControl *)sender;

@end
