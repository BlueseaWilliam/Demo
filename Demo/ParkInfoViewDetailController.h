//
//  ParkInfoViewDetailController.h
//  Demo
//
//  Created by William on 2018/11/2.
//  Copyright © 2018年 William. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class ParkInfo;

NS_ASSUME_NONNULL_BEGIN

@interface ParkInfoViewDetailController : UIViewController

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) IBOutlet UITableView *infoView;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withParkInfo:(ParkInfo *)info;

@end

NS_ASSUME_NONNULL_END
