//
//  TableCell.h
//  CPM-Week-2-iOS
//
//  Created by Jeremy Fox on 8/13/13.
//  Copyright (c) 2013 rentpath. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *subTitle;
@property (weak, nonatomic) IBOutlet UILabel *price;

@end
