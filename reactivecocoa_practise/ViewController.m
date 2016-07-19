//
//  ViewController.m
//  reactivecocoa_practise
//
//  Created by ZangChengwei on 16/6/19.
//  Copyright © 2016年 ZangChengwei. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa.h>
#import <Masonry.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *grid;
@property (weak, nonatomic) IBOutlet UIButton *autoRunBtn;
@property (weak, nonatomic) IBOutlet UIButton *oneStepBtn;

@end

static int GridXBlocks = 13;
static int GridYBlocks = 7;

typedef NS_ENUM(NSUInteger, SpiritState) {
    SpiritStateAppear,
    SpiritStateRunning,
    SpiritStateDisappear,
};

typedef NS_ENUM(NSUInteger, ControlState) {
    ControlStateStop,
    ControlStateAuto,
    ControlStateOneStep,
};

NSNumber *(^addFunction)(NSNumber *a, NSNumber *b) = ^NSNumber *(NSNumber *a, NSNumber *b) {
    return @(a.integerValue + b.integerValue);
};

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *img1 = [UIImage imageNamed:@"pet1"];
    UIImage *img2 = [UIImage imageNamed:@"pet2"];
    UIImage *img3 = [UIImage imageNamed:@"pet3"];
    
    NSArray *steps = @[RACTuplePack(@1, @0), RACTuplePack(@1, @0),
                       RACTuplePack(@1, @0), RACTuplePack(@0, @1),
                       RACTuplePack(@0, @1), RACTuplePack(@0, @1),
                       RACTuplePack(@1, @0), RACTuplePack(@1, @0),
                       RACTuplePack(@1, @0), RACTuplePack(@1, @0),
                       RACTuplePack(@0, @-1), RACTuplePack(@0, @-1),
                       RACTuplePack(@1, @0), RACTuplePack(@1, @0),
                       RACTuplePack(@1, @0)
                       ];
    
    RACTuple *startBlock = RACTuplePack(@1, @2);
    
    NSInteger spiritCount = steps.count + 1; // 步数 + 1个起始位置
    
    void (^updateXYConstraints)(UIView *view, RACTuple *location) = ^(UIView *view, RACTuple *location) {
        CGFloat width = self.grid.frame.size.width / GridXBlocks;
        CGFloat height = self.grid.frame.size.height / GridYBlocks;
        RACTupleUnpack(NSNumber *locationX, NSNumber *locationY) = location;
        CGFloat x = [locationX floatValue] * width;
        CGFloat y = [locationY floatValue] * height;
        view.frame = CGRectMake(x, y, width, height);
    };
    
    for (int i = 0; i < spiritCount; ++i) {
        UIImageView *spiritView = [[UIImageView alloc] init];
        
        spiritView.tag = i;
        spiritView.animationImages = @[img1, img2, img3];
        spiritView.animationDuration = 1.0;
        spiritView.alpha = 0.0f;
        [self.grid addSubview:spiritView];
        
        updateXYConstraints(spiritView, startBlock);
    }
    
    RACSequence *stepsSequence = steps.rac_sequence;
    
    stepsSequence = [stepsSequence scanWithStart:startBlock reduce:^id(RACTuple *running, RACTuple *next) {
        RACTupleUnpack(NSNumber *x1, NSNumber *y1) = running;
        RACTupleUnpack(NSNumber *x2, NSNumber *y2) = next;
        return RACTuplePack(addFunction(x1, x2), addFunction(y1, y2));
    }];
    
    RACSignal *stepsSignal = stepsSequence.signal;
    stepsSignal = [[stepsSignal map:^id(id value) {
        return [[RACSignal return:value] delay:1];
    }] concat];
    
    RACSignal *(^newSpiritSignal)(NSNumber *idx) = ^RACSignal *(NSNumber *idx) {
        RACSignal *head = [RACSignal return:RACTuplePack(idx,
                                                         @(SpiritStateAppear),
                                                         startBlock)];
        
        RACSignal *running = [stepsSignal map:^id(RACTuple *xy) {
            return RACTuplePack(idx, @(SpiritStateRunning), xy);
        }];
        
        RACSignal *end = [RACSignal return:RACTuplePack(idx,
                                                        @(SpiritStateDisappear),
                                                        nil)];
    
        return [[head concat:running] concat:end];
    };
    
    RACSignal *timerSignal = [[RACSignal interval:1.5 onScheduler:[RACScheduler mainThreadScheduler]] startWith:nil];
    
    RACSignal *autoBtnClickSignal = [[self.autoRunBtn rac_signalForControlEvents:UIControlEventTouchUpInside] mapReplace:@(ControlStateAuto)];
    RACSignal *oneStepBtnClickSignal = [[self.oneStepBtn rac_signalForControlEvents:UIControlEventTouchUpInside] mapReplace:@(ControlStateOneStep)];
    
    RACSignal *clickSignal = [RACSignal merge:@[autoBtnClickSignal, oneStepBtnClickSignal]];
    
    clickSignal = [clickSignal scanWithStart:@(ControlStateStop) reduce:^id(NSNumber *running, NSNumber *next) {
        if ([running isEqual:next] && [running isEqual:@(ControlStateAuto)]) {
            // 如果上一次和这一次都是auto状态，就转换为stop状态
            return @(ControlStateStop);
        }
        return next;
    }];
    RACSignal *stepSignal = [RACSignal switch:clickSignal
                                        cases:@{@(ControlStateAuto): timerSignal,
                                                @(ControlStateOneStep): [RACSignal return:nil]
                                                }
                                      default:[RACSignal empty]];
    
    
    RACSignal *runSignal = [stepSignal scanWithStart:@-1 reduce:^id(NSNumber *running, id _) {
        NSInteger idx = running.integerValue;
        ++idx;
        if (idx == spiritCount) { idx = 0 ;}
        return @(idx);
    }];
    
    RACSignal *spiritRunSignal = [runSignal flattenMap:newSpiritSignal];
    @weakify(self)
    [[spiritRunSignal deliverOnMainThread] subscribeNext:^(RACTuple *info) {
        @strongify(self)
        RACTupleUnpack(NSNumber *idx, NSNumber *state, RACTuple *xy) = info;
        SpiritState stateValue = state.unsignedIntegerValue;
        NSInteger idxValue = idx.integerValue;
        UIImageView *spirit = [self.grid viewWithTag:idxValue];
        
        switch (stateValue) {
            case SpiritStateAppear:
            {
                updateXYConstraints(spirit, xy);
                [UIView animateWithDuration:1 animations:^{
                    spirit.alpha = 1.0f;
                }];
                [spirit startAnimating];
            }
                break;
            case SpiritStateRunning:
            {
                
                [UIView animateWithDuration:1 animations:^{
                    updateXYConstraints(spirit, xy);
                }];
            }
                break;
            case SpiritStateDisappear:
            {
                [UIView animateWithDuration:1 animations:^{
                    spirit.alpha = 0.0f;
                } completion:^(BOOL finished) {
                    [spirit stopAnimating];
                }];
                
            }
                break;
            default:
                break;
        }
        
        
    }];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
