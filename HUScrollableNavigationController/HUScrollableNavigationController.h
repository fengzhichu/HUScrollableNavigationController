//
//  HUScrollableNavigationController.h
//  Picaso
//
//  Created by Hummer on 16/8/20.
//  Copyright © 2016年 Amazation. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, NavigationBarState) {
    NavigationBarStateCollapsed,
    NavigationBarStateExpanded,
    NavigationBarStateScrolling,
};

@class HUScrollableNavigationController;
@protocol HUScrollableNavigationControllerDelegate <NSObject>
@optional
- (void)navigationController:(HUScrollableNavigationController * _Nonnull)navigationController didChangeNavigationBarState:(NavigationBarState)state;
- (void)navigationController:(HUScrollableNavigationController * _Nonnull)navigationController didScrollWithProgress:(CGFloat)progress;
@end

@interface HUScrollableNavigationController : UINavigationController
@property (nonatomic, assign) BOOL canNavigationBarScroll;
@property (nonatomic, assign, getter=isAlwaysScrollable) BOOL alwaysScrollable;
@property (nonatomic, assign) NavigationBarState state;
@property (nullable, nonatomic, weak) id<HUScrollableNavigationControllerDelegate> navigationBarScrollDelegate;

- (void)showNavigationBarWithAnimation:(BOOL)animation;
- (void)hideNavigationBarWithAnimation:(BOOL)animation;
- (void)observeScrollView:(UIView * _Nonnull)view forDelayDistance:(CGFloat)distance;
- (void)stopObserveScrollView;
@end
