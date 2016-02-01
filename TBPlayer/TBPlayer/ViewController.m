//
//  ViewController.m
//  TBPlayer
//
//  Created by qianjianeng on 16/1/31.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "ViewController.h"
#import "TBPlayer.h"

@interface ViewController ()

@property (nonatomic, weak) TBPlayer *player;
@end

@implementation ViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    NSString *url = [[NSBundle mainBundle] pathForResource:@"112" ofType:@"mp4"];
    
     [[TBPlayer sharedInstance] playWithUrl:[NSURL fileURLWithPath:url] showView:self.view];


}
- (IBAction)button:(UIButton *)sender {
    [[TBPlayer sharedInstance] seekToTime:20.0];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
