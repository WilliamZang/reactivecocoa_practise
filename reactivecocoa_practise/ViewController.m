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
    
    RACSignal *spiritRunSignal = nil;
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
