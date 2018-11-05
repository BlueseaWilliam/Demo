//
//  ParkInfoViewDetailController.m
//  Demo
//
//  Created by William on 2018/11/2.
//  Copyright © 2018年 William. All rights reserved.
//

#import "ParkInfoViewDetailController.h"

#import "ParkInfo+CoreDataClass.h"
#import "ParkInfoViewDetailTableViewCell.h"

#import <CoreLocation/CoreLocation.h>
#import <MBProgressHUD/MBProgressHUD.h>


@interface ParkInfoViewDetailController () <UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) ParkInfo *parkInfo;
@property (nonatomic, strong) UIBarButtonItem *routeBtn;
@property (nonatomic, strong) UIBarButtonItem *clearBtn;

@property (nonatomic, strong) MKRoute *parkRoute;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D parkLocation;

@end


@implementation ParkInfoViewDetailController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withParkInfo:(ParkInfo *)info {
    self = [super initWithNibName:@"ParkInfoViewDetailController" bundle:nibBundleOrNil];
    if (self) {
        self.parkInfo = info;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.routeBtn = [[UIBarButtonItem alloc] initWithTitle:@"Route" style:UIBarButtonItemStylePlain target:self action:@selector(routeBtnPress)];
    self.clearBtn = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(cleartnPress)];
    self.navigationItem.rightBarButtonItem = self.routeBtn;

    [self.infoView registerNib:[UINib nibWithNibName:@"ParkInfoViewDetailTableViewCell" bundle:nil] forCellReuseIdentifier:@"parkinfoviewdetailtableviewcellid"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CLLocationCoordinate2D location = [self getWGS84Location];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, 500, 500);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:region];
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = self.parkLocation = location;
    
    [self.mapView setRegion:adjustedRegion animated:YES];
    [self.mapView addAnnotation: annotation];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.parkInfo = nil;
    self.routeBtn = nil;
    self.clearBtn = nil;
    self.parkRoute = nil;
    self.currentLocation = nil;
    self.locationManager = nil;
    
    self.mapView.delegate = nil;
}


#pragma mark - Button Methods
- (void)cleartnPress {
    [self clear];
}

- (void)routeBtnPress {
    if (![CLLocationManager locationServicesEnabled] ) {
        NSLog(@"Please enable location service");
        return;
    }else {
        self.navigationItem.rightBarButtonItem = self.clearBtn;
        
        if (!self.locationManager) {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            self.locationManager.distanceFilter = 10.0f;
        }else {
            [self route];
        }
    }
}


#pragma mark - Private Methods
- (void)clear {
    for(MKRouteStep *step in self.parkRoute.steps) {
        [self.mapView removeOverlay:step.polyline];
    }
    
    [self.locationManager stopUpdatingLocation];
    self.navigationItem.rightBarButtonItem = self.routeBtn;
}

- (void)route {
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, 500, 500);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:region];
    [self.mapView setRegion:adjustedRegion animated:NO];
    [self.mapView setShowsUserLocation:YES];
    self.mapView.delegate = self;
    
    [self drawLine];
}

- (void)drawLine {
    MKPlacemark *startPlace = [[MKPlacemark alloc] initWithCoordinate:self.currentLocation.coordinate addressDictionary:nil];
    MKPlacemark *endPlace = [[MKPlacemark alloc] initWithCoordinate:self.parkLocation addressDictionary:nil];
    MKMapItem *startItem = [[MKMapItem alloc]initWithPlacemark:startPlace];
    MKMapItem *endItem = [[MKMapItem alloc]initWithPlacemark:endPlace];
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc]init];
    request.source = startItem;
    request.destination = endItem;
    
    MKDirections *directions = [[MKDirections alloc]initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (!error) {
            self.parkRoute = response.routes[0];
            for(MKRouteStep *step in self.parkRoute.steps) {
                [self.mapView addOverlay:step.polyline];
            }
        }
    }];
}

- (CLLocationCoordinate2D)getWGS84Location {
    CLLocationCoordinate2D location;
    
    double x = self.parkInfo.tw97x.doubleValue;
    double y = self.parkInfo.tw97y.doubleValue;
    
    double a = 6378137.0;
    double b = 6356752.314245;
    
    double lng0 = 121 * M_PI / 180;
    double k0 = 0.9999;
    double dx = 250000.0;
    double dy = 0.0;
    double e = pow((1 - pow(b, 2) / pow(a, 2)), 0.5);
    x = x - dx;
    y = y - dy;
    double mm = y / k0;
    double mu = mm / (a * (1.0 - pow(e, 2) / 4.0 - 3 * pow(e, 4) / 64.0 - 5 * pow(e, 6) / 256.0));
    double e1 = (1.0 - pow((1.0 - pow(e, 2)), 0.5)) / (1.0 + pow((1.0 - pow(e, 2)), 0.5));
    double j1 = (3 * e1 / 2 - 27 * pow(e1, 3) / 32.0);
    double j2 = (21 * pow(e1, 2) / 16 - 55 * pow(e1, 4) / 32.0);
    double j3 = (151 * pow(e1, 3) / 96.0);
    double j4 = (1097 * pow(e1, 4) / 512.0);
    double fp = mu + j1 * sin(2 * mu) + j2 * sin(4 * mu) + j3 * sin(6 * mu) + j4 * sin(8 * mu);
    double e2 = pow((e * a / b), 2);
    double c1 = pow(e2 * cos(fp), 2);
    double t1 = pow(tan(fp), 2);
    double r1 = a * (1 - pow(e, 2)) / pow((1 - pow(e, 2) * pow(sin(fp), 2)), (3.0 / 2.0));
    double n1 = a / pow((1 - pow(e, 2) * pow(sin(fp), 2)), 0.5);
    
    double dd = x / (n1 * k0);
    double q1 = n1 * tan(fp) / r1;
    double q2 = (pow(dd, 2) / 2.0);
    double q3 = (5 + 3 * t1 + 10 * c1 - 4 * pow(c1, 2) - 9 * e2) * pow(dd, 4) / 24.0;
    double q4 = (61 + 90 * t1 + 298 * c1 + 45 * pow(t1, 2) - 3 * pow(c1, 2) - 252 * e2) * pow(dd, 6) / 720.0;
    double lat = fp - q1 * (q2 - q3 + q4);
    double q5 = dd;
    double q6 = (1 + 2 * t1 + c1) * pow(dd, 3) / 6;
    double q7 = (5 - 2 * c1 + 28 * t1 - 3 * pow(c1, 2) + 8 * e2 + 24 * pow(t1, 2)) * pow(dd, 5) / 120.0;
    double lng = lng0 + (q5 - q6 + q7) / cos(fp);
    
    lat = (lat * 180) / M_PI;
    lng = (lng * 180) / M_PI;
    
    location.latitude = lat;
    location.longitude = lng;
    
    return location;
}


#pragma mark - UITableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ParkInfoViewDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"parkinfoviewdetailtableviewcellid"];

    switch (indexPath.row) {
        case 0:
            cell.titleLabel.text = @"停車場名稱";
            cell.descriptionLabel.text = self.parkInfo.name;
            break;
            
        case 1:
            cell.titleLabel.text = @"區域";
            cell.descriptionLabel.text = self.parkInfo.area;
            break;
            
        case 2:
            cell.titleLabel.text = @"營業時間";
            cell.descriptionLabel.text = self.parkInfo.servicetime;
            break;
            
        case 3:
            cell.titleLabel.text = @"地址";
            cell.descriptionLabel.text = self.parkInfo.address;
            break;
            
        default:
            break;
    }

    return cell;
}


#pragma mark - MKMapView delegate
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id)overlay{
    MKPolylineRenderer * render = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    render.strokeColor =[ UIColor blueColor];
    render.lineWidth = 5;
    
    return render;
}

- (void)mapView:(MKMapView *)mapView didAddOverlayRenderers:(NSArray<MKOverlayRenderer *> *)renderers {
    NSLog(@"didAddOverlayRenderers");
}


#pragma mark - CLLocationManager delegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusRestricted || status ==  kCLAuthorizationStatusDenied) {
        NSLog(@"Please enable location service");
    }else if (status == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    }else {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (!self.currentLocation) {
        self.currentLocation = [locations lastObject];
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, 500, 500);
        MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:region];
        [self.mapView setRegion:adjustedRegion animated:NO];
        [self.mapView setShowsUserLocation:YES];
        self.mapView.delegate = self;
        
        [self drawLine];
    }else {
        if ([self.currentLocation distanceFromLocation:locations.lastObject] > manager.distanceFilter) {
            self.currentLocation = [locations lastObject];
        }
    }
}

@end
