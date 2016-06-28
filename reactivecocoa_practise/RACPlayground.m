//
//  RACPlayground.m
//  reactivecocoa_practise
//
//  Created by ZangChengwei on 16/6/19.
//  Copyright © 2016年 ZangChengwei. All rights reserved.
//

#import "RACPlayground.h"
#import <ReactiveCocoa.h>

void sequence();
void rac_playground()
{
    RACSignal *signal = [RACSignal return:@1];
    [signal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    
    sequence();
}

int factorial1(int x) {
    int result = 1;
    for (int i = 1; i <= x; ++i) {
        result *= i;
    }
    return result;
}

int factorial2(int x) {
    if (x == 1) return 1;
    return x * factorial2(x - 1);
}


void test() {
    int a = 5;
    int b = 6;
    int c = a + b;
    a = 10;
    NSLog(@"%d", c);
    
}

void sequence() {
    RACSequence *sequence1 = [RACSequence return:@1];
    RACSequence *sequence2 = [RACSequence sequenceWithHeadBlock:^id{
        return @2;
    } tailBlock:^RACSequence *{
        return sequence1;
    }];
    RACSequence *sequence3 = @[@1, @2, @3].rac_sequence;
    
    RACSequence *mappedSequence = [sequence1 map:^id(NSNumber *value) {
        return @(value.integerValue * 3);
    }];
    RACSequence *concatedSequence = [sequence2 concat:mappedSequence];
    RACSequence *mergedSequence = [RACSequence zip:@[concatedSequence, sequence3]];
    
    NSLog(@"head is %@", mergedSequence.head);
    for (id value in mergedSequence) {
        NSLog(@"value is %@", value);
    }
    
}
UIView *someObject = nil;
void signalExample() {
    id self = nil;
    RACSignal *signal1 = [RACSignal return:@"hello"];
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        [subscriber sendNext:@2];
        [subscriber sendCompleted];
        return nil;
    }];
    RACSignal *signal3 = RACObserve(someObject, frame);
    
    RACSignal *mappedSignal = [signal1 map:^id(NSString *value) {
        return [value stringByAppendingString:@" world"];
    }];
    RACSignal *concatedSignal = [mappedSignal concat:signal2];
    RACSignal *mergeSignal = [RACSignal merge:@[concatedSignal, signal3]];
    
    [mergeSignal subscribeNext:^(id x) {
        NSLog(@"next is %@", x);
    } completed:^{
        NSLog(@"completed");
    }];
    
    
}

RACSignal *makeTimer(int times) {
    RACSignal *timer = [RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]];
    return [[[timer scanWithStart:@(times) reduce:^id(NSNumber *running, id _) {
        return @(running.intValue - 1);
    }] startWith:@(times)]
    takeUntilBlock:^BOOL(NSNumber *x) {
        return x.intValue == 0;
    }];
}

typedef int(^intFunc)(int a);

intFunc addX(int x) {
    return ^int(int p) {
        return x + p;
    };
}

intFunc transparent(intFunc origin) {
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    return ^int(int p) {
        if (results[@(p)]) {
            return [results[@(p)] intValue];
        }
        results[@(p)] = @(origin(p));
        return [results[@(p)] intValue];
    };
}




intFunc other(intFunc intFunc1) {
    return ^int(int p) {
        return -intFunc1(p);
    };
}

void testAddX() {
    intFunc fun1 = addX(5);
    intFunc fun2 = other(fun1);
    
    intFunc fun3 = transparent(fun2);
    
    int result = fun3(7);
    int result2 = fun3(7);
}

void test3() {
    NSArray *a = @[@1, @2, @3];
    // a <*> (* 10)
    NSMutableArray *array = [NSMutableArray array];
    for (NSNumber *v in a) {
        [array addObject:@(v.integerValue * 10)];
    }
    id v = array[2];
    
}

void test4() {
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        [subscriber sendNext:@2];
        [subscriber sendNext:@3];
        [subscriber sendCompleted];
        return nil;
    }];
    
    __block int collection = 0;
    [signal subscribeNext:^(id x) {
        collection += [x intValue];
    }];
    
    [signal aggregateWithStart:@0 reduce:^id(NSNumber *running, NSNumber *next) {
        return @(running.intValue + next.intValue);
    }];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"%@ is the result", x);
    }];
    
    
    
}



































