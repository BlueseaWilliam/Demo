//
//  ParkInfoViewController.h
//  Demo
//
//  Created by William on 2018/10/31.
//  Copyright © 2018年 William. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParkInfoViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITextField *areaField;
@property (nonatomic, strong) IBOutlet UITextField *keywordField;
@property (nonatomic, strong) IBOutlet UITableView *listView;

@end

