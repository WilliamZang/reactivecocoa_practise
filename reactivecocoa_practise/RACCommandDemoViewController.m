//
//  ViewController.m
//  reactivecocoa_practise
//
//  Created by ZangChengwei on 16/6/19.
//  Copyright © 2016年 ZangChengwei. All rights reserved.
//

#import "RACCommandDemoViewController.h"
#import <ReactiveCocoa.h>
@interface RACCommandDemoViewController ()
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UIButton *fetchCodeBtn;

@end

@implementation RACCommandDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    RACSignal *(^counterSignal)(NSNumber *count) = ^RACSignal *(NSNumber *count) {
        RACSignal *timerSignal = [RACSignal interval:1 onScheduler:RACScheduler.mainThreadScheduler];
        RACSignal *counterSignal = [[timerSignal scanWithStart:count reduce:^id(NSNumber *running, id _) {
            return @(running.integerValue - 1);
        }] takeUntilBlock:^BOOL(NSNumber *x) {
            return x.integerValue < 0;
        }];
        
        return [counterSignal startWith:count];
    };
    
    RACSignal *enableSignal = [self.phoneNumberTextField.rac_textSignal map:^id(NSString *value) {
        return @(value.length == 11);
    }];
    
    RACCommand *command = [[RACCommand alloc] initWithEnabled:enableSignal signalBlock:^RACSignal *(id input) {
        return counterSignal(@10);
    }];
    
    RACSignal *counterStringSignal = [[command.executionSignals switchToLatest] map:^id(NSNumber *value) {
        return [value stringValue];
    }];
    
    RACSignal *resetStringSignal = [[command.executing filter:^BOOL(NSNumber *value) {
        return !value.boolValue;
    }] mapReplace:@"点击获得验证码"];
    
    
    [self.fetchCodeBtn rac_liftSelector:@selector(setTitle:forState:)
                            withSignals:[RACSignal merge:@[counterStringSignal, resetStringSignal]],
                    [RACSignal return:@(UIControlStateNormal)], nil];
    /*
    @weakify(self)
    [[RACSignal merge:@[counterSignal, resetStringSignal]] subscribeNext:^(id x) {
        @strongify(self)
        [self.fetchCodeBtn setTitle:x forState:UIControlStateNormal];
    }];
     */
    
    self.fetchCodeBtn.rac_command = command;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
