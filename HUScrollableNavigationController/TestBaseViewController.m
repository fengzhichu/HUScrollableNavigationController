//
//  TestBaseViewController.m
//  Picaso
//
//  Created by Hummer on 16/8/21.
//  Copyright © 2016年 Amazation. All rights reserved.
//

#import "TestBaseViewController.h"
#import "HUScrollableNavigationController.h"

@interface TestBaseViewController () <UIScrollViewDelegate>

@end

@implementation TestBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [(HUScrollableNavigationController *)self.navigationController showNavigationBarWithAnimation:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [(HUScrollableNavigationController *)self.navigationController stopObserveScrollView];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    [(HUScrollableNavigationController *)self.navigationController showNavigationBarWithAnimation:YES];
    return true;
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
