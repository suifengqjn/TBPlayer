//
//  ViewController.m
//  TBPlayer
//
//  Created by qianjianeng on 16/1/31.
//  Copyright © 2016年 SF. All rights reserved.
//
//// github地址：https://github.com/suifengqjn/TBPlayer

#import "ViewController.h"
#import "TBPlayer.h"
#import "XCHudHelper.h"
#import "avplayerVC.h"

@interface ViewController ()



@end

@implementation ViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100, 100, 100, 100);
    button.center = self.view.center;
    [button setTitle:@"播放" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor darkGrayColor];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(ButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];

}

- (void)ButtonClick
{
    avplayerVC *vc = [avplayerVC new];
    
    [self presentViewController:vc animated:NO completion:nil];
}





@end
