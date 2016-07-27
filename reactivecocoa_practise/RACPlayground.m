//
//  RACPlayground.m
//  reactivecocoa_practise
//
//  Created by ZangChengwei on 16/6/19.
//  Copyright © 2016年 ZangChengwei. All rights reserved.
//

#import "RACPlayground.h"
#import <ReactiveCocoa.h>

void rac_playground()
{
    RACSignal *signal = [RACSignal return:@1];
    [signal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
}

void asyncFeature()
{
    NSURL *url = [NSURL URLWithString:@"http://xxxx.com/"];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url];
    
}

void eventFeature()
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    
}