//
//  ViewController.m
//  EXTextField
//
//  Created by kingly on 16/9/1.
//  Copyright © 2016年 https://github.com/kingly09/EXTextField  kingly  inc . All rights reserved.
//

#import "ViewController.h"
#import "UITextField+Extension.h"

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];

    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    [self.view addSubview:backgroundView];
    
    
    UIView *leftView =  [[UIView alloc] initWithFrame:CGRectMake(0,0, SCREEN_WIDTH*2/3, SCREEN_HEIGHT)];
    
    leftView.backgroundColor = [UIColor orangeColor];
    
    UITextField *defaultfield = [[UITextField alloc] initWithFrame:CGRectMake(0, 100, 200, 30)];
    defaultfield.borderStyle = UITextBorderStyleRoundedRect;
    [leftView addSubview:defaultfield];

    
    //默认为self.view视图移动，与textfield底部距离键盘顶部的距离为10
    UITextField *field2 = [[UITextField alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 200, 200, 30)];
    [leftView addSubview:field2];
    field2.placeholder = @"self.view 视图移动";
    field2.borderStyle = UITextBorderStyleRoundedRect;
    [backgroundView addSubview:leftView];
    
    UIView *rtView =  [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*2/3,0, SCREEN_WIDTH/3, SCREEN_HEIGHT)];
    rtView.backgroundColor = [UIColor clearColor];
    
    //设置不移动
    UITextField *field3 = [[UITextField alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 200, 80, 30)];
    [leftView addSubview:field3];
    field3.placeholder = @"不移动";
    field3.borderStyle = UITextBorderStyleRoundedRect;
    field3.ex_canMove = NO;
    [rtView addSubview:field3];
    
    [backgroundView addSubview:rtView];
    
    UIView *topView = [[UIView alloc] init];
    topView.frame   = CGRectMake(0,0, leftView.frame.size.width, 100);
    topView.backgroundColor = [UIColor brownColor];
    [leftView addSubview:topView];
    
    
    UIView *topView02 = [[UIView alloc] init];
    topView02.frame   = CGRectMake(0,0, rtView.frame.size.width, SCREEN_HEIGHT-200);
    topView02.backgroundColor = [UIColor blueColor];
    [rtView addSubview:topView02];
    
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 100 ,SCREEN_WIDTH, 100 )];
    footerView.backgroundColor = [UIColor yellowColor];
    [backgroundView addSubview:footerView];
    
    //设置移动的父视图
    UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(0, 0,leftView.frame.size.width - 44, 44 )];
    field.placeholder = @"backgroundView 视图移动";
    field.borderStyle = UITextBorderStyleRoundedRect;
    [footerView  addSubview:field];
    
    field.ex_heightToKeyboard = 0;
    field.ex_moveView = backgroundView;
    
    //设置textfield底部距离键盘顶部的距离
    UITextField *moveFieldheight = [[UITextField alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 250, 200, 30)];
    moveFieldheight.borderStyle = UITextBorderStyleRoundedRect;
    moveFieldheight.ex_heightToKeyboard = 100;
    moveFieldheight.ex_moveView = leftView;
    moveFieldheight.placeholder = [NSString stringWithFormat:@"距离为%fpx",moveFieldheight.ex_heightToKeyboard];
    [leftView addSubview:moveFieldheight];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
