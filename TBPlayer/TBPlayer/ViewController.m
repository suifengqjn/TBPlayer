//
//  ViewController.m
//  TBPlayer
//
//  Created by qianjianeng on 16/1/31.
//  Copyright © 2016年 SF. All rights reserved.
//

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
    


}


- (IBAction)button:(UIButton *)sender {
    
    avplayerVC *vc = [avplayerVC new];
    
    [self presentViewController:vc animated:NO completion:nil];
    
    
    
    
}




@end
