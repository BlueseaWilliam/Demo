//
//  NetWorkManager.h
//  Demo
//
//  Created by William on 2018/10/31.
//  Copyright © 2018年 William. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetWorkManager : NSObject

+ (NetWorkManager *)sharedManager;

- (BOOL)isNetworkConnected;
- (void)getDataFromAPICompletion:(void (^)(bool result, NSDictionary *dict))completion;

@end

NS_ASSUME_NONNULL_END
