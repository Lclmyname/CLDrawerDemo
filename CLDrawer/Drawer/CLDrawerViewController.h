//
//  CLDrawerViewController.h
//  CLDrawer
//
//  Created by apple on 16/10/31.
//  Copyright © 2016年 刘朝龙. All rights reserved.
//

#import "ViewController.h"

@interface CLDrawerViewController : ViewController

- (instancetype)initDrawerViewController:(UIViewController *)drawerViewController leftMenuController:(UIViewController *)leftMenuController rightMenuController:(UIViewController *)rightMenuController;
+ (instancetype)drawerViewController:(UIViewController *)drawerViewController leftMenuController:(UIViewController *)leftMenuController rightMenuController:(UIViewController *)rightMenuController;

@end
