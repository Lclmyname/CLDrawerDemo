//
//  CLDrawerViewController.m
//  CLDrawer
//
//  Created by apple on 16/10/31.
//  Copyright © 2016年 刘朝龙. All rights reserved.
//

#import "CLDrawerViewController.h"
#define LeftMenuWidth 200
#define RightMenuWidth 80
#define ScaleLevel 0.4

#define LeftScrollX 100
#define RightScrollX ContentWidth - 80

#define ContentWidth     self.view.frame.size.width
#define ContentHeight    self.view.frame.size.height
#define LeftMenuOriginX  -(LeftMenuWidth+((LeftMenuWidth*(1-ScaleLevel))/2))
#define RightMenuOriginX ContentWidth

typedef NS_ENUM(NSInteger, CLScrollDirection) {
    CLScrollDirectionNone,
    CLScrollDirectionLeft,
    CLScrollDirectionRight
};

@interface CLDrawerViewController ()
/** --容器VC */
@property (nonatomic, strong, readwrite) UIViewController *contentVC;
/** --左抽屉VC */
@property (nonatomic, strong, readwrite) UIViewController *leftMenuVC;
/** --右抽屉VC */
@property (nonatomic, strong, readwrite) UIViewController *rightMenuVC;

/** --侧滑方向*/
@property (nonatomic, assign, readwrite) CLScrollDirection scrollDirection;
/** --手指所在位置 */
@property (nonatomic, strong, readwrite) NSNumber *touchPointX;
/** --移动距离*/
@property (nonatomic, assign, readwrite) CGFloat   distanceMove;

/** --清按手势,左右各一个,用以关闭抽屉*/
@property (nonatomic, strong, readwrite) UITapGestureRecognizer *leftCloseTapGestureRecognizer;
@property (nonatomic, strong, readwrite) UITapGestureRecognizer *rightCloseTapGestureRecognizer;
/** --TODO待添加功能[遮罩效果,拖拽过程中有渐变黑色效果]*/
/** --TODO待添加功能[添加配置属性,诸如:抽屉宽度,缩放比例等]*/
/** --TODO待完善功能[将可复用代码模块化,优化代码]*/

@end

@implementation CLDrawerViewController

- (instancetype)initDrawerViewController:(UIViewController *)drawerViewController leftMenuController:(UIViewController *)leftMenuController rightMenuController:(UIViewController *)rightMenuController
{
    if (self = [super init]){
        [self setContentVC:drawerViewController];
        [self setLeftMenuVC:leftMenuController];
        [self setRightMenuVC:rightMenuController];
    }
    return self;
}
+ (instancetype)drawerViewController:(UIViewController *)drawerViewController leftMenuController:(UIViewController *)leftMenuController rightMenuController:(UIViewController *)rightMenuController
{
    CLDrawerViewController *drawerVC = [[CLDrawerViewController alloc] init];
    [drawerVC setContentVC:drawerViewController];
    [drawerVC setLeftMenuVC:leftMenuController];
    [drawerVC setRightMenuVC:rightMenuController];
    return drawerVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupContentViewController];
    [self setupLeftMenuViewController];
    [self setupRightMenuViewController];
    [self setupTapGestureRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 重新设计UI
- (void)setupContentViewController
{
    [self addChildViewController:self.contentVC];
    [self.view addSubview:self.contentVC.view];
    [self.contentVC.view setFrame:self.view.frame];
}
- (void)setupLeftMenuViewController
{
    if (self.leftMenuVC) {
        [self addChildViewController:self.leftMenuVC];
        [self.view addSubview:self.leftMenuVC.view];
        [self.leftMenuVC.view setFrame:CGRectMake(LeftMenuOriginX, ContentHeight*ScaleLevel/2, LeftMenuWidth*ScaleLevel, ContentHeight*ScaleLevel)];
    }
}
- (void)setupRightMenuViewController
{
    if (self.rightMenuVC) {
        [self addChildViewController:self.rightMenuVC];
        [self.view addSubview:self.rightMenuVC.view];
        [self.rightMenuVC.view setFrame:CGRectMake(RightMenuOriginX, 0, RightMenuWidth, ContentHeight)];
    }
}
- (void)setupTapGestureRecognizer
{
    self.leftCloseTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeLeftMenu)];
    self.rightCloseTapGestureRecognizer= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeRightMenu)];
}

#pragma mark -- touch action
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point  = [touch locationInView:self.view];
    
    self.touchPointX = @(point.x);
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point  = [touch locationInView:self.view];
    if (self.touchPointX) {
        /** 判断滑动方向,将左抽屉或者右抽屉拉出来 */
        CGFloat touchPointX = [self.touchPointX floatValue];
        CGFloat diffTouchPointX = point.x - touchPointX;
        if (self.scrollDirection==CLScrollDirectionNone&&touchPointX<LeftScrollX&&diffTouchPointX>0) {
            self.scrollDirection = CLScrollDirectionLeft;
        }else if (self.scrollDirection==CLScrollDirectionNone&&touchPointX>RightScrollX&&diffTouchPointX<0){
            self.scrollDirection = CLScrollDirectionRight;
        }
        /** 判断结束重新修改UI*/
        [self reSetUpUIWithDiffTouchPointX:diffTouchPointX];
    }
    
    self.touchPointX = @(point.x);
    
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches];
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches];
}

#pragma mark -- private method
- (void)deallocData
{
    self.scrollDirection = CLScrollDirectionNone;
    self.touchPointX = nil;
    self.distanceMove= 0;
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches
{
    UITouch *touch = [touches anyObject];
    CGPoint point  = [touch locationInView:self.view];
    CGFloat touchPointX = [self.touchPointX floatValue];
    CGFloat diffTouchPointX = point.x - touchPointX;
    /** 判断结束重新修改UI*/
    [self reSetUpUIWithDiffTouchPointX:diffTouchPointX];
    // [self deallocData];
    [self setupEndUI];
}
- (void)showLeftMenu
{
    self.distanceMove  = LeftMenuWidth;
    CGRect contentRect = self.contentVC.view.frame;
    CGRect leftMenuRect = self.leftMenuVC.view.frame;
    
    contentRect.origin.x   = LeftMenuWidth+(ContentWidth-ContentWidth*ScaleLevel)/2;
    contentRect.origin.y   = (ContentHeight-ContentHeight*ScaleLevel)/2;
    contentRect.size.width = ContentWidth*ScaleLevel;
    contentRect.size.height= ContentHeight*ScaleLevel;
    leftMenuRect.origin.x = 0;
    leftMenuRect.origin.y = 0;
    leftMenuRect.size.width = LeftMenuWidth;
    leftMenuRect.size.height= ContentHeight;
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.contentVC.view setFrame:contentRect];
        [self.leftMenuVC.view setFrame:leftMenuRect];
    } completion:^(BOOL finished) {
        [self.contentVC.view addGestureRecognizer:self.leftCloseTapGestureRecognizer];
    }];
    self.scrollDirection = CLScrollDirectionLeft;
}
- (void)closeLeftMenu
{
    CGRect contentRect = self.contentVC.view.frame;
    CGRect leftMenuRect = self.leftMenuVC.view.frame;
    
    contentRect.origin.x   = 0;
    contentRect.origin.y   = 0;
    contentRect.size.width = ContentWidth;
    contentRect.size.height= ContentHeight;
    leftMenuRect.origin.x = -LeftMenuWidth;
    leftMenuRect.origin.y = ContentHeight*ScaleLevel/2;
    leftMenuRect.size.width = LeftMenuWidth*ScaleLevel;
    leftMenuRect.size.height= ContentHeight*ScaleLevel;
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.contentVC.view setFrame:contentRect];
        [self.leftMenuVC.view setFrame:leftMenuRect];
    } completion:^(BOOL finished) {
        [self.contentVC.view removeGestureRecognizer:self.leftCloseTapGestureRecognizer];
    }];
    [self deallocData];
}
- (void)showRightMenu
{
    CGRect rightMenuRect = self.rightMenuVC.view.frame;
    
    rightMenuRect.origin.x = ContentWidth - RightMenuWidth;
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.rightMenuVC.view setFrame:rightMenuRect];
    } completion:^(BOOL finished) {
        [self.contentVC.view addGestureRecognizer:self.rightCloseTapGestureRecognizer];
    }];
    self.scrollDirection = CLScrollDirectionRight;
}
- (void)closeRightMenu
{
    CGRect rightMenuRect = self.rightMenuVC.view.frame;
    
    rightMenuRect.origin.x = ContentWidth;
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.rightMenuVC.view setFrame:rightMenuRect];
    } completion:^(BOOL finished) {
        [self.contentVC.view removeGestureRecognizer:self.rightCloseTapGestureRecognizer];
    }];
    [self deallocData];
}
- (void)reSetUpUIWithDiffTouchPointX:(CGFloat)diffPointX
{
    if (self.scrollDirection==CLScrollDirectionLeft) {
        /** --第一步,计算偏移量*/
        self.distanceMove += diffPointX;
        CGRect contentRect = self.contentVC.view.frame;
        CGRect leftMenuRect= self.leftMenuVC.view.frame;
        
        if ((diffPointX>0&&self.distanceMove<LeftMenuWidth)) {
            CGFloat offsetLevel = (self.distanceMove/LeftMenuWidth);
            if (offsetLevel<=0) offsetLevel = 0;
            /** --第二步,计算左抽屉的坐标和大小*/
            // 左抽屉宽度公式 ： d+(w-d)*scale
            CGFloat lMWidth = self.distanceMove+(LeftMenuWidth-self.distanceMove)*ScaleLevel;
            // 左抽屉高度公式 ：((d/w)+(1-d/w)*scale)*h
            CGFloat lMHeight = (offsetLevel+(1-offsetLevel)*ScaleLevel)*ContentHeight;
            // 左抽屉X轴坐标
            CGFloat lMOriginX = -LeftMenuWidth+self.distanceMove+(lMWidth-leftMenuRect.size.width)/2;
            // 左抽屉Y轴坐标
            CGFloat lMOriginY = (ContentHeight-lMHeight)/2;
            
            /** --第三步,计算容器的坐标和大小*/
            // 容器的宽度
            CGFloat cWidth = ((1-offsetLevel)*(1-ScaleLevel)+ScaleLevel)*ContentWidth;
            // 容器的高度
            CGFloat cHeight = ((1-offsetLevel)*(1-ScaleLevel)+ScaleLevel)*ContentHeight;
            // 容器X轴坐标
            CGFloat cOriginX = self.distanceMove+(ContentWidth-cWidth)/2;
            // 容器Y轴坐标
            CGFloat cOriginY = (ContentHeight-cHeight)/2;
            
            contentRect = CGRectMake(cOriginX, cOriginY, cWidth, cHeight);
            leftMenuRect= CGRectMake(lMOriginX, lMOriginY, lMWidth, lMHeight);
            
            if (self.distanceMove>LeftMenuWidth) {
                contentRect.origin.x   = LeftMenuWidth+(ContentWidth-ContentWidth*ScaleLevel)/2;
                contentRect.origin.y   = (ContentHeight-ContentHeight*ScaleLevel)/2;
                contentRect.size.width = ContentWidth*ScaleLevel;
                contentRect.size.height= ContentHeight*ScaleLevel;
                leftMenuRect.origin.x = 0;
                leftMenuRect.origin.y = 0;
                leftMenuRect.size.width = LeftMenuWidth;
                leftMenuRect.size.height= ContentHeight;
            }
        }else if ((diffPointX<0&&contentRect.origin.x>0)){
            CGFloat offsetLevel = (self.distanceMove/LeftMenuWidth);
            if (offsetLevel>=1) offsetLevel = 1;
            /** --第二步,计算左抽屉的坐标和大小*/
            // 左抽屉宽度公式 ： d+(w-d)*scale
            CGFloat lMWidth = self.distanceMove+(LeftMenuWidth-self.distanceMove)*ScaleLevel;
            // 左抽屉高度公式 ：((d/w)+(1-d/w)*scale)*h
            CGFloat lMHeight = (offsetLevel+(1-offsetLevel)*ScaleLevel)*ContentHeight;
            // 左抽屉X轴坐标
            CGFloat lMOriginX = -LeftMenuWidth+self.distanceMove+(lMWidth-leftMenuRect.size.width)/2;
            // 左抽屉Y轴坐标
            CGFloat lMOriginY = (ContentHeight-lMHeight)/2;
            
            /** --第三步,计算容器的坐标和大小*/
            // 容器的宽度
            CGFloat cWidth = ((1-offsetLevel)*(1-ScaleLevel)+ScaleLevel)*ContentWidth;
            // 容器的高度
            CGFloat cHeight = ((1-offsetLevel)*(1-ScaleLevel)+ScaleLevel)*ContentHeight;
            // 容器X轴坐标
            CGFloat cOriginX = self.distanceMove+(ContentWidth-cWidth)/2;
            // 容器Y轴坐标
            CGFloat cOriginY = (ContentHeight-cHeight)/2;
            
            contentRect = CGRectMake(cOriginX, cOriginY, cWidth, cHeight);
            leftMenuRect= CGRectMake(lMOriginX, lMOriginY, lMWidth, lMHeight);
            
            if ((contentRect.origin.x<0)) {
                contentRect.origin.x   = 0;
                contentRect.origin.y   = 0;
                contentRect.size.width = ContentWidth;
                contentRect.size.height= ContentHeight;
                leftMenuRect.origin.x = -LeftMenuWidth;
                leftMenuRect.origin.y = ContentHeight*ScaleLevel/2;
                leftMenuRect.size.width = LeftMenuWidth*ScaleLevel;
                leftMenuRect.size.height= ContentHeight*ScaleLevel;
            }else if (leftMenuRect.origin.x>=0){
                contentRect.origin.x   = LeftMenuWidth+(ContentWidth-ContentWidth*ScaleLevel)/2;
                contentRect.origin.y   = (ContentHeight-ContentHeight*ScaleLevel)/2;
                contentRect.size.width = ContentWidth*ScaleLevel;
                contentRect.size.height= ContentHeight*ScaleLevel;
                leftMenuRect.origin.x = 0;
                leftMenuRect.origin.y = 0;
                leftMenuRect.size.width = LeftMenuWidth;
                leftMenuRect.size.height= ContentHeight;
            }
        }
        [self.contentVC.view setFrame:contentRect];
        [self.leftMenuVC.view setFrame:leftMenuRect];
    }else if (self.scrollDirection==CLScrollDirectionRight) {
        CGRect rightMenuRect = self.rightMenuVC.view.frame;
        if ((diffPointX<0&&rightMenuRect.origin.x>ContentWidth-RightMenuWidth)) {
            rightMenuRect.origin.x += diffPointX;
            
            if ((rightMenuRect.origin.x>ContentWidth)) {
                rightMenuRect.origin.x = ContentWidth;
            }
        } else if ((diffPointX>0&&rightMenuRect.origin.x<ContentWidth)) {
            rightMenuRect.origin.x += diffPointX;
            
            if ((rightMenuRect.origin.x<ContentWidth-RightMenuWidth)) {
                rightMenuRect.origin.x = ContentWidth-RightMenuWidth;
            }
        }
        [self.rightMenuVC.view setFrame:rightMenuRect];
    }
}
- (void)setupEndUI
{
    if (self.scrollDirection==CLScrollDirectionLeft) {
        if (self.contentVC.view.frame.origin.x>LeftScrollX) {
            [self showLeftMenu];
        }else{
            [self closeLeftMenu];
        }
    }else if (self.scrollDirection==CLScrollDirectionRight) {
        if (self.rightMenuVC.view.frame.origin.x>RightScrollX+40) {
            [self closeRightMenu];
        }else{
            [self showRightMenu];
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
