//
//  UITextField+Extension.m
//  EXTextField
//
//  Created by kingly on 16/9/1.
//  Copyright © 2016年 https://github.com/kingly09/EXTextField  kingly  inc . All rights reserved.
//

#import "UITextField+Extension.h"
#import <objc/runtime.h>

static char exCanMoveKey;
static char exMoveViewKey;
static char exHeightToKeyboardKey;
static char exInitialYKey;
static char exTapGestureKey;
static char exKeyboardYKey;
static char exTotalHeightKey;
static char exKeyboardHeightKey;
static char exHasContentOffsetKey;
static char exKeyboardFrameBeginToEndKey;

@implementation UITextField (Extension)
@dynamic ex_canMove;
@dynamic ex_moveView;
@dynamic ex_heightToKeyboard;

/**
 * 初始化交换Selector
 **/
+ (void)load {
    static dispatch_once_t onceTokenTextField;
    dispatch_once(&onceTokenTextField, ^{
        SEL systemSelector = @selector(initWithFrame:);
        SEL mySystemSelector = @selector(setExTextFieldInitWithFrame:);
        [self exchangeSystemSelector:systemSelector bySel:mySystemSelector];
        
        SEL becomeFirst = @selector(becomeFirstResponder);
        SEL myBecomeFirst = @selector(newExTextFieldBecomeFirstResponder);
        [self exchangeSystemSelector:becomeFirst bySel:myBecomeFirst];
        
        SEL resignFirst = @selector(resignFirstResponder);
        SEL myResignFirst = @selector(newExTextFieldResignFirstResponder);
        [self exchangeSystemSelector:resignFirst bySel:myResignFirst];
        
        SEL selInitCoder = @selector(initWithCoder:);
        SEL mySelInitCoder = @selector(setExTextFieldInitWithCoder:);
        [self exchangeSystemSelector:selInitCoder bySel:mySelInitCoder];
    });
    [super load];
}
/**
 * 设置交换方法
 **/
+ (void)exchangeSystemSelector:(SEL)systemSel bySel:(SEL)mySel {
    Method systemMethod = class_getInstanceMethod([self class], systemSel);
    Method myMethod = class_getInstanceMethod([self class], mySel);
    //首先动态添加方法，实现是被交换的方法，返回值表示添加成功还是失败
    BOOL isAdd = class_addMethod(self, systemSel, method_getImplementation(myMethod), method_getTypeEncoding(myMethod));
    if (isAdd) {
        //如果成功，说明类中不存在这个方法的实现
        //将被交换方法的实现替换到这个并不存在的实现
        class_replaceMethod(self, mySel, method_getImplementation(systemMethod), method_getTypeEncoding(systemMethod));
    }else{
        //否则，交换两个方法的实现
        method_exchangeImplementations(systemMethod, myMethod);
    }
}

- (instancetype)setExTextFieldInitWithCoder:(NSCoder *)aDecoder {
    [self setExTextFieldInit];
    return [self setExTextFieldInitWithCoder:aDecoder];
}

- (instancetype)setExTextFieldInitWithFrame:(CGRect)frame {
    [self setExTextFieldInit];
    return [self setExTextFieldInitWithFrame:frame];
}
/**
 * 初始化init
 **/
- (void)setExTextFieldInit {
    self.ex_heightToKeyboard = 10;
    self.ex_canMove = YES;
    self.exKeyboardY = 0;
    self.exTotalHeight = 0;
    self.exTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
}
/**
 *  接收键盘的显示的通知
 **/
- (void)notificationShowKeyboardAction:(NSNotification *)sender {
//       NSLog(@"%@", sender);
    if (!self.ex_canMove) {
        return;
    }
    self.exKeyboardY = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    self.exKeyboardHeight = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    CGRect begins = [[[sender userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect end = [[[sender userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [[sender.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    if ((begins.origin.y-end.origin.y<0) && duration == 0){
        self.exKeyboardFrameBeginToEnd = begins.origin.y - end.origin.y;
    }else{
        self.exKeyboardFrameBeginToEnd  = 0;
    }
    [self exKeyboardDidShow];
}

- (void)exKeyboardDidShow {
    if (self.exKeyboardHeight == 0) {
        return;
    }
    CGFloat fieldYInWindow = [self convertPoint:self.bounds.origin toView:[UIApplication sharedApplication].keyWindow].y;
    CGFloat height = (fieldYInWindow + self.ex_heightToKeyboard + self.frame.size.height) - self.exKeyboardY;
    CGFloat moveHeight = height > 0 ? height : 0;
    moveHeight = self.exKeyboardFrameBeginToEnd < 0?self.exKeyboardFrameBeginToEnd:moveHeight;
    if (height < 0  && moveHeight < 0) {
        if (fabs(height)>fabs(moveHeight)) {
            return;
        }
    }
    [UIView animateWithDuration:0.25 animations:^{
        if (self.exhasContentOffset) {
            UIScrollView *scrollView = (UIScrollView *)self.ex_moveView;
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + moveHeight);
        } else {
            CGRect rect = self.ex_moveView.frame;
            self.exInitialY = rect.origin.y;
            rect.origin.y -= moveHeight;
            self.ex_moveView.frame = rect;
        }
        self.exTotalHeight += moveHeight;
    }];
}
/**
 *  接收键盘的隐藏的通知
 **/
- (void)notificationHideKeyboardAction:(NSNotification *)sender {
    if (!self.ex_canMove || self.exKeyboardY == 0) {
        return;
    }
    [self exHideKeyBoard:0.25];
}

- (void)exHideKeyBoard:(CGFloat)duration {
    [UIView animateWithDuration:duration animations:^{
        if (self.exhasContentOffset) {
            UIScrollView *scrollView = (UIScrollView *)self.ex_moveView;
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y - self.exTotalHeight);
        } else {
            CGRect rect = self.ex_moveView.frame;
            rect.origin.y += self.exTotalHeight;
            self.ex_moveView.frame = rect;
        }
        self.exTotalHeight = 0;
    }];
}
/**
 * 获取 TextField 的焦点
 **/
- (BOOL)newExTextFieldBecomeFirstResponder {
    if (self.ex_moveView == nil) {
        self.ex_moveView = [self viewController].view;
    }
    if (![self.ex_moveView.gestureRecognizers containsObject:self.exTapGesture]) {
        [self.ex_moveView addGestureRecognizer:self.exTapGesture];
    }
    if ([self isFirstResponder] || !self.ex_canMove) {
        return [self newExTextFieldBecomeFirstResponder];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationShowKeyboardAction:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationHideKeyboardAction:) name:UIKeyboardWillHideNotification object:nil];
    return [self newExTextFieldBecomeFirstResponder];
}
/**
 * 取消 TextField 的焦点
 **/
- (BOOL)newExTextFieldResignFirstResponder {
    if ([self.ex_moveView.gestureRecognizers containsObject:self.exTapGesture]) {
        [self.ex_moveView removeGestureRecognizer:self.exTapGesture];
    }
    if (!self.ex_canMove) {
        return [self newExTextFieldResignFirstResponder];
    }
    BOOL result = [self newExTextFieldResignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [self exHideKeyBoard:0];
    return result;
}

- (void)tapAction {
    [[self viewController].view endEditing:YES];
}

- (UIViewController *)viewController {
    UIView *next = self;
    while (1) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
        next = next.superview;
    }
    return nil;
}

#pragma mark - 对外接口

- (void)setEx_canMove:(BOOL)ex_canMove {
    objc_setAssociatedObject(self, &exCanMoveKey, @(ex_canMove), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)ex_canMove {
    return [objc_getAssociatedObject(self, &exCanMoveKey) boolValue];
}

- (void)setEx_heightToKeyboard:(CGFloat)ex_heightToKeyboard {
    objc_setAssociatedObject(self, &exHeightToKeyboardKey, @(ex_heightToKeyboard), OBJC_ASSOCIATION_ASSIGN);
}

- (CGFloat)ex_heightToKeyboard {
    return [objc_getAssociatedObject(self, &exHeightToKeyboardKey) floatValue];
}

- (void)setEx_moveView:(UIView *)ex_moveView {
    self.exhasContentOffset = NO;
    if ([ex_moveView isKindOfClass:[UIScrollView class]]) {
        self.exhasContentOffset = YES;
    }
    objc_setAssociatedObject(self, &exMoveViewKey, ex_moveView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)ex_moveView {
    return objc_getAssociatedObject(self, &exMoveViewKey);
}

#pragma mark - 初始化属性 私有方法
- (void)setExInitialY:(CGFloat)exInitialY {
    objc_setAssociatedObject(self, &exInitialYKey, @(exInitialY), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)exInitialY {
    return [objc_getAssociatedObject(self, &exInitialYKey) floatValue];
}

- (void)setExTapGesture:(UITapGestureRecognizer *)exTapGesture {
    objc_setAssociatedObject(self, &exTapGestureKey, exTapGesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UITapGestureRecognizer *)exTapGesture {
    return objc_getAssociatedObject(self, &exTapGestureKey);
}

- (void)setExKeyboardY:(CGFloat)exKeyboardY {
    objc_setAssociatedObject(self, &exKeyboardYKey, @(exKeyboardY), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)exKeyboardY {
    return [objc_getAssociatedObject(self, &exKeyboardYKey) floatValue];
}

- (void)setExTotalHeight:(CGFloat)exTotalHeight {
    objc_setAssociatedObject(self, &exTotalHeightKey, @(exTotalHeight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)exTotalHeight {
    return [objc_getAssociatedObject(self, &exTotalHeightKey) floatValue];
}

- (void)setExKeyboardFrameBeginToEnd:(CGFloat)exKeyboardFrameBeginToEnd {
    objc_setAssociatedObject(self, &exKeyboardFrameBeginToEndKey, @(exKeyboardFrameBeginToEnd), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (CGFloat)exKeyboardFrameBeginToEnd {
    return [objc_getAssociatedObject(self, &exKeyboardFrameBeginToEndKey) floatValue];
}

- (void)setExKeyboardHeight:(CGFloat)exKeyboardHeight {
    objc_setAssociatedObject(self, &exKeyboardHeightKey, @(exKeyboardHeight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)exKeyboardHeight {
    return [objc_getAssociatedObject(self, &exKeyboardHeightKey) floatValue];
}

- (void)setExhasContentOffset:(BOOL)exhasContentOffset {
    objc_setAssociatedObject(self, &exHasContentOffsetKey, @(exhasContentOffset), OBJC_ASSOCIATION_ASSIGN);
}
- (BOOL)exhasContentOffset {
    return [objc_getAssociatedObject(self, &exHasContentOffsetKey) boolValue];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

@end