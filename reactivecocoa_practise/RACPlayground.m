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

void ifThenElse()
{
    RACSignal *signalA = nil;
    RACSignal *signalTrue = nil;
    RACSignal *signalFalse = nil;
    
    RACSignal *signalB = [RACSignal if: signalA
                                  then: signalTrue
                                  else: signalFalse];
}

void timerSignal()
{
    RACSignal *signal = @[@1, @3, @7,
                          @9, @8].rac_sequence.signal;
    
    RACSignal *timerSignal = [[signal map:^id(id value) {
        return [[RACSignal return:value] delay:1];
    }] concat];
    
}

void mapThenFlatten()
{
    RACSignal *signal = @[@1, @2, @3].rac_sequence.signal;
    
    RACSignal *mappedSignal = [[signal map:^id(NSNumber *value) {
        return [[[RACSignal return:value] repeat]
                take:value.integerValue];
    }] flatten];
}

void musicExample()
{
    RACSignal *signal = @[@"♪5", @"♬1", @"♬2", @"♬3", @"♩4"]
                            .rac_sequence
                            .signal;
    NSDictionary *toneLengthMap = @{@"♩": @0.5,
                                    @"♪": @0.25,
                                    @"♬": @0.125};
    RACSignal *mappedSignal = [[signal map:^id(NSString *value) {
        NSString *tone = [value substringFromIndex:1];
        NSString *length = [value substringToIndex:1];
        NSNumber *toneValue = @(tone.integerValue);
        NSNumber *toneLength = toneLengthMap[length];
        return [[RACSignal return:toneValue]
                concat:[[RACSignal empty]
                        delay: toneLength.doubleValue]];
    }] concat];
}

void valueToError()
{
    RACSignal *signal = @[@1, @2, @3, @0].rac_sequence.signal;
    
    RACSignal *mappedSignal = [[signal map:^id(NSNumber *value) {
        if (value.integerValue == 0) {
            return [RACSignal error:[NSError errorWithDomain:@"0"
                                                        code:0
                                                    userInfo:nil]];
        } else {
            return [RACSignal return:value];
        }
    }] flatten];
}

void flattenMap()
{
    RACSignal *signal = @[@1, @2, @3, @0].rac_sequence.signal;
    
    RACSignal *flatten = [signal flattenMap:^RACStream *(RACSignal *value) {
        return value;
    }];
    
    RACSignal *map = [signal flattenMap:^RACStream *(id value) {
        id anotherValue = value; // map here!
        return [RACSignal return: anotherValue];
    }];
    
    RACSignal *filter = [signal flattenMap:^RACStream *(id value) {
        BOOL filter = (value == nil); // filter here!
        return filter ? [RACSignal empty] : [RACSignal return:value];
    }];
    
}

void serialSyncProcess()
{
    NSError *someError = nil;
    RACSignal *signal = [RACSignal return:@"http://xx.com/a"];
    
    RACSignal *getSignal = [signal flattenMap:
                            ^RACStream *(NSString *url) {
        NSURLRequest *request = [NSURLRequest requestWithURL:
                                 [NSURL URLWithString:url]];
        return [NSURLConnection rac_sendAsynchronousRequest:request];
    }];
    
    RACSignal *jsonSignal = [getSignal flattenMap:
                             ^RACStream *(NSData *data) {
        NSError *error = nil;
        id result = [NSJSONSerialization JSONObjectWithData:data
                                                    options:0
                                                      error:&error];
        return error == nil ? [RACSignal return: result]
                                 : [RACSignal error: error];
    }];
    
    RACSignal *getItemSignal = [jsonSignal flattenMap:
                                ^RACStream *(NSDictionary *value) {
        if (![value isKindOfClass:[NSDictionary class]] ||
            value[@"data.url"] == nil) {
            return [RACSignal error:someError];
        }
        NSURLRequest *anotherRequest = [NSURLRequest requestWithURL:
                                        [NSURL URLWithString:value[@"data.url"]]];
        return [NSURLConnection rac_sendAsynchronousRequest:anotherRequest];
    }];
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
@interface ExampleViewController ()

@property (weak, nonatomic) UIButton *autoRunBtn;
@property (weak, nonatomic) UIButton *oneStepBtn;
@property (weak, nonatomic) UITextField *searchTextField;

@end

@implementation ExampleViewController

- (void)switchToLatestsExample1
{
    RACSignal *autoRunButtonClickSignal = [self.autoRunBtn
                                           rac_signalForControlEvents:UIControlEventTouchUpInside];
    RACSignal *oneStepButtonClickSignal = [self.oneStepBtn
                                           rac_signalForControlEvents:UIControlEventTouchUpInside];
    
    RACSignal *idSignal = [RACSignal return:nil];
    RACSignal *timerSignal = [RACSignal interval:1
                                     onScheduler:[RACScheduler
                                                  mainThreadScheduler]];
    
    autoRunButtonClickSignal = [autoRunButtonClickSignal mapReplace:idSignal];
    oneStepButtonClickSignal = [oneStepButtonClickSignal mapReplace:timerSignal];
    
    RACSignal *controlSignal = [autoRunButtonClickSignal merge:
                                oneStepButtonClickSignal];
    controlSignal = [controlSignal switchToLatest];
}

- (void)switchToLatestsExample2
{
    RACSignal *searchTextSignal = [self.searchTextField rac_textSignal];
    
    RACSignal *requestSignals = [searchTextSignal map:^id(NSString *searchText) {
        NSString *urlString = [NSString stringWithFormat:@"http://xxxx.xxx.xxx/?q=%@", searchText];
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        return [NSURLConnection rac_sendAsynchronousRequest:request];
    }];
    
    requestSignals = [requestSignals switchToLatest];
    
}

@end

@implementation RACSignal (BindImplementation)

- (RACSignal *)take:(NSUInteger)count {
    if (count == 0) return [RACSignal empty];
    
    return [self bind:^{
        __block NSUInteger taken = 0;
        
        return ^ id (id value, BOOL *stop) {
            if (taken < count) {
                ++taken;
                if (taken == count) *stop = YES;
                return [RACSignal return:value];
            } else {
                return nil;
            }
        };
    }];
}

//- (RACSignal *)bind:(RACStreamBindBlock (^)(void))block;
//{
//    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        RACStreamBindBlock bindBlock = block();
//        
//        [self subscribeNext:^(id x) {
//            BOOL stop = NO;
//            RACSignal *signal = (RACSignal *)bindBlock(x, &stop);
//            if (signal == nil || stop) { [subscriber sendCompleted];
//            } else {
//                [signal subscribeNext:^(id x) { [subscriber sendNext:x];
//                } error:^(NSError *error) { [subscriber sendError:error];
//                } completed:^{ }];
//            }
//        } error:^(NSError *error) { [subscriber sendError:error];
//        } completed:^{ [subscriber sendCompleted]; }];
//        return nil;
//    }];
//}
@end