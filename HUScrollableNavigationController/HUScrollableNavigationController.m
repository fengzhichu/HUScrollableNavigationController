//
//  HUScrollableNavigationController.m
//  Picaso
//
//  Created by Hummer on 16/8/20.
//  Copyright © 2016年 Amazation. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "HUScrollableNavigationController.h"

@interface HUScrollableNavigationController () <UIGestureRecognizerDelegate, UIScrollViewDelegate> {
    UIPanGestureRecognizer *_gestureRecognizer;
    UIScrollView *_scrollableView;
    CGFloat _delayDistance;
    CGFloat _maxDelay;
    CGFloat _lastGestureContentOffset;
    CGPoint _scrollBeginOffset;
    CGPoint _scrollViewLastContentOffset;
}
@property (nonatomic, assign, readonly) CGFloat fullNavigationBarHeight;
@property (nonatomic, assign, readonly) CGFloat navigationBarHeight;
@property (nonatomic, assign, readonly) CGFloat statusBarHeight;
@property (nonatomic, assign, readonly) CGFloat tabBarHeight;
@property (nonatomic, assign, readonly) CGFloat maxScrollDistance;
@property (nonatomic, assign, readonly) CGPoint contentOffset;
@property (nonatomic, assign, readonly) CGSize contentSize;
@end

@implementation HUScrollableNavigationController

- (CGFloat)fullNavigationBarHeight {
    return self.navigationBarHeight + self.statusBarHeight;
}

- (CGFloat)navigationBarHeight {
    return self.navigationBar.frame.size.height;
}

- (CGFloat)statusBarHeight {
    return [[UIApplication sharedApplication] statusBarFrame].size.height;
}

- (CGFloat)tabBarHeight {
    if (self.tabBarController ==nil ) {
        return 0;
    }
    UITabBar *tabBar = self.tabBarController.tabBar;
    return tabBar.translucent ? 0 : tabBar.frame.size.height;
}

- (CGPoint)contentOffset {
    return _scrollableView ? _scrollableView.contentOffset : CGPointZero;
}

- (CGSize)contentSize {
    return _scrollableView ? _scrollableView.contentSize : CGSizeZero;
}

- (CGFloat)maxScrollDistance {
    return self.navigationBarHeight - self.statusBarHeight;
}

- (void)setState:(NavigationBarState)state {
    if (state == NavigationBarStateScrolling && _state != NavigationBarStateScrolling) {
        _scrollViewLastContentOffset = _scrollableView.contentOffset;
    }
    _state = state;
    if ([self.navigationBarScrollDelegate respondsToSelector:@selector(navigationController:didChangeNavigationBarState:)]) {
        [self.navigationBarScrollDelegate navigationController:self didChangeNavigationBarState:state];
    }
}

- (void)observeScrollView:(UIView *)view forDelayDistance:(CGFloat)distance {
    if ([view isMemberOfClass:[UIWebView class]] ||
        [view isMemberOfClass:[WKWebView class]]) {
        _scrollableView = [(UIWebView *)view scrollView];
    } else if ([view isKindOfClass:[UIScrollView class]]) {
        _scrollableView = (UIScrollView *)view;
    } else {
        return;
    }
    _gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    _gestureRecognizer.maximumNumberOfTouches = 1;
    _gestureRecognizer.delegate = self;
    [_scrollableView addGestureRecognizer:_gestureRecognizer];
    
    _delayDistance = distance;
    _maxDelay = distance;
    // _canNavigationBarScroll = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidChangeOrientation:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidChangeStatusBarFrame:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        _scrollBeginOffset = self.contentOffset;
    }
    if (gesture.state != UIGestureRecognizerStateFailed) {
        UIView *superView = _scrollableView.superview;
        CGPoint translation = [gesture translationInView:superView];
        CGFloat distance = _lastGestureContentOffset - translation.y;
        _lastGestureContentOffset = translation.y;
        if ([self shouldScrollNavigationBarWithDistance:distance]) {
            [self scrollNavigationBarWithDistance:distance];
        }
    }
    if (gesture.state == UIGestureRecognizerStateEnded ||
        gesture.state == UIGestureRecognizerStateCancelled ||
        gesture.state == UIGestureRecognizerStateFailed) {
        [self checkForPartialScroll];
        _lastGestureContentOffset = 0;
    }
}

- (void)appDidBecomeActive:(UIGestureRecognizer *)gesture {
    [self showNavigationBarWithAnimation:YES];
}

- (void)deviceDidChangeOrientation:(UIGestureRecognizer *)gesture {
    [self showNavigationBarWithAnimation:YES];
}

- (void)appDidChangeStatusBarFrame:(UIGestureRecognizer *)gesture {
    [self showNavigationBarWithAnimation:YES];
}

- (void)hideNavigationBarWithAnimation:(BOOL)animation {
    if (_scrollableView == nil) return;
    
    if (_state != NavigationBarStateExpanded) {
        [self updateNavigationItems];
        return;
    }
    UIViewController *visibleViewController = self.visibleViewController;
    self.state = NavigationBarStateScrolling;
    [UIView animateWithDuration:animation ? 0.2 : 0 animations:^{
        [self scrollNavigationBarWithDistance:self.fullNavigationBarHeight];
        [visibleViewController.view setNeedsLayout];
        if (self.navigationBar.translucent) {
            CGPoint currentOffset = self.contentOffset;
            _scrollableView.contentOffset = CGPointMake(currentOffset.x, currentOffset.y + self.navigationBarHeight);
        }
    } completion:^(BOOL finished) {
        self.state = NavigationBarStateCollapsed;
    }];
}

- (void)showNavigationBarWithAnimation:(BOOL)animation {
    if (_scrollableView == nil) return;
    
    if (_state != NavigationBarStateCollapsed) {
        [self updateNavigationItems];
        return;
    }
    UIViewController *visibleViewController = self.visibleViewController;
    self.state = NavigationBarStateScrolling;
    _gestureRecognizer.enabled = NO;
    [UIView animateWithDuration:animation ? 0.2 : 0 animations:^{
        _lastGestureContentOffset = 0;
        _delayDistance = -self.fullNavigationBarHeight;
        [self scrollNavigationBarWithDistance:-self.fullNavigationBarHeight];
        [visibleViewController.view setNeedsLayout];
        if (self.navigationBar.translucent) {
            CGPoint currentOffset = self.contentOffset;
            _scrollableView.contentOffset = CGPointMake(currentOffset.x, currentOffset.y - self.navigationBarHeight);
        }
    } completion:^(BOOL finished) {
        self.state = NavigationBarStateExpanded;
        _gestureRecognizer.enabled = YES;
    }];
}

- (BOOL)shouldScrollNavigationBarWithDistance:(CGFloat)distance {
    if (distance < 0) {
        if (_scrollableView != nil &&
            self.contentOffset.y + _scrollableView.frame.size.height > self.contentSize.height &&
            self.contentSize.height > _scrollableView.frame.size.height) {
            return NO;
        }
    }
    return  YES;
}

- (void)scrollNavigationBarWithDistance:(CGFloat)distance {
    CGRect frame = self.navigationBar.frame;
    if (distance > 0) {
        _delayDistance -= distance;
        if (_delayDistance > 0) {
            return;
        }
        if (_scrollableView != nil &&
            !self.isAlwaysScrollable &&
            self.state != NavigationBarStateCollapsed &&
            _scrollableView.frame.size.height >= self.contentSize.height) {
            return;
        }
        if (frame.origin.y - distance < -self.maxScrollDistance) {
            distance = frame.origin.y + self.maxScrollDistance;
        }
        if (frame.origin.y <= -self.maxScrollDistance) {
            self.state = NavigationBarStateCollapsed;
            _delayDistance = _maxDelay;
        } else {
            self.state = NavigationBarStateScrolling;
        }
        if (_scrollableView.contentOffset.y < -self.fullNavigationBarHeight) {
            self.state = NavigationBarStateExpanded;
        }
    }
    
    if (distance < 0) {
        _delayDistance += distance;
        if (_delayDistance > 0 && _maxDelay < self.contentOffset.y) {
            return;
        }
        if (frame.origin.y - distance > self.statusBarHeight) {
            distance = frame.origin.y - self.statusBarHeight;
        }
        if (frame.origin.y >= self.statusBarHeight) {
            self.state = NavigationBarStateExpanded;
            _delayDistance = _maxDelay;
        } else {
            self.state = NavigationBarStateScrolling;
        }
    }
    [self updateNavigationBarFrameWithDistance:distance];
    [self updateNavigationItems];
    [self restoreContentOffsetWithDistance:distance];
}

- (void)updateNavigationBarFrameWithDistance:(CGFloat)distance {
    if (self.state == NavigationBarStateExpanded || self.topViewController == nil) {
            return;
    }
    CGRect frame = self.navigationBar.frame;
    frame.origin = CGPointMake(frame.origin.x, frame.origin.y - distance);
    self.navigationBar.frame = frame;
    
    if (!self.navigationBar.translucent) {
        CGFloat navigationBarY = self.navigationBar.frame.origin.y + self.navigationBar.frame.size.height;
        frame = self.topViewController.view.frame;
        frame.origin = CGPointMake(frame.origin.x, navigationBarY);
        frame.size = CGSizeMake(frame.size.width, self.view.frame.size.height - navigationBarY - self.tabBarHeight);
        self.topViewController.view.frame = frame;
    } else {
        CGFloat navigationBarY = self.navigationBar.frame.origin.y + self.navigationBar.frame.size.height;
        frame = self.topViewController.view.frame;
        frame.origin = CGPointMake(frame.origin.x, navigationBarY - self.fullNavigationBarHeight);
        frame.size = CGSizeMake(frame.size.width, self.view.frame.size.height - navigationBarY - self.tabBarHeight + self.fullNavigationBarHeight);
//        self.topViewController.view.frame = frame;
        _scrollableView.frame = frame;
        if (self.state == NavigationBarStateScrolling) {
            [_scrollableView setContentOffset:_scrollViewLastContentOffset animated:NO];
        }
    }
}

- (void)restoreContentOffsetWithDistance:(CGFloat)distance {
    if (self.navigationBar.translucent || distance == 0) {
        return;
    }
    [_scrollableView setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y - distance) animated:NO];
}

- (void)checkForPartialScroll {
    CGRect frame = self.navigationBar.frame;
    NSTimeInterval duration = 0;
    CGFloat distance = 0;
    if (self.navigationBar.frame.origin.y >= (self.statusBarHeight - (frame.size.height / 2))) {
        distance = frame.origin.y - self.statusBarHeight;
        duration = fabs(distance / (frame.size.height / 2)) * 0.2;
    } else {
        distance = frame.origin.y + self.maxScrollDistance;
        duration = fabs(distance/ (frame.size.height / 2)) * 0.2;
    }
    _delayDistance = _maxDelay;
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionTransitionCurlUp | UIViewAnimationOptionTransitionCurlDown animations:^{
        [self updateNavigationBarFrameWithDistance:distance];
        [self updateNavigationItems];
    } completion:^(BOOL finished) {
        self.state = self.navigationBar.frame.origin.y < 0 ? NavigationBarStateCollapsed : NavigationBarStateExpanded;
    }];
}

- (void)updateNavigationItems {
    if (self.visibleViewController == nil) {
        return;
    }
    CGRect frame = self.navigationBar.frame;
    CGFloat alpha = (frame.origin.y + self.maxScrollDistance) / frame.size.height;
//    CGFloat progress = alpha;
    CGFloat progress = (frame.origin.y + 4) / self.maxScrollDistance;
    progress = progress > 1 ? 1 : (progress > 0 ? progress : 0.01);
    if ([self.navigationBarScrollDelegate respondsToSelector:@selector(navigationController:didScrollWithProgress:)]) {
        [self.navigationBarScrollDelegate navigationController:self didScrollWithProgress:progress];
    }
    
    UINavigationItem *navigationItem = self.visibleViewController.navigationItem;
    navigationItem.titleView.alpha = alpha;
    self.navigationBar.tintColor = [self.navigationBar.tintColor colorWithAlphaComponent:alpha];
    UIColor *titleColor = [self.navigationBar.titleTextAttributes objectForKey:NSForegroundColorAttributeName];
    NSMutableDictionary *textAttributes = [NSMutableDictionary dictionaryWithDictionary:self.navigationBar.titleTextAttributes];
    if (titleColor) {
        textAttributes[NSForegroundColorAttributeName] = [titleColor colorWithAlphaComponent:alpha];
    } else {
        textAttributes[NSForegroundColorAttributeName] = [[UIColor blackColor] colorWithAlphaComponent:alpha];
    }
    self.navigationBar.titleTextAttributes = textAttributes;
    
    [self.navigationBar.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *className = [[obj classForCoder] description];
        if ([className isEqualToString:@"UINavigationButton"] ||
            [className isEqualToString:@"UINavigationItemView"] ||
            [className isEqualToString:@"UIImageView"] ||
            [className isEqualToString:@"UISegmentedControl"]) {
            obj.alpha = alpha;
        }
    }];
    
    navigationItem.backBarButtonItem.customView.alpha = alpha;
    
    navigationItem.leftBarButtonItem.customView.alpha = alpha;
    [navigationItem.leftBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.customView.alpha = alpha;
    }];
    
    navigationItem.rightBarButtonItem.customView.alpha = alpha;
    [navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.customView.alpha = alpha;
    }];
}

- (void)stopObserveScrollView {
    [self showNavigationBarWithAnimation:NO];
    if (_gestureRecognizer) {
        [_scrollableView removeGestureRecognizer:_gestureRecognizer];
    }
    _scrollableView = nil;
    _gestureRecognizer = nil;
    _canNavigationBarScroll = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return _canNavigationBarScroll;
}

@end

