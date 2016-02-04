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
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *movePath =  [document stringByAppendingPathComponent:@"保存数据.mp4"];
    
    NSURL *localURL = [NSURL fileURLWithPath:movePath];
    
    NSURL *url2 = [NSURL URLWithString:@"http://zyvideo1.oss-cn-qingdao.aliyuncs.com/zyvd/7c/de/04ec95f4fd42d9d01f63b9683ad0"];
    
    NSURL *url3 = url2;
    [[TBPlayer sharedInstance] playWithUrl:url3 showView:self.view];


}
- (IBAction)button:(UIButton *)sender {
    //[[TBPlayer sharedInstance] seekToTime:20.0];
    
    [XCHudHelper showMessage:@"asd"] ;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
