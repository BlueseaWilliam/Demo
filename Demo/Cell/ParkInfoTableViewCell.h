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

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *areaLabel;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) IBOutlet UILabel *addressLabel;

@end

NS_ASSUME_NONNULL_END
