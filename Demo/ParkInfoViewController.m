//
//  ParkInfoViewController.m
//  Demo
//
//  Created by William on 2018/10/31.
//  Copyright © 2018年 William. All rights reserved.
//

#import "ParkInfoViewController.h"
#import "ParkInfoViewDetailController.h"

#import "ParkInfoTableViewCell.h"

#import "DataManager.h"
#import "NetWorkManager.h"


@interface ParkInfoViewController () <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *areaArray;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, assign) NSInteger areaSelected;
@property (nonatomic, strong) UIPickerView *areaPicker;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end


@implementation ParkInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //setup Data
    self.areaSelected = 0;
    self.dataArray = nil;
    self.areaArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AreaList" ofType:@"plist"]];
    
    //setup PickerView
    [self setupPickerView];
    
    //setup RefreshControl
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(handleRefresh) forControlEvents:UIControlEventValueChanged];
    
    //setup TableView
    [self.listView addSubview:self.refreshControl];
    [self.listView registerNib:[UINib nibWithNibName:@"ParkInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"parkinfotableviewcellid"];
    
    //fetch Data From API server
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[NetWorkManager sharedManager] getDataFromAPICompletion:^(bool result, NSDictionary * _Nonnull dict) {
        if (!result) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSLog(@"Failed to fetch data from API server");
        }else {
            [[DataManager sharedManager] setupDBByJsonDictionary:dict completion:^(bool result) {
                if (!result) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    NSLog(@"Failed to setup DB");
                }else {
                    [[DataManager sharedManager] getParkInfoAllDataCompletion:^(NSArray * _Nonnull array) {
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        
                        self.dataArray = array;
                        [self.listView reloadData];
                    }];
                }
            }];
        }
    }];
}

#pragma mark - Button Methods
- (void)pressDone:(UIBarButtonItem *)sender {
    [self.areaField resignFirstResponder];
    
    if (self.areaSelected == 0) {
        self.areaField.text = @"";
    }else {
        self.areaField.text = [self.areaArray objectAtIndex:self.areaSelected];
    }
}

- (void)pressCancel:(UIBarButtonItem *)sender {
    [self.areaField resignFirstResponder];
}

- (IBAction)filterBtnPress:(id)sender {
    [self resignAllResponder];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[DataManager sharedManager] getParkInfoDataByArea:self.areaField.text withKeyword:self.keywordField.text withCompletion:^(NSArray * _Nonnull array) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        self.dataArray = array;
        [self.listView reloadData];
    }];
}


#pragma mark - Private Methods
- (void)setupPickerView {
    self.areaPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];;
    self.areaPicker.delegate = self;
    self.areaPicker.dataSource = self;
    self.areaPicker.showsSelectionIndicator = YES;
    self.areaPicker.backgroundColor = [UIColor whiteColor];
    self.areaField.inputView = self.areaPicker;
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pressDone:)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(pressCancel:)];
    [toolBar setItems:[NSArray arrayWithObjects:cancelButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], doneButton, nil]];
    self.areaField.inputAccessoryView = toolBar;
}

- (void)resignAllResponder {
    if (self.areaField.isFirstResponder) {
        [self.areaField resignFirstResponder];
    }
    
    if (self.keywordField.isFirstResponder) {
        [self.keywordField resignFirstResponder];
    }
}

- (void)handleRefresh {
    [[NetWorkManager sharedManager] getDataFromAPICompletion:^(bool result, NSDictionary * _Nonnull dict) {
        if (!result) {
            NSLog(@"Failed to fetch data from API server");
        }else {
            [[DataManager sharedManager] setupDBByJsonDictionary:dict completion:^(bool result) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                if (!result) {
                    NSLog(@"Failed to update DB");
                }else {
                    [[DataManager sharedManager] getParkInfoDataByArea:self.areaField.text withKeyword:self.keywordField.text withCompletion:^(NSArray * _Nonnull array) {
                        self.dataArray = array;
                        [self.listView reloadData];
                        [self.refreshControl endRefreshing];
                    }];
                }
            }];
        }
    }];
}


#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];

    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}


#pragma mark - UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.areaArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.areaArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.areaSelected = (int)row;
}


#pragma mark - UITableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ParkInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"parkinfotableviewcellid"];
    ParkInfo *info = [self.dataArray objectAtIndex:indexPath.row];

    if (info) {
        cell.nameLabel.text = info.name;
        cell.areaLabel.text = info.area;
        cell.timeLabel.text = info.servicetime;
        cell.addressLabel.text = info.address;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self resignAllResponder];
    ParkInfoViewDetailController *infoVC = [[ParkInfoViewDetailController alloc] initWithNibName:@"ParkInfoViewDetailController" bundle:nil withParkInfo:[self.dataArray objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:infoVC animated:YES];
    infoVC = nil;
}

@end
