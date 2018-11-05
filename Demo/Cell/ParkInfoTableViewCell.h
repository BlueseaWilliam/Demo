//
//  ParkInfoTableViewCell.h
//  Demo
//
//  Created by William on 2018/11/2.
//  Copyright © 2018年 William. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ParkInfoTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *areaLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;

@end

NS_ASSUME_NONNULL_END
