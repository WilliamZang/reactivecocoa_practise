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
        NSURLSessionDataTask *op = [manager GET:url parameters:@{@"a": @"b"} progress:^(NSProgress * _Nonnull downloadProgress) {
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

@end

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
    
    RACSignal *statLoadSignal = [webViewDelegate rac_signalForSelector:@selector(webViewDidStartLoad:) fromProtocol:@protocol(UIWebViewDelegate)];
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
