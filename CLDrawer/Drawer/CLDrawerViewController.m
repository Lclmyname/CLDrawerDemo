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

#define ContentWidth     [UIScreen mainScreen].bounds.size.width
#define ContentHeight    [UIScreen mainScreen].bounds.size.height
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
// 待添加功能[添加配置属性,诸如:抽屉宽度,缩放比例等]
/** --展开和收起状态下左右视图的坐标位置*/
@property (nonatomic, assign, readonly) CGRect showLeftMenuRect;
@property (nonatomic, assign, readonly) CGRect showRightMenuRect;
@property (nonatomic, assign, readonly) CGRect closeLeftMenuCGRect;
@property (nonatomic, assign, readonly) CGRect closeRightMenuCGRect;
@property (nonatomic, assign, readonly) CGRect showContentRect;
@property (nonatomic, assign, readonly) CGRect showLeftContentRect;
@property (nonatomic, assign, readonly) CGRect showRightContentRect;
/** --可拖拽位置 即左边沿开启左抽屉动画,右边沿开启右抽屉动画*/
@property (nonatomic, assign, readonly) CGFloat dragLeftMenuMaxOriginX;
@property (nonatomic, assign, readonly) CGFloat dragRightMenuMaxOriginX;

/** --TODO待完善功能[将可复用代码模块化,优化代码]*/

@end

@implementation CLDrawerViewController

- (instancetype)init
{
    if (self = [super init]) {
        
        _leftMenuWidth   = LeftMenuWidth;
        _rightMenuWidth  = RightMenuWidth;
        _scaleLevel      = ScaleLevel;
        [self setupSetting];
    }
    return self;
}

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

#pragma mark - setter
- (void)setScaleLevel:(CGFloat)scaleLevel
{
    _scaleLevel = scaleLevel;
    [self setupSetting];
}
- (void)setLeftMenuWidth:(CGFloat)leftMenuWidth
{
    _leftMenuWidth = leftMenuWidth;
    [self setupSetting];
}
- (void)setRightMenuWidth:(CGFloat)rightMenuWidth
{
    _rightMenuWidth = rightMenuWidth;
    [self setupSetting];
}

#pragma mark - 重新设计UI
- (void)setupContentViewController
{
    [self addChildViewController:self.contentVC];
    [self.view addSubview:self.contentVC.view];
    [self.contentVC.view setFrame:self.showContentRect];
}
- (void)setupLeftMenuViewController
{
    if (self.leftMenuVC) {
        [self addChildViewController:self.leftMenuVC];
        [self.view addSubview:self.leftMenuVC.view];
        [self.leftMenuVC.view setFrame:self.closeLeftMenuCGRect];
    }
}
- (void)setupRightMenuViewController
{
    if (self.rightMenuVC) {
        [self addChildViewController:self.rightMenuVC];
        [self.view addSubview:self.rightMenuVC.view];
        [self.rightMenuVC.view setFrame:self.closeRightMenuCGRect];
    }
}
- (void)setupTapGestureRecognizer
{
    self.leftCloseTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeLeftMenu)];
    self.rightCloseTapGestureRecognizer= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeRightMenu)];
}
- (void)setupSetting
{
    _dragLeftMenuMaxOriginX = self.leftMenuWidth/2;
    _dragRightMenuMaxOriginX = ContentWidth-self.rightMenuWidth;
    
    _showLeftMenuRect    = CGRectMake(0, 0, self.leftMenuWidth, ContentHeight);
    _showRightMenuRect   = CGRectMake(ContentWidth-self.rightMenuWidth, 0, self.rightMenuWidth, ContentHeight);
    
    _closeLeftMenuCGRect = CGRectMake(-(self.leftMenuWidth+((self.leftMenuWidth*(1-self.scaleLevel))/2)), ContentHeight*self.scaleLevel/2, self.leftMenuWidth*self.scaleLevel, ContentHeight*self.scaleLevel);
    _closeRightMenuCGRect= CGRectMake(ContentWidth, 0, self.rightMenuWidth, ContentHeight);
    
    _showContentRect     = CGRectMake(0, 0, ContentWidth, ContentHeight);
    _showLeftContentRect = CGRectMake(self.leftMenuWidth+(1-self.scaleLevel)*ContentWidth/2, (1-self.scaleLevel)*ContentHeight/2, ContentWidth*self.scaleLevel, ContentHeight*self.scaleLevel);
    _showRightContentRect= _showContentRect;
}
#pragma mark -- frame
- (CGRect)contentRectWithDragLeftMenu:(CGFloat)offsetLevel
{
    /** --第三步,计算容器的坐标和大小*/
    // 容器的宽度
    CGFloat cWidth = ((1-offsetLevel)*(1-self.scaleLevel)+self.scaleLevel)*ContentWidth;
    // 容器的高度
    CGFloat cHeight = ((1-offsetLevel)*(1-self.scaleLevel)+self.scaleLevel)*ContentHeight;
    // 容器X轴坐标
    CGFloat cOriginX = self.distanceMove+(ContentWidth-cWidth)/2;
    // 容器Y轴坐标
    CGFloat cOriginY = (ContentHeight-cHeight)/2;
    
    return CGRectMake(cOriginX, cOriginY, cWidth, cHeight);
}
- (CGRect)leftMenuRectWithDrag:(CGFloat)offsetLevel
{
    // 左抽屉宽度公式 ： d+(w-d)*scale
    CGFloat lMWidth = self.distanceMove+(self.leftMenuWidth-self.distanceMove)*self.scaleLevel;
    // 左抽屉高度公式 ：((d/w)+(1-d/w)*scale)*h
    CGFloat lMHeight = (offsetLevel+(1-offsetLevel)*self.scaleLevel)*ContentHeight;
    // 左抽屉X轴坐标
    CGFloat lMOriginX = -self.leftMenuWidth+self.distanceMove+(lMWidth-self.leftMenuVC.view.frame.size.width)/2;
    // 左抽屉Y轴坐标
    CGFloat lMOriginY = (ContentHeight-lMHeight)/2;
    
    return CGRectMake(lMOriginX, lMOriginY, lMWidth, lMHeight);
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

- (void)reSetUpUIWithDiffTouchPointX:(CGFloat)diffPointX
{
    if (self.scrollDirection==CLScrollDirectionLeft) {
        /** --第一步,计算偏移量*/
        self.distanceMove += diffPointX;
        CGRect contentRect = self.contentVC.view.frame;
        CGRect leftMenuRect= self.leftMenuVC.view.frame;
        
        if ((diffPointX>0&&self.distanceMove<self.leftMenuWidth)) {
            CGFloat offsetLevel = (self.distanceMove/self.leftMenuWidth);
            if (offsetLevel<=0) offsetLevel = 0;
            contentRect = [self contentRectWithDragLeftMenu:offsetLevel];
            leftMenuRect= [self leftMenuRectWithDrag:offsetLevel];
            
            if (self.distanceMove>self.leftMenuWidth) {
                contentRect = self.showLeftContentRect;
                leftMenuRect= self.showLeftMenuRect;
            }
        }else if ((diffPointX<0&&contentRect.origin.x>0)){
            CGFloat offsetLevel = (self.distanceMove/self.leftMenuWidth);
            if (offsetLevel>=1) offsetLevel = 1;
            contentRect = [self contentRectWithDragLeftMenu:offsetLevel];
            leftMenuRect= [self leftMenuRectWithDrag:offsetLevel];
            
            if ((contentRect.origin.x<0)) {
                contentRect = self.showContentRect;
                leftMenuRect= self.closeLeftMenuCGRect;
            }else if (leftMenuRect.origin.x>=0){
                contentRect = self.showLeftContentRect;
                leftMenuRect= self.showLeftMenuRect;
            }
        }
        [self.contentVC.view setFrame:contentRect];
        [self.leftMenuVC.view setFrame:leftMenuRect];
    }else if (self.scrollDirection==CLScrollDirectionRight) {
        CGRect rightMenuRect = self.rightMenuVC.view.frame;
        if ((diffPointX<0&&rightMenuRect.origin.x>ContentWidth-self.rightMenuWidth)) {
            rightMenuRect.origin.x += diffPointX;
            
            if ((rightMenuRect.origin.x>ContentWidth)) {
                rightMenuRect = self.closeRightMenuCGRect;
            }
        } else if ((diffPointX>0&&rightMenuRect.origin.x<ContentWidth)) {
            rightMenuRect.origin.x += diffPointX;
            
            if ((rightMenuRect.origin.x<ContentWidth-self.rightMenuWidth)) {
                rightMenuRect = self.showRightMenuRect;
            }
        }
        [self.rightMenuVC.view setFrame:rightMenuRect];
    }
}
- (void)setupEndUI
{
    if (self.scrollDirection==CLScrollDirectionLeft) {
        if (self.contentVC.view.frame.origin.x>self.dragLeftMenuMaxOriginX) {
            [self showLeftMenu];
        }else{
            [self closeLeftMenu];
        }
    }else if (self.scrollDirection==CLScrollDirectionRight) {
        if (self.rightMenuVC.view.frame.origin.x>self.dragRightMenuMaxOriginX+40) {
            [self closeRightMenu];
        }else{
            [self showRightMenu];
        }
    }
}
#pragma mark -- animation method
- (void)showLeftMenu
{
    self.distanceMove  = self.leftMenuWidth;
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.contentVC.view setFrame:self.showLeftContentRect];
        [self.leftMenuVC.view setFrame:self.showLeftMenuRect];
    } completion:^(BOOL finished) {
        [self.contentVC.view addGestureRecognizer:self.leftCloseTapGestureRecognizer];
    }];
    self.scrollDirection = CLScrollDirectionLeft;
}
- (void)closeLeftMenu
{
    [UIView animateWithDuration:0.2 animations:^{
        [self.contentVC.view setFrame:self.showContentRect];
        [self.leftMenuVC.view setFrame:self.closeLeftMenuCGRect];
    } completion:^(BOOL finished) {
        [self.contentVC.view removeGestureRecognizer:self.leftCloseTapGestureRecognizer];
    }];
    [self deallocData];
}
- (void)showRightMenu
{
    [UIView animateWithDuration:0.2 animations:^{
        [self.rightMenuVC.view setFrame:self.showRightMenuRect];
    } completion:^(BOOL finished) {
        [self.contentVC.view addGestureRecognizer:self.rightCloseTapGestureRecognizer];
    }];
    self.scrollDirection = CLScrollDirectionRight;
}
- (void)closeRightMenu
{
    [UIView animateWithDuration:0.2 animations:^{
        [self.rightMenuVC.view setFrame:self.closeRightMenuCGRect];
    } completion:^(BOOL finished) {
        [self.contentVC.view removeGestureRecognizer:self.rightCloseTapGestureRecognizer];
    }];
    [self deallocData];
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
