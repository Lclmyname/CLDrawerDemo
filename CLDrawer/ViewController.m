//
//  ViewController.m
//  CLDrawer
//
//  Created by apple on 16/10/31.
//  Copyright © 2016年 刘朝龙. All rights reserved.
//

#import "ViewController.h"
#import "CLDrawerViewController.h"

#import "OneViewController.h"
#import "TwoViewController.h"
#import "ThreeViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchAction:(id)sender {
    CLDrawerViewController *drawerVC = [CLDrawerViewController drawerViewController:[[OneViewController alloc] init] leftMenuController:[[TwoViewController alloc] init] rightMenuController:[[ThreeViewController alloc] init]];
    [self.navigationController pushViewController:drawerVC animated:YES];
}

@end
