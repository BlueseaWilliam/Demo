//
//  DataManager.m
//  Demo
//
//  Created by William on 2018/10/31.
//  Copyright © 2018年 William. All rights reserved.
//

#import "DataManager.h"
#import "ParkInfo+CoreDataClass.h"
#import <MagicalRecord/MagicalRecord.h>


static DataManager *dataManager = nil;


@interface DataManager ()

@end


@implementation DataManager

+ (DataManager *)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataManager = [[DataManager alloc] init];
    });
    
    return dataManager;
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (void)setupDBByJsonDictionary:(NSDictionary *)dict completion:(void (^)(bool result))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL result = NO;
        
        if ([dict objectForKey:@"success"] && [[dict objectForKey:@"success"] boolValue]) {
            if ([[dict objectForKey:@"result"] objectForKey:@"records"]) {
                NSDate *date = [NSDate date];
                NSArray *array = [[dict objectForKey:@"result"] objectForKey:@"records"];
                NSManagedObjectContext *newContext = [NSManagedObjectContext MR_rootSavingContext];
                
                for (NSDictionary *d in array) {
                    if ([d objectForKey:@"ID"] && [d objectForKey:@"NAME"]) {
                        ParkInfo *parkinfo = [self findParkInByID:[d objectForKey:@"ID"] name:[d objectForKey:@"NAME"]];
                        
                        if (!parkinfo) {
                            [self createNewParkInfoByDictionary:d withData:date withContext:newContext];
                        }else {
                            [self updateParkInfo:&parkinfo byDictionary:dict withData:date];
                        }
                    }
                }
                
                [self deleteDataByDateIfNeed:date withContext:newContext];
                [newContext MR_saveToPersistentStoreAndWait];
                
                result = YES;
                date = nil;
                array = nil;
                newContext = nil;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(result);
            }
        });
    });
}


#pragma mark - Fetch Data methods
- (void)getParkInfoAllDataCompletion:(void (^)(NSArray *array))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *resultArray = [ParkInfo MR_findAll];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(resultArray);
            }
        });
    });
}

- (void)getParkInfoDataByArea:(NSString *)area withKeyword:(NSString *)keyword withCompletion:(void (^)(NSArray *array))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *resultArray = nil;
        NSMutableArray *array = [NSMutableArray array];
        
        if (area && area.length) {
            [array addObject:[NSPredicate predicateWithFormat:@"area == %@", area]];
        }
        
        if (keyword && keyword.length) {
            [array addObject:[NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", keyword]];
        }
        
        NSPredicate *predicates = [NSCompoundPredicate andPredicateWithSubpredicates:array];
        resultArray = [ParkInfo MR_findAllWithPredicate:predicates];
        array = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(resultArray);
            }
        });
    });
}


#pragma mark - CoreData methods
- (ParkInfo *)findParkInByID:(NSString *)idKey name:(NSString *)nameKey {
    NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"idkey == %@", idKey];
    NSPredicate *predicateName = [NSPredicate predicateWithFormat:@"name == %@", nameKey];
    NSPredicate *placesPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicateID, predicateName]];
    ParkInfo *parkInfo = [ParkInfo MR_findFirstWithPredicate:placesPredicate];
    
    predicateID = nil;
    predicateName = nil;
    placesPredicate = nil;
    
    return parkInfo;
}

- (void)deleteDataByDateIfNeed:(NSDate *)date withContext:(NSManagedObjectContext *)context {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accessdate < %@", date];
    NSArray *oldDataArray = [ParkInfo MR_findAllWithPredicate:predicate];

    for (ParkInfo *info in oldDataArray) {
        [info MR_deleteEntityInContext:context];
    }
}

- (void)updateParkInfo:(ParkInfo **)parkInfo byDictionary:(NSDictionary *)dict withData:(NSDate *)date {
    if([dict objectForKey:@"AREA"]) (*parkInfo).area = [dict objectForKey:@"AREA"];
    if([dict objectForKey:@"TYPE"]) (*parkInfo).type = [dict objectForKey:@"TYPE"];
    if([dict objectForKey:@"SUMMARY"]) (*parkInfo).summary = [dict objectForKey:@"SUMMARY"];
    if([dict objectForKey:@"ADDRESS"]) (*parkInfo).address = [dict objectForKey:@"ADDRESS"];
    if([dict objectForKey:@"TEL"]) (*parkInfo).tel = [dict objectForKey:@"TEL"];
    if([dict objectForKey:@"PAYEX"]) (*parkInfo).payex = [dict objectForKey:@"PAYEX"];
    if([dict objectForKey:@"SERVICETIME"]) (*parkInfo).servicetime = [dict objectForKey:@"SERVICETIME"];
    if([dict objectForKey:@"TW97X"]) (*parkInfo).tw97x = [dict objectForKey:@"TW97X"];
    if([dict objectForKey:@"TW97Y"]) (*parkInfo).tw97y = [dict objectForKey:@"TW97Y"];
    if([dict objectForKey:@"TOTALCAR"]) (*parkInfo).totalcar = [dict objectForKey:@"TOTALCAR"];
    if([dict objectForKey:@"TOTALMOTOR"]) (*parkInfo).totalmotor = [dict objectForKey:@"TOTALMOTOR"];
    if([dict objectForKey:@"TOTALBIKE"]) (*parkInfo).totalbike = [dict objectForKey:@"TOTALBIKE"];
    (*parkInfo).accessdate = date;
}

- (void)createNewParkInfoByDictionary:(NSDictionary *)dict withData:(NSDate *)date withContext:(NSManagedObjectContext *)context {
    ParkInfo *parkInfo = [ParkInfo MR_createEntityInContext:context];
    if([dict objectForKey:@"ID"]) parkInfo.idkey = [dict objectForKey:@"ID"];
    if([dict objectForKey:@"NAME"]) parkInfo.name = [dict objectForKey:@"NAME"];
    if([dict objectForKey:@"AREA"]) parkInfo.area = [dict objectForKey:@"AREA"];
    if([dict objectForKey:@"TYPE"]) parkInfo.type = [dict objectForKey:@"TYPE"];
    if([dict objectForKey:@"SUMMARY"]) parkInfo.summary = [dict objectForKey:@"SUMMARY"];
    if([dict objectForKey:@"ADDRESS"]) parkInfo.address = [dict objectForKey:@"ADDRESS"];
    if([dict objectForKey:@"TEL"]) parkInfo.tel = [dict objectForKey:@"TEL"];
    if([dict objectForKey:@"PAYEX"]) parkInfo.payex = [dict objectForKey:@"PAYEX"];
    if([dict objectForKey:@"SERVICETIME"]) parkInfo.servicetime = [dict objectForKey:@"SERVICETIME"];
    if([dict objectForKey:@"TW97X"]) parkInfo.tw97x = [dict objectForKey:@"TW97X"];
    if([dict objectForKey:@"TW97Y"]) parkInfo.tw97y = [dict objectForKey:@"TW97Y"];
    if([dict objectForKey:@"TOTALCAR"]) parkInfo.totalcar = [dict objectForKey:@"TOTALCAR"];
    if([dict objectForKey:@"TOTALMOTOR"]) parkInfo.totalmotor = [dict objectForKey:@"TOTALMOTOR"];
    if([dict objectForKey:@"TOTALBIKE"]) parkInfo.totalbike = [dict objectForKey:@"TOTALBIKE"];
    parkInfo.accessdate = date;
    parkInfo = nil;
}

@end
