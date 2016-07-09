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

void higherOrderSignal()
{
    RACSignal *signal = [RACSignal return:@1];
    RACSignal *signalHighOrder = [RACSignal return:signal];
    RACSignal *anotherSignal = [signal map:^id(id value) {
        return [RACSignal return:value];
    }];
}

void subscirbeHighOrderSignal()
{
    RACSignal *signal = @[@1, @2, @3].rac_sequence.signal;
    RACSignal *highOrderSignal = [signal map:^id(id value) {
        return [RACSignal return:value];
    }];
    
    [highOrderSignal subscribeNext:^(RACSignal *aSignal) {
        [aSignal subscribeNext:^(id x) {
            // get real value here.
        }];
    }];
}

void switchToLatests()
{
    RACSignal *signal = @[@1, @2, @3].rac_sequence.signal;
    RACSignal *signalA = [signal map:^id(id value) {
        return [RACSignal return:value];
    }];
    
    RACSignal *signalB = [signalA switchToLatest];
}