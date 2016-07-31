//
//  RACPlayground.m
//  reactivecocoa_practise
//
//  Created by ZangChengwei on 16/6/19.
//  Copyright © 2016年 ZangChengwei. All rights reserved.
//

#import "RACPlayground.h"
#import <ReactiveCocoa.h>

@implementation RACSignal (Private)

- (RACSignal *)myMap_:(id (^)(id))map
{
    NSCParameterAssert(map != nil);
    return [RACSignal createSignal:
            ^RACDisposable *(id<RACSubscriber> su) {
        [self subscribeNext:^(id x) {
            [su sendNext:map(x)];
        } error:^(NSError *error) {
            [su sendError:error];
        } completed:^{
            [su sendCompleted];
        }];
        return nil;
    }];
}

- (RACSignal *)myMap2_:(id (^)(id))map
{
    @weakify(self)
    NSCParameterAssert(map != nil);
    return [RACSignal createSignal:
            ^RACDisposable *(id<RACSubscriber> su) {
        @strongify(self)
        [self subscribeNext:^(id x) {
            [su sendNext:map(x)];
        } error:^(NSError *error) {
            [su sendError:error];
        } completed:^{
            [su sendCompleted];
        }];
        return nil;
    }];
}

+ (RACSignal *)myMerge_:(id<NSFastEnumeration>)signals
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        for (RACSignal *signal in signals) {
            [signal subscribeNext:^(id x) {
                [subscriber sendNext:x];
            } error:^(NSError *error) {
                [subscriber sendError:error];
            } completed:^{
                [subscriber sendCompleted];
            }];
        }
        return nil;
    }];
}

+ (RACSignal *)myMerge:(id<NSFastEnumeration>)signals
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        RACCompoundDisposable *mainDisposable = [[RACCompoundDisposable alloc] init];
        for (RACSignal *signal in signals) {
            [mainDisposable addDisposable:[signal subscribeNext:^(id x) {
                [subscriber sendNext:x];
            } error:^(NSError *error) {
                [subscriber sendError:error];
                [mainDisposable dispose];
            } completed:^{
                [subscriber sendCompleted];
                [mainDisposable dispose];
            }]];
        }
        return mainDisposable;
    }];
}

- (RACSignal *)myConcat:(RACSignal *)signal
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        RACSerialDisposable *mainDisposable = [[RACSerialDisposable alloc] init];
        mainDisposable.disposable = [self subscribeNext:^(id x) {
            [subscriber sendNext:x];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            mainDisposable.disposable = [signal subscribe:subscriber];
        }];
        return mainDisposable;
    }];
}
@end



void subscribe()
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        [subscriber sendNext:@2];
        [subscriber sendCompleted];
        return nil;
    }];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"next: %@", x);
    } error:^(NSError *error) {
        NSLog(@"error: %@", error);
    } completed:^{
        NSLog(@"complete");
    }];
}

void subscribeSubject()
{
    RACSubject *subject = [RACSubject subject];
    
    [subject subscribeNext:^(id x) {
        NSLog(@"Subscriber 1 receive next: %@", x);
    } error:^(NSError *error) {
        NSLog(@"Subscriber 1 receive error: %@", error);
    } completed:^{
        NSLog(@"Subscriber 1 receive complete");
    }];
    
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendCompleted];
    [subject sendNext:@3];
}

void delayTask()
{
    NSString *someStr = @"someStr";
    
    [[RACScheduler scheduler] afterDelay:1 schedule:^{
        NSLog(@"%@", someStr);
    }];
}

void delayTask2()
{
    NSString *someStr = @"someStr";
    NSString *someOtherStr = @"someOtherStr";
    
    [RACScheduler.mainThreadScheduler afterDelay:1 schedule:^{
        NSLog(@"%@", someStr);
        NSString *innerStr = @"innerStr";
        
        [RACScheduler.mainThreadScheduler afterDelay:1 schedule:^{
            NSLog(@"%@ && %@", someOtherStr, innerStr);
        }];
    }];
}

void coldSignalDelaySubscribe()
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        [subscriber sendNext:@2];
        [subscriber sendCompleted];
        return nil;
    }];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"Subscriber 1 receive next: %@", x);
    } error:^(NSError *error) {
        NSLog(@"Subscriber 1 receive error: %@", error);
    } completed:^{
        NSLog(@"Subscriber 1 receive complete");
    }];
    
    [RACScheduler.mainThreadScheduler afterDelay:1 schedule:^{
        [signal subscribeNext:^(id x) {
            NSLog(@"Subscriber 2 receive next: %@", x);
        } error:^(NSError *error) {
            NSLog(@"Subscriber 2 receive error: %@", error);
        } completed:^{
            NSLog(@"Subscriber 2 receive complete");
        }];
    }];
    
}

void hotSignalDelaySubscribe()
{
    RACSubject *subject = [RACReplaySubject subject];
    
    [subject subscribeNext:^(id x) {
        NSLog(@"Subscriber 1 receive next: %@", x);
    } error:^(NSError *error) {
        NSLog(@"Subscriber 1 receive error: %@", error);
    } completed:^{
        NSLog(@"Subscriber 1 receive complete");
    }];
    
    [RACScheduler.mainThreadScheduler afterDelay:1 schedule:^{
        [subject subscribeNext:^(id x) {
            NSLog(@"Subscriber 2 receive next: %@", x);
        } error:^(NSError *error) {
            NSLog(@"Subscriber 2 receive error: %@", error);
        } completed:^{
            NSLog(@"Subscriber 2 receive complete");
        }];
    }];
    
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendCompleted];
}

void coldSignalDelaySend()
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [RACScheduler.mainThreadScheduler afterDelay:1 schedule:^{
            [subscriber sendNext:@1];
            [subscriber sendNext:@2];
        }];
        [RACScheduler.mainThreadScheduler afterDelay:2 schedule:^{
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"Subscriber 1 receive next: %@", x);
    } error:^(NSError *error) {
        NSLog(@"Subscriber 1 receive error: %@", error);
    } completed:^{
        NSLog(@"Subscriber 1 receive complete");
    }];
}

void hotSignalDelaySend()
{
    RACSubject *subject = [RACSubject subject];
    
    [subject subscribeNext:^(id x) {
        NSLog(@"Subscriber 1 receive next: %@", x);
    } error:^(NSError *error) {
        NSLog(@"Subscriber 1 receive error: %@", error);
    } completed:^{
        NSLog(@"Subscriber 1 receive complete");
    }];
    
    [RACScheduler.mainThreadScheduler afterDelay:1 schedule:^{
        [subject sendNext:@1];
        [subject sendNext:@2];
        [subject sendCompleted];
    }];
}


void subscirbeSignalWithDispose()
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        [subscriber sendNext:@2];
        [RACScheduler.mainThreadScheduler schedule:^{
            [subscriber sendCompleted];
        }];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"inner disposed");
        }];
    }];
    
    RACDisposable *disposable = [signal subscribeNext:^(id x) {
        NSLog(@"next: %@", x);
    } error:^(NSError *error) {
        NSLog(@"error: %@", error);
    } completed:^{
        NSLog(@"complete");
    }];
    NSLog(@"Disposed ? %@", disposable.disposed ? @"YES" : @"NO");
    [disposable dispose];
    NSLog(@"Disposed ? %@", disposable.disposed ? @"YES" : @"NO");
}

void signalTransform()
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> s) {
        [s sendNext:@1];
        [RACScheduler.mainThreadScheduler afterDelay:1 schedule:^{
            [s sendCompleted];
        }];
        return nil;
    }];
    RACSignal *signal2 = [signal myMap_:^id(NSNumber *value) {
        return @(value.integerValue * 2);
    }];
    [RACScheduler.mainThreadScheduler afterDelay:1 schedule:^{
        [signal2 subscribeNext:^(id x) {
            NSLog(@"Subscriber 1 receive next: %@", x);
        } error:^(NSError *error) {
            NSLog(@"Subscriber 1 receive error: %@", error);
        } completed:^{
            NSLog(@"Subscriber 1 receive complete");
        }];
    }];
}

void disposableCase1()
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        [RACScheduler.mainThreadScheduler afterDelay:2 schedule:^{
            [subscriber sendNext:@2];
            [subscriber sendCompleted];
        }];
        
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"dispose!!!");
        }];
    }];
    
    RACDisposable *disposable = [signal subscribeNext:^(id x) {
        NSLog(@"next: %@", x);
    } completed:^{
        NSLog(@"complete");
    }];
    
    [RACScheduler.mainThreadScheduler afterDelay:1 schedule:^{
        [disposable dispose];
    }];
}

void disposableCase2()
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        RACDisposable *disposable1 = [RACScheduler.mainThreadScheduler afterDelay:2 schedule:^{
            [subscriber sendNext:@2];
            
        }];
        
        RACDisposable *disposable2 = [RACScheduler.mainThreadScheduler afterDelay:2 schedule:^{
            [subscriber sendCompleted];
        }];
        
        
        return [RACDisposable disposableWithBlock:^{
            [disposable1 dispose];
            [disposable2 dispose];
            NSLog(@"dispose!!!");
        }];
    }];
    
    RACDisposable *disposable = [signal subscribeNext:^(id x) {
        NSLog(@"next: %@", x);
    } completed:^{
        NSLog(@"complete");
    }];
    
    [RACScheduler.mainThreadScheduler afterDelay:1 schedule:^{
        [disposable dispose];
    }];
}

@interface SomeClass : NSObject

@property (nonatomic, strong) id someProp;

@end

void scopedDisposable()
{
    SomeClass *self = nil;
    
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        RACDisposable *disposable1 = [RACScheduler.mainThreadScheduler afterDelay:2 schedule:^{
            [subscriber sendNext:@2];
            
        }];
        RACDisposable *disposable2 = [RACScheduler.mainThreadScheduler afterDelay:2 schedule:^{
            [subscriber sendCompleted];
        }];
        return [RACDisposable disposableWithBlock:^{
            [disposable1 dispose];
            [disposable2 dispose];
            NSLog(@"dispose!!!");
        }];
    }];
    RACDisposable *disposable = [signal subscribeNext:^(id x) {
        NSLog(@"next: %@", x);
    } completed:^{
        NSLog(@"complete");
    }];
    self.someProp = disposable.asScopedDisposable;
    
}
void rac_playground()
{
    RACSignal *signal = [RACSignal return:@1];
    [signal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    hotSignalDelaySubscribe();
}