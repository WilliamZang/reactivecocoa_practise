//
//  ViewController.m
//  reactivecocoa_practise
//
//  Created by ZangChengwei on 16/6/19.
//  Copyright © 2016年 ZangChengwei. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *spirit;
@property (weak, nonatomic) IBOutlet UIView *grid;
@property (weak, nonatomic) IBOutlet UIButton *autoRunBtn;
@property (weak, nonatomic) IBOutlet UIButton *oneStepBtn;

@end

static int GridXBlocks = 13;
static int GridYBlocks = 7;


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *img1 = [UIImage imageNamed:@"pet1"];
    UIImage *img2 = [UIImage imageNamed:@"pet2"];
    UIImage *img3 = [UIImage imageNamed:@"pet3"];
    
    self.spirit.animationImages = @[img1, img2, img3];
    self.spirit.animationDuration = 1.0;
    [self.spirit startAnimating];
    
    RACSignal *stepSignal = @[RACTuplePack(@1, @0), RACTuplePack(@1, @0),
                              RACTuplePack(@1, @0), RACTuplePack(@0, @1),
                              RACTuplePack(@0, @1), RACTuplePack(@0, @1),
                              RACTuplePack(@1, @0), RACTuplePack(@1, @0),
                              RACTuplePack(@1, @0), RACTuplePack(@1, @0),
                              RACTuplePack(@0, @-1), RACTuplePack(@0, @-1),
                              RACTuplePack(@1, @0), RACTuplePack(@1, @0),
                              RACTuplePack(@1, @0)
                              ].rac_sequence.signal;
    
    RACTuple *startBlock = RACTuplePack(@1, @2);
    
    // 得到未来的所有的步骤的NSArray
    RACSignal *stepsSignal = [[[stepSignal scanWithStart:startBlock reduce:^id(RACTuple *last, RACTuple *direction) {
        RACTupleUnpack(NSNumber *x1, NSNumber *y1) = last;
        RACTupleUnpack(NSNumber *x2, NSNumber *y2) = direction;
        NSNumber *x = @(x1.integerValue + x2.integerValue);
        NSNumber *y = @(y1.integerValue + y2.integerValue);
        return RACTuplePack(x, y);
    }] startWith:startBlock] collect];
    
    // 两种点击信号
    RACSignal *autoClickSignal = [self.autoRunBtn rac_signalForControlEvents:UIControlEventTouchUpInside];
    RACSignal *oneStepClickSignal = [self.oneStepBtn rac_signalForControlEvents:UIControlEventTouchUpInside];
    
    // 单元信号，用来模拟移动一步
    RACSignal *idSignal = [RACSignal return: nil];
    // 自动信号，用来模拟1s移动一步，注意startWith减少第一秒的等待
    RACSignal *timerSignal = [[RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]] startWith:nil];
    
    // 高阶信号的变换，第三节课会讲到，这里可以用下面注释的两句
    RACSignal *oneStepSignal = [[[autoClickSignal mapReplace:timerSignal]
                                 merge:[oneStepClickSignal mapReplace:idSignal]]
                                switchToLatest];
    //RACSignal *oneStepSignal = oneStepClickSignal;
    // 这里实现一个第一次点击后，就接上一个timer信号的信号，来实现自动信号
    //RACSignal *oneStepSignal = [[autoClickSignal take:1] concat:[timerSignal skip:1]];
    
    // 对stepsSignal进行采样就可以多次得到离散的steps结果，但是由于stepsSignal很快就complete了，所以先链接一个无限信号
    // 之后，利用scan reduce进行一个0 ~ steps.count-1 的循环取值，就得到结果了
    RACSignal *spiritRunSignal = [[[[stepsSignal concat:[RACSignal never]] sample:oneStepSignal]
                                  scanWithStart:RACTuplePack(nil, @0) reduce:^id(RACTuple *value, NSArray *steps) {
        NSNumber *idx = value.second;
        NSInteger nextIdx = (idx.integerValue + 1) % steps.count;
        return RACTuplePack(steps[nextIdx], @(nextIdx));
    }] reduceEach:^id(NSArray *steps, id _){
        return steps;
    }];
    
    

    @weakify(self)
    [spiritRunSignal subscribeNext:^(RACTuple *xy) {
        @strongify(self)
        RACTupleUnpack(NSNumber *x, NSNumber *y) = xy;
        CGFloat spiritHeight = self.grid.frame.size.height / GridYBlocks;
        CGFloat spiritWidth = self.grid.frame.size.width / GridXBlocks;
        [UIView animateWithDuration:1 animations:^{
            self.spirit.frame = CGRectMake(spiritWidth * x.integerValue, spiritHeight * y.integerValue, spiritWidth, spiritHeight);
        }];
        
    }];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
