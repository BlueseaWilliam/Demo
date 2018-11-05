//
//  DataManager.h
//  Demo
//
//  Created by William on 2018/10/31.
//  Copyright © 2018年 William. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataManager : NSObject

+ (DataManager *)sharedManager;
- (void)setupDBByJsonDictionary:(NSDictionary *)dict completion:(void (^)(bool result))completion;

- (void)getParkInfoAllDataCompletion:(void (^)(NSArray *array))completio;
- (void)getParkInfoDataByArea:(NSString *)area withKeyword:(NSString *)keyword withCompletion:(void (^)(NSArray *array))completion;
@end

NS_ASSUME_NONNULL_END
