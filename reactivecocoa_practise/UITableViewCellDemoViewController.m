//
//  UITableViewCellDemoViewController.m
//  reactivecocoa_practise
//
//  Created by ZangChengwei on 16/8/15.
//  Copyright © 2016年 ZangChengwei. All rights reserved.
//

#import "UITableViewCellDemoViewController.h"
#import <ReactiveCocoa.h>

@implementation UITableViewCellDemoViewController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    RACSignal *signal = [RACSignal interval:1 onScheduler:RACScheduler.mainThreadScheduler];
    RACSignal *counterSignal = [[[signal scanWithStart:@0 reduce:^id(NSNumber *running, id next) {
        return @(running.integerValue + 1);
    }] map:^id(NSNumber *value) {
        return value.stringValue;
    }] startWith:@"0"];
    RAC(cell, detailTextLabel.text) = [counterSignal takeUntil:cell.rac_prepareForReuseSignal];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 100;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
@end
