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
    
    RACSequence *stepsSequence = steps.rac_sequence;
    
    NSInteger spiritCount = steps.count + 1; // 步数 + 1个起始位置
    
    void (^updateXYConstraints)(UIView *view, RACTuple *location) = ^(UIView *view, RACTuple *location) {
        CGFloat width = self.grid.frame.size.width / GridXBlocks;
        CGFloat height = self.grid.frame.size.height / GridYBlocks;
        CGFloat x = [location.first floatValue] * width;
        CGFloat y = [location.second floatValue] * height;
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
    
    
    
    
    
    
    
    
    
    
    RACSignal *spiritRunSignal = nil;
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
