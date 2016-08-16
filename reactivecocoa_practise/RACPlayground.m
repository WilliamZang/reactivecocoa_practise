//
//  RACPlayground.m
//  reactivecocoa_practise
//
//  Created by ZangChengwei on 16/6/19.
//  Copyright © 2016年 ZangChengwei. All rights reserved.
//

#import "RACPlayground.h"
#import <ReactiveCocoa.h>
#import <AFNetworking.h>
#import <UIKit/UIKit.h>

void rac_playground()
{
    RACSignal *signal = [RACSignal return:@1];
    [signal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
}

void asyncFeature()
{
    NSURL *baseURL = [NSURL URLWithString:@"http://someURL/"];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    
    [manager GET:@"somePath" parameters:@{@"a": @"b"} progress:^(NSProgress * _Nonnull downloadProgress) {
        // 进度
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        // 成功
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // 失败
    }];
    
    
}

typedef NS_ENUM(NSUInteger, RequestState) {
    RequestStateProgress,
    RequestStateResponse,
};
RACSignal *asyncGet(NSString *url)
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURL *baseURL = [NSURL URLWithString:@"http://someURL/"];
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
        NSURLSessionDataTask *op = [manager GET:url
                                     parameters:@{@"a": @"b"}
                                       progress:^(NSProgress * _Nonnull downloadProgress) {
            [subscriber sendNext:RACTuplePack(@(RequestStateProgress), downloadProgress)];
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [subscriber sendNext:RACTuplePack(@(RequestStateResponse), responseObject)];
            [subscriber sendCompleted];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [subscriber sendError:error];
        }];
        return [RACDisposable disposableWithBlock:^{
            if (op.state != NSURLSessionTaskStateCanceling
                && op.state != NSURLSessionTaskStateCompleted) {
                [op cancel];
            }
        }];
    }];
}
@interface SomeObjClass : NSObject <UIWebViewDelegate>

- (void)onButtonClick:(UIButton *)button;

@property (nonatomic, strong) id someProp;
@property (nonatomic, weak) id someOtherProp;

@end

@implementation SomeObjClass

- (void)onButtonClick:(UIButton *)button
{
    // something todo
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    // something todo
}

- (void)noBlockRetain
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.someProp = @5;
    });
}

- (void)retainCycleWhenCreate
{
    self.someProp = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"self is %@", self);
        [subscriber sendNext:self.someOtherProp];
        [subscriber sendCompleted];
        return nil;
    }];
    
    self.someProp = [RACSignal return:self];
    
    self.someProp = [[RACSignal return:@1] map:^id(id value) {
        return [NSString stringWithFormat:@"%@%@", self, value];
    }];
}

- (RACSignal *)makeNewSignal
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:self.someProp];
        [subscriber sendNext:self.someOtherProp];
        [subscriber sendCompleted];
        return nil;
    }];
}

- (void)retainCycleWhenSubscribe
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        self.someOtherProp = x;
    }];
    self.someProp = button;
}

- (void)noReatinCycleWhenSubscribe
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        [subscriber sendCompleted];
        return nil;
    }];
    self.someProp = signal;
    
    [signal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
}

- (void)badObserveMarco
{
    SomeObjClass *someOther = [SomeObjClass new];
    
    RACSignal *signal = [[RACSignal return:@1] flattenMap:^RACStream *(id value) {
        return RACObserve(someOther, someProp);
    }];
    self.someProp = signal;
    
}

@end

void retainCycle()
{
    SomeObjClass *a = [SomeObjClass new];
    SomeObjClass *b = [SomeObjClass new];
    a.someProp = b;
    b.someProp = a;

    
}

void blockRetainCycle()
{
    SomeObjClass *a = [SomeObjClass new];
    a.someProp = ^ {
        NSLog(@"%@", a);
    };
}

void noRetainCycle()
{
    SomeObjClass *a = [SomeObjClass new];
    SomeObjClass *b = [SomeObjClass new];
    a.someProp = b;
    b.someOtherProp = a;

}


void noBlockRetainCycle()
{
    SomeObjClass *a = [SomeObjClass new];
    __weak SomeObjClass *weakA = a;
    a.someProp = ^ {
        NSLog(@"%@", weakA);
    };
    
    
}



void breakRetainCycle()
{
    SomeObjClass *a = [SomeObjClass new];
    SomeObjClass *b = [SomeObjClass new];
    a.someProp = b;
    b.someProp = a;

    a.someProp = nil;
    
    a.someProp = ^ {
        NSLog(@"%@", a);
    };
    
    a.someProp = nil;
}

void useWeakifyStrongify()
{
    SomeObjClass *a = [SomeObjClass new];
    @weakify(a)
    a.someProp = ^ {
        NSLog(@"%@", a);
        @strongify(a)
        NSLog(@"%@", a);
    };
}

void nestedBlocksStrongify()
{
    SomeObjClass *a = [SomeObjClass new];
    @weakify(a)
    a.someProp = ^ {
        @strongify(a)
        SomeObjClass *b = [SomeObjClass new];
        a.someProp = ^{
            a.someOtherProp = b;
        };
    };
    
}

void eventFeature()
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    SomeObjClass *someTarget = nil;
    
    [button addTarget:someTarget action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIWebView *webView = nil;
    
    webView.delegate = someTarget;
    
    
}

void eventFeatureSignal()
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIWebView *webView = nil;
    
    RACSignal *clickSignal = [button rac_signalForControlEvents:UIControlEventTouchUpInside];
    
    NSObject *webViewDelegate = [[NSObject alloc] init];
    webView.delegate = (id<UIWebViewDelegate>)webViewDelegate;
    
    RACSignal *statLoadSignal = [webViewDelegate rac_signalForSelector:@selector(webViewDidStartLoad:)
                                                          fromProtocol:@protocol(UIWebViewDelegate)];
}




@interface SomeViewController : UIViewController
@property (nonatomic, copy) NSString *data;
@property (nonatomic, assign) NSInteger totalCount;
@end

@implementation SomeViewController

- (void)viewDidLoad
{
    // something todo
    [self addObserver:self forKeyPath:@"data" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
}

- (void)viewDidAppear:(BOOL)animated
{
    // something todo
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    // something todo
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"data"];
}

- (void)aop
{
    RACSignal *dataSignal = RACObserve(self, data);
    RACSignal *appearSignal = [self rac_signalForSelector:@selector(viewWillAppear:)];
}
- (RACSignal *)someMethod:(id)x
{
    return nil;
}
@end

void badCase1()
{
    RACSignal *signal = nil; // someSignal
    id self;
    [signal subscribeNext:^(NSString *x) {
        RACSignal *signalB = [self someMethod:x];
        [signalB subscribeNext:^(id x) {
           // blablabla
        }];
    }];
}

void badCase2()
{
    RACSignal *signal = nil; // someSignal
    SomeViewController *self = nil;
    
    
    [signal filter:^BOOL(id x) {
        self.data = x;
        return [self someMethod:x] != nil;
    }];
    
    [signal map:^id(id value) {
        return [NSString stringWithFormat:@"%@ -- %@", self.data, value];
    }];
    
    [signal map:^id(id value) {
        NSString *str = [NSString stringWithFormat:@"%ld+%@", (long)self.totalCount, value];
        self.totalCount ++;
        return str;
    }];
    
}

void useCommandProcessError()
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        if (rand() > 0.5) {
            [subscriber sendError:[NSError errorWithDomain:@"" code:1 userInfo:nil]];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *signal2 = [RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]];
    [[signal2 flattenMap:^RACStream *(id value) {
        return signal;
    }] subscribeNext:^(id x) {
        // ?
    }];
    
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return signal;
    }];
    
    [command rac_liftSelector:@selector(execute:) withSignals:signal2, nil];
    
    [[command.executionSignals switchToLatest] subscribeNext:^(id x) {
        
    }];
    
    [command.errors subscribeNext:^(id x) {
        
    }];
}
