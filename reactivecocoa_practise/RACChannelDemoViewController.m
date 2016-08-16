//
//  RACChannelDemoViewController.m
//  reactivecocoa_practise
//
//  Created by ZangChengwei on 16/8/11.
//  Copyright © 2016年 ZangChengwei. All rights reserved.
//

#import "RACChannelDemoViewController.h"
#import <ReactiveCocoa.h>
@interface RACChannelDemoViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation RACChannelDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    RACChannelTerminal *terminal =  self.textField.rac_newTextChannel;
    
    [[terminal map:^id(NSString *value) {
        const char *str = [value UTF8String];
        char newStr[15] = {0};
        int count = 0;
        for (unsigned int i = 0; i < value.length; ++i) {
            const char c = str[i];
            if (c <= '9' && c >= '0') {
                if (count == 4
                    || count == 9) {
                    newStr[count] = '-';
                    ++count;
                }
                newStr[count] = c;
                ++count;
                
                if (count >= 14) {
                    break;
                }
            }
        }
        NSString *newString = [NSString stringWithUTF8String:newStr];
        return newString;
    }] subscribe:terminal];
    
    
}

@end
