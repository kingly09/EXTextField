//
//  UITextField+Extension.h
//  EXTextField
//
//  Created by kingly on 16/9/1.
//  Copyright © 2016年 https://github.com/kingly09/EXTextField  kingly  inc . All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  通过添加UITextField类目，使用runtime实现，TextField被遮挡时视图上移效果，
 *  点击对应的父视图的空白地方回收键盘，不需要写一句代码，所有TextField全拥有此功能，
 *  可以控制是否开启，上移视图，
 *  可以设置距keyboard距离
 *  支持第三方键盘显示隐藏
 **/

@interface UITextField (Extension)
/**
 *  是否支持视图上移
 */
@property (nonatomic, assign) BOOL ex_canMove;
/**
 *  点击回收键盘、移动的视图，默认是当前控制器的view
 */
@property (nonatomic, strong) UIView *ex_moveView;
/**
 *  textfield底部距离键盘顶部的距离
 */
@property (nonatomic, assign) CGFloat ex_heightToKeyboard;


@end
