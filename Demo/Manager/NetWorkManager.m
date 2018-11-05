//
//  NetWorkManager.m
//  Demo
//
//  Created by William on 2018/10/31.
//  Copyright © 2018年 William. All rights reserved.
//

#import "NetWorkManager.h"

#define API_URL @"http://data.ntpc.gov.tw/api/v1/rest/datastore/382000000A-000225-002"

static NetWorkManager *netWorkManager = nil;


@implementation NetWorkManager

+ (NetWorkManager *)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        netWorkManager = [[NetWorkManager alloc] init];
    });
    
    return netWorkManager;
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (void)getDataFromAPICompletion:(void (^)(bool result, NSDictionary *dict))completion {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:API_URL]];
    NSURLSessionDataTask *sessionDataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if(!data) {
            if (completion) {
                completion(NO, nil);
            }
        }else {
            NSError *jsonError;
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    (error) ? completion(NO, nil) : completion(YES, jsonData);
                }
            });
        }
    }];
    
    [sessionDataTask resume];
}

@end
