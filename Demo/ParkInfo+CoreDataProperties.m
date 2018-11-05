//
//  ParkInfo+CoreDataProperties.m
//  Demo
//
//  Created by William on 2018/11/3.
//  Copyright © 2018年 William. All rights reserved.
//
//

#import "ParkInfo+CoreDataProperties.h"

@implementation ParkInfo (CoreDataProperties)

+ (NSFetchRequest<ParkInfo *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"ParkInfo"];
}

@dynamic address;
@dynamic area;
@dynamic idkey;
@dynamic name;
@dynamic payex;
@dynamic servicetime;
@dynamic summary;
@dynamic tel;
@dynamic totalbike;
@dynamic totalcar;
@dynamic totalmotor;
@dynamic tw97x;
@dynamic tw97y;
@dynamic type;
@dynamic accessdate;

@end
