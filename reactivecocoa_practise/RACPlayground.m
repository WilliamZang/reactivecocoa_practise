//
//  RACPlayground.m
//  reactivecocoa_practise
//
//  Created by ZangChengwei on 16/6/19.
//  Copyright © 2016年 ZangChengwei. All rights reserved.
//

#import "RACPlayground.h"
#import <ReactiveCocoa.h>

typedef int(^FoldFunction)(int running, int next);
int fold(int *array, int count, FoldFunction func, int start);
void subscribe();

void rac_playground()
{
    int arr[] = {1, 2, 3, 4, 5};
    int result = fold(arr, 5, ^int(int running, int next) {
        return running + next;
    }, 0);
    // result = ?
    NSLog(@"%d", result);
    return ;
    id self = nil;
    
    NSError *errorObject = [NSError errorWithDomain:@"Something wrong" code:500 userInfo:nil];
    RACSignal *signal1 = [RACSignal return:@"Some Value"];
    RACSignal *signal2 = [RACSignal error:errorObject];
    RACSignal *signal3 = [RACSignal empty];
    RACSignal *signal4 = [RACSignal never];
    
    RACSignal *signal5 = [RACSignal createSignal:
                          ^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        [subscriber sendNext:@2];
        [subscriber sendError:errorObject];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
           
        }];
    }];
    
    UIControl *view = [[UIControl alloc] initWithFrame:CGRectZero];
    
    RACSignal *signal6 = [view rac_signalForSelector:@selector(setFrame:)];
    RACSignal *signal7 = [view rac_signalForControlEvents:UIControlEventTouchUpInside];
    RACSignal *signal8 = [view rac_willDeallocSignal];
    RACSignal *signal9 = RACObserve(view, backgroundColor);
    
    RACSignal *signal10 = [signal1 map:^id(NSString *value) {
        return [value substringFromIndex:1];
    }];

    RACSequence *sequence = @[@"A", @"B", @"C"].rac_sequence;

    RACSignal *signal11 = sequence.signal;
    
    [signal11 subscribeNext:^(id x) {
        NSLog(@"next value is %@", x);
    } error:^(NSError *error) {
        NSLog(@"Ops! Get some error: %@", error);
    } completed:^{
        NSLog(@"It finished success");
    }];
    
    RAC(view, backgroundColor) = signal10;
    
    [view rac_liftSelector:@selector(convertPoint:toView:)
               withSignals:signal1, signal2, nil];
    [view rac_liftSelector:@selector(convertRect:toView:)
      withSignalsFromArray:@[signal3, signal4]];
    [view rac_liftSelector:@selector(convertRect:toLayer:)
     withSignalOfArguments:signal5];
    
}

void subscribe()
{
    RACSignal *signal = [RACSignal createSignal:
                         ^RACDisposable *(id<RACSubscriber> subscriber)
    {
        [subscriber sendNext:@1];
        [subscriber sendNext:@2];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"dispose");
        }];
    }];
    
    RACDisposable *disposable = [signal subscribeNext:^(id x) {
        NSLog(@"next value is %@", x);
    } error:^(NSError *error) {
        NSLog(@"Ops! Get some error: %@", error);
    } completed:^{
        NSLog(@"It finished success");
    }];
    
    [disposable dispose];
    
}

void tuple()
{
    
    RACTuple *tuple = RACTuplePack(@1, @"haha");
    
    id first = tuple.first;
    id second = tuple.second;
    id last = tuple.last;
    id index1 = tuple[1];
    
    RACTupleUnpack(NSNumber *num, NSString *str) = tuple;
    
}

void map()
{
    RACSignal *signal = @[@1, @2, @3, @4].rac_sequence.signal;
    
    RACSignal *newSignal = [signal map:^id(NSNumber *value) {
        return @(value.integerValue * 2);
    }];
    
}

void mapAndMapReplace()
{
    RACSignal *signalA = @[@1, @2, @3, @4].rac_sequence.signal;
    
    RACSignal *signalB = [signalA map:^id(id value) {
        return @8;
    }]; // signalB is --8--8--8--8--|
    
    RACSignal *signalC = [signalA mapReplace:@8];
    // signalC is --8--8--8--8--| too.
    
}

void reduceEach()
{
    RACTuple *a = RACTuplePack(@1, @2);
    RACTuple *b = RACTuplePack(@2, @3);
    RACTuple *c = RACTuplePack(@3, @5);
    
    RACSignal *signalA = @[a, b, c].rac_sequence.signal;
    
    RACSignal *signalB = [signalA reduceEach:^id(NSNumber *first,
                                                 NSNumber *second) {
        return @(first.integerValue + second.integerValue);
    }];
}

void filter()
{
    RACSignal *signalA = @[@"ab", @"hello", @"ppp", @"0"].rac_sequence.signal;
    
    RACSignal *signalB = [signalA filter:^BOOL(NSString *value) {
        return value.length > 2;
    }];
    
}

void igrone()
{
    RACSignal *signalA = @[@1, @2, @1, @3].rac_sequence.signal;
    
    RACSignal *signalB = [signalA filter:^BOOL(id value) {
        return ![@1 isEqual:value];
    }];
    
    RACSignal *signalC = [signalA ignore:@1];
}

void take()
{
    RACSignal *signalA = @[@1, @2, @3].rac_sequence.signal;
    
    RACSignal *signalB = [signalA take:2];
    
}

void startWith()
{
    RACSignal *signalA = @[@"ab", @"hello", @"ppp", @"0"].rac_sequence.signal;
    
    RACSignal *signalB = [signalA startWith:@"Start"];
}

void sideEffect()
{
    RACSignal *signalA = @[@"ab", @"hello", @"ppp", @"0"].rac_sequence.signal;
    
    RACSignal *signalB = [signalA map:^id(id value) {
        // do some thing;
        return value;
    }];
    
    RACSignal *signalC = [signalA doNext:^(id x) {
        // do some thing;
    }];
    
}

int fold(int *array, int count, FoldFunction func, int start)
{
    int current = array[0];
    int running = func(start, current);
    if (count == 1) {
        return running;
    }
    return fold(array + 1, count - 1, func, running);
}

void aggregate()
{
    RACSignal *signalA = @[@1, @2, @3, @4].rac_sequence.signal;
    
    RACSignal *signalB = [signalA aggregateWithStart:@0
                                              reduce:^id(NSNumber *running,
                                                         NSNumber *next) {
        return @(running.integerValue + next.integerValue);
    }];
    
}

void scan()
{
    RACSignal *signalA = @[@1, @2, @3, @4].rac_sequence.signal;
    
    RACSignal *signalB = [signalA scanWithStart:@0
                                         reduce:^id(NSNumber *running,
                                                    NSNumber *next) {
        return @(running.integerValue + next.integerValue);
    }];
    
}

void infinitySignal()
{
    RACSignal *repeat1 = [[RACSignal return:@1] repeat];
    
    RACSignal *signalB = [repeat1 scanWithStart:@0
                                         reduce:^id(NSNumber *running,
                                                    NSNumber *next) {
        return @(running.integerValue + next.integerValue);
    }];
    
    RACSignal *signalC = [repeat1 scanWithStart:RACTuplePack(@1, @1)
                                         reduce:^id(RACTuple *running, id _) {
        NSNumber *next = @([running.first integerValue] + [running.second integerValue]);
        return RACTuplePack(running.second, next);
    }];
}

void delaySignal()
{
    RACSignal *signalA = @[@1, @2, @3, @4].rac_sequence.signal;
    
    RACSignal *signalB = [signalA delay:1];
    
    // another interval signal
    RACSignal *interval = [[[RACSignal return:@1] delay:1] repeat];
}

void concatWith()
{
    RACSignal *signalA = @[@1, @2, @3, @4, @5].rac_sequence.signal;
    RACSignal *signalB = @[@6, @7].rac_sequence.signal;
    
    RACSignal *signalC = [signalA concat:signalB];
}

void merge()
{
    RACSignal *signalA = @[@1, @2, @3, @4, @5].rac_sequence.signal;
    RACSignal *signalB = @[@6, @7].rac_sequence.signal;
    
    {
        RACSignal *signalC = [signalA merge:signalB];
    }
    {
        RACSignal *signalC = [RACSignal merge:@[signalA, signalB]];
    }
    {
        RACSignal *signalC = [RACSignal merge:RACTuplePack(signalA, signalB)];
    }
}

void mergeMapreplace()
{
    UIViewController *self = nil;
    
    RACSignal *appearSignal = [[self rac_signalForSelector:@selector(viewDidAppear:)]
                               mapReplace:@YES];
    RACSignal *disappearSignal = [[self rac_signalForSelector:@selector(viewWillDisappear:)]
                                  mapReplace:@NO];

    RACSignal *activeSignal = [RACSignal merge:@[appearSignal, disappearSignal]];

}

void combineLatest()
{
    RACSignal *signalA = @[@1, @2, @3, @4, @5].rac_sequence.signal;
    RACSignal *signalB = @[@6, @7].rac_sequence.signal;
    
    {
        RACSignal *signalC = [signalA combineLatestWith:signalB];
    }
    {
        RACSignal *signalC = [RACSignal combineLatest:@[signalA, signalB]];
    }
    {
        RACSignal *signalC = [RACSignal combineLatest:RACTuplePack(signalA, signalB)];
    }
}


int max(int *array, int count)
{
    if (count < 1)
        return INT_MIN;
    
    if (count == 1)
        return array[0];
    
    int temp = max(array + 1, count - 1);
    
    return array[0] > temp ? array[0] : temp;
}




















