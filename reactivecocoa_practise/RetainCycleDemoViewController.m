//
//  RetainCycleDemoViewController.m
//  reactivecocoa_practise
//
//  Created by ZangChengwei on 16/8/12.
//  Copyright © 2016年 ZangChengwei. All rights reserved.
//

#import "RetainCycleDemoViewController.h"
#import <ReactiveCocoa.h>

@interface RetainCycleDemoViewController ()
@property (weak, nonatomic) IBOutlet UIButton *barButton;

@property (nonatomic, copy) NSString *someStringProperty;
@property (nonatomic, strong) RACSignal *signal;

@end

static NSDictionary *globalSelectorHash = nil;
static NSMutableArray *globalArray = nil;

@implementation RetainCycleDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (globalSelectorHash == nil) {
        
        NSArray *selectors = @[
           NSStringFromSelector(@selector(selfWithinBlock)),
           NSStringFromSelector(@selector(memberVariableWithinBlock)),
           NSStringFromSelector(@selector(delayRelease)),
           NSStringFromSelector(@selector(retainedByGlobalObject)),
           NSStringFromSelector(@selector(retainCycleWhenCreatingSignal)),
           NSStringFromSelector(@selector(retainCycleWhenSubscribingSignal))
        ];
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:selectors.count];
        [selectors enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            dictionary[indexPath] = obj;
        }];
        globalSelectorHash = [dictionary copy];
    }
    
    if (globalArray == nil) {
        globalArray = [NSMutableArray array];
    }
    
    UINavigationController *navigationController = self.navigationController;
    @weakify(navigationController)
    [self.rac_willDeallocSignal subscribeCompleted:^{
        @strongify(navigationController)
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"内存释放" message:@"已经成功释放ViewController" preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *_){}]];
        [navigationController presentViewController:controller animated:YES completion:nil];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectorString = globalSelectorHash[indexPath];
    SEL selector = NSSelectorFromString(selectorString);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:selector];
#pragma clang diagnostic pop
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)selfWithinBlock
{
    RACSignal *signal = [RACSignal return:@1];
    [signal subscribeNext:^(id x) {
        NSLog(@"self is %@, next is %@", self, x);
    }];
}

- (void)memberVariableWithinBlock
{
    RACSignal *signal = [self rac_signalForSelector:@selector(viewWillAppear:)];
    [signal subscribeNext:^(id x) {
        NSLog(@"property is %@, next is %@", _someStringProperty, x);
    }];
}

- (void)delayRelease
{
    RACSignal *signal = [[RACSignal return:@1] delay:5];
    [signal subscribeNext:^(id x) {
        NSLog(@"self is %@, next is %@", self, x);
    }];
    
    
    
}

- (void)retainedByGlobalObject
{
    [globalArray removeAllObjects];
    [globalArray addObject:[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"self is %@", self);
        return nil;
    }]];
}

- (void)retainCycleWhenCreatingSignal
{
    self.signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"self is %@", self);
        return nil;
    }];
    
}

- (void)retainCycleWhenSubscribingSignal
{
    [[self.barButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        NSLog(@"self is %@", self);
    }];
}



@end
