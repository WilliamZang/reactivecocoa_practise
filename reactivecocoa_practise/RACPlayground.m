//
//  RACPlayground.m
//  reactivecocoa_practise
//
//  Created by ZangChengwei on 16/6/19.
//  Copyright © 2016年 ZangChengwei. All rights reserved.
//

#import "RACPlayground.h"
#import <ReactiveCocoa.h>

void interestingQuestion();
void rac_playground()
{
    interestingQuestion();
}
void subject()
{
    RACSubject *subject = [RACSubject subject];
    
    [subject subscribeNext:^(id x) {
        // a
    } error:^(NSError *error) {
        // b
    } completed:^{
        // c
    }];
    
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@3];
    
    [subject sendCompleted];
    
    
}

void coldSignalToHotSignal()
{
    RACSignal *signal = @[@1, @2, @3, @4].rac_sequence.signal;
    RACSignal *signalB = [[signal map:^id(id value) {
        return [[RACSignal return:value] delay:1];
    }] concat];
    
    RACSubject *speaker = [RACSubject subject];
    [signalB subscribe:speaker];
    
    [speaker subscribeNext:^(id x) {
        // a
    }];
    
    [speaker subscribeNext:^(id x) {
        // b
    }];
    
    [speaker subscribeNext:^(id x) {
        // c
    }];
}

void replaySubject()
{
    RACReplaySubject *subject = [RACReplaySubject
                                 replaySubjectWithCapacity:1];
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendCompleted];
    
    [subject subscribeNext:^(id x) {  /* a*/  }];
    
    
}

void interestingQuestion()
{
    RACSignal *signal = @[@1, @2, @3, @4].rac_sequence.signal;
    
    RACSignal *signalGroup = [signal groupBy:^NSString *(NSNumber *object) {
        return object.integerValue % 2 == 0 ? @"odd" : @"even";
    }];
    
    [[[signalGroup take:1] flatten] subscribeNext:^(id x) {
        NSLog(@"next: %@", x);
    }];
}
void scheduler()
{
    // 主线程的Scheduler
    RACScheduler *mainScheduler = [RACScheduler mainThreadScheduler];
    
    // 子线程的两个Scheduler，注意[RACScheduler scheduler]是返回一个新的
    RACScheduler *scheduler1 = [RACScheduler scheduler];
    RACScheduler *scheduler2 = [RACScheduler scheduler];
    
    // 返回当前的Scheduler，自定义线程会返回nil
    RACScheduler *scheduler3 = [RACScheduler currentScheduler];
    
    // 创建某优先级Scheduler，不建议除非你知道你在干神马
    RACScheduler *scheduler4 = [RACScheduler schedulerWithPriority:RACSchedulerPriorityHigh];
    RACScheduler *scheduler5 = [RACScheduler schedulerWithPriority:RACSchedulerPriorityHigh name:@"someName"];
    
    // 创建立即Scheduler，不建议除非你知道你在干神马
    RACScheduler *scheduler6 = [RACScheduler immediateScheduler];
    
    // 分派一个任务, [disposable dispose]用来取消
    RACDisposable *disposable = [mainScheduler schedule:^{ /* 这里是个任务 */ }];
    [disposable dispose];
    
    // 定时任务
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date = [formatter dateFromString:@"2016-07-20 21:00:00"];
    [scheduler1 after:date schedule:^{ /* 将在2016-07-20 21:00:00执行 */ }];
    
    // 延时任务
    [scheduler2 afterDelay:30 schedule:^{ /* 将在30秒后执行 */ }];
    
    // 循环任务
    [scheduler3 after:[NSDate date] repeatingEvery:1 withLeeway:0.1 schedule:^{
        // 从现在开始，每1秒执行一次，最长不能操作1.1秒执行下一次
    }];
}

void subscribeSync()
{
    NSLog(@"start test");
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"sendNext:@1");
        [subscriber sendNext:@1];
        NSLog(@"sendNext:@2");
        [subscriber sendNext:@2];
        NSLog(@"sendCompleted");
        [subscriber sendCompleted];
        NSLog(@"return nil");
        return nil;
    }];
    NSLog(@"signal was created");
    [signal subscribeNext:^(id x) {
        NSLog(@"receive next:%@", x);
    } error:^(NSError *error) {
        NSLog(@"receive error:%@", error);
    } completed:^{
        NSLog(@"receive complete");
    }];
    NSLog(@"subscribing finished");
}

void subscribeAsync()
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"111");
        [subscriber sendNext:@1];
        [subscriber sendCompleted];
        
        return nil;
    }];
    
    [[RACScheduler scheduler] schedule:^{
        NSLog(@"222");
        [signal subscribeNext:^(id x) {
            NSLog(@"333");
        }];
    }];
    
    NSLog(@"444");
}

void sendAsync()
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"111");
        RACDisposable *disposable = [[RACScheduler scheduler] schedule:^{
            [subscriber sendNext:@1];
            [subscriber sendCompleted];
        }];
        return disposable;
    }];
    
    NSLog(@"222");
    [signal subscribeNext:^(id x) {
        NSLog(@"333");
    }];
    
    NSLog(@"444");
}

void sendEverywhere()
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"111");
        [subscriber sendNext:@0.1];
        RACDisposable *disposable = [[RACScheduler scheduler] schedule:^{
            [subscriber sendNext:@1.1];
            [subscriber sendCompleted];
        }];
        return disposable;
    }];
    NSLog(@"222");
    [signal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    NSLog(@"444");
}

void sendAndSubscribeEverywhere()
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"111");
        [subscriber sendNext:@0.1];
        RACDisposable *disposable = [[RACScheduler scheduler] schedule:^{
            [subscriber sendNext:@1.1];
            [subscriber sendCompleted];
        }];
        return disposable;
    }];
    [[RACScheduler scheduler] schedule:^{
        NSLog(@"222");
        [signal subscribeNext:^(id x) {
            NSLog(@"%@", x);
        }];
    }];
    NSLog(@"444");
}

void useSubscribeOn()
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"111");
        [subscriber sendNext:@0.1];
        RACDisposable *disposable = [[RACScheduler scheduler] schedule:^{
            [subscriber sendNext:@1.1];
            [subscriber sendCompleted];
        }];
        return disposable;
    }];
    [[RACScheduler scheduler] schedule:^{
        NSLog(@"222");
        [[signal subscribeOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
            NSLog(@"%@", x);
        }];
    }];
    NSLog(@"444");
}

void useDeliverOn()
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"111");
        [subscriber sendNext:@0.1];
        RACDisposable *disposable = [[RACScheduler scheduler] schedule:^{
            [subscriber sendNext:@1.1];
            [subscriber sendCompleted];
        }];
        return disposable;
    }];
    [[RACScheduler scheduler] schedule:^{
        NSLog(@"222");
        [[signal deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
            NSLog(@"%@", x);
        }];
    }];
    NSLog(@"444");
}

void whenShouldWeUseSubscribeOn()
{
    UIView *view = [[UIView alloc] init];
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        UILabel *label = [[UILabel alloc] init];
        label.text = @"Hello world";
        [view addSubview:label];
        
        [subscriber sendNext:@0.1];
        RACDisposable *disposable = [[RACScheduler scheduler] schedule:^{
            [subscriber sendNext:@1.1];
            [subscriber sendCompleted];
        }];
        return disposable;
    }];
    [[RACScheduler scheduler] schedule:^{
        [[signal subscribeOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
            NSLog(@"%@", x);
        }];
    }];
}