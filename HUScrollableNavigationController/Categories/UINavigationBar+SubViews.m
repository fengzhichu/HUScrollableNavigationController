//
//  UINavigationBar+SubViews.m
//  Picaso
//
//  Created by Hummer on 16/8/21.
//  Copyright © 2016年 Amazation. All rights reserved.
//

#import "UINavigationBar+SubViews.h"
#import <objc/runtime.h>
#import <objc/objc.h>

@implementation UINavigationBar (SubViews)

- (UIView *)findSubView:(NSString *)className inView:(UIView *)view withComparator:(BOOL (^)(UIView *view))comparator {
    if ([NSStringFromClass([view class]) isEqualToString:className]) {
        if (comparator == nil) {
            return view;
        }
        if (comparator(view)) {
            return view;
        }
    }
    __block UIView *subView = nil;
    [view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        subView = [self findSubView:className inView:obj withComparator:comparator];
        if (subView) {
            *stop = YES;
        }
    }];
    return subView;
}

- (UIView *)bottomLineView {
    UIView *view = objc_getAssociatedObject(self, @selector(bottomLineView));
    if (view == nil) {
        view = [self findSubView:NSStringFromClass([UIImageView class]) inView:self withComparator:^BOOL(UIView *view) {
            return view.bounds.size.height <= 1.0;
        }];
        view == nil ?: objc_setAssociatedObject(self, @selector(bottomLineView), view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return view;
}

- (UIView *)effectView {
    UIView *view = objc_getAssociatedObject(self, @selector(effectView));
    if (view == nil) {
        view = [self findSubView:@"_UIBackdropEffectView" inView:self withComparator:nil];
        view == nil ?: objc_setAssociatedObject(self, @selector(effectView), view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return view;
}

@end
