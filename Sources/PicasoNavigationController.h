//
//  PicasoNavigationController.h
//  Picaso
//
//  Created by Hummer on 16/8/20.
//  Copyright © 2016年 Amazation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PicasoBaseNavigationController.h"

typedef NS_ENUM(NSUInteger, NavigationBarState) {
    NavigationBarStateCollapsed,
    NavigationBarStateExpanded,
    NavigationBarStateScrolling,
};

@class PicasoNavigationController;
@protocol PicasoNavigationControllerDelegate <NSObject>
@optional
- (void)navigationController:(PicasoNavigationController * _Nonnull)navigationController didChangeNavigationBarState:(NavigationBarState)state;
- (void)navigationController:(PicasoNavigationController * _Nonnull)navigationController didScrollWithProgress:(CGFloat)progress;
@end

@interface PicasoNavigationController : PicasoBaseNavigationController
@property (nonatomic, assign) BOOL canNavigationBarScroll;
@property (nonatomic, assign, getter=isAlwaysScrollable) BOOL alwaysScrollable;
@property (nonatomic, assign) NavigationBarState state;
@property (nullable, nonatomic, weak) id<PicasoNavigationControllerDelegate> navigationBarScrollDelegate;


//- (void)scrollableViewDidScroll:(UIScrollView *)scrollView;
//- (void)scrollableViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
//- (void)scrollableViewEndDecelerating:(UIScrollView *)scrollView;

- (void)showNavigationBarWithAnimation:(BOOL)animation;
- (void)hideNavigationBarWithAnimation:(BOOL)animation;
- (void)observeScrollView:(UIView * _Nonnull)view forDelayDistance:(CGFloat)distance;
//- (void)observeScrollView:(UIView * _Nonnull)view forScrollUpDelayDistance:(CGFloat)up scrollDownDelayDistance:(CGFloat)down;
- (void)stopObserveScrollView;
@end
