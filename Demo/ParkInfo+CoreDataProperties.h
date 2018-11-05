//
//  ParkInfo+CoreDataProperties.h
//  Demo
//
//  Created by William on 2018/11/3.
//  Copyright © 2018年 William. All rights reserved.
//
//

#import "ParkInfo+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface ParkInfo (CoreDataProperties)

+ (NSFetchRequest<ParkInfo *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *address;
@property (nullable, nonatomic, copy) NSString *area;
@property (nullable, nonatomic, copy) NSString *idkey;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *payex;
@property (nullable, nonatomic, copy) NSString *servicetime;
@property (nullable, nonatomic, copy) NSString *summary;
@property (nullable, nonatomic, copy) NSString *tel;
@property (nullable, nonatomic, copy) NSString *totalbike;
@property (nullable, nonatomic, copy) NSString *totalcar;
@property (nullable, nonatomic, copy) NSString *totalmotor;
@property (nullable, nonatomic, copy) NSString *tw97x;
@property (nullable, nonatomic, copy) NSString *tw97y;
@property (nullable, nonatomic, copy) NSString *type;
@property (nullable, nonatomic, copy) NSDate *accessdate;

@end

NS_ASSUME_NONNULL_END
