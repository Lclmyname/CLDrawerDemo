//
//  CLDrawerViewController.h
//  CLDrawer
//
//  Created by apple on 16/10/31.
//  Copyright © 2016年 刘朝龙. All rights reserved.
//

#import "ViewController.h"

@interface CLDrawerViewController : ViewController

/** --TODO待添加功能[添加配置属性,诸如:抽屉宽度,缩放比例等]*/
@property (nonatomic, assign, readwrite) CGFloat leftMenuWidth;
@property (nonatomic, assign, readwrite) CGFloat rightMenuWidth;
@property (nonatomic, assign, readwrite) CGFloat scaleLevel;

- (instancetype)initDrawerViewController:(UIViewController *)drawerViewController leftMenuController:(UIViewController *)leftMenuController rightMenuController:(UIViewController *)rightMenuController;
+ (instancetype)drawerViewController:(UIViewController *)drawerViewController leftMenuController:(UIViewController *)leftMenuController rightMenuController:(UIViewController *)rightMenuController;

@end
