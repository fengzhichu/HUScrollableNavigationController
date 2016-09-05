//
//  TestTableViewController.m
//  Picaso
//
//  Created by Hummer on 16/8/21.
//  Copyright © 2016年 Amazation. All rights reserved.
//

#import "TestTableViewController.h"
#import "HUScrollableNavigationController.h"
#import "UINavigationBar+SubViews.h"

@interface TestTableViewController () <UITableViewDataSource, UITableViewDelegate, HUScrollableNavigationControllerDelegate> {
    UILabel *_titleLabel;
    UIView *_bgView;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation TestTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    ((HUScrollableNavigationController *)self.navigationController).navigationBarScrollDelegate = self;
    
    self.navigationItem.hidesBackButton = NO;
//    self.navigationController.navigationBar.translucent = NO;
    
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375, 44)];
    [_bgView setBackgroundColor:[UIColor clearColor]];
    
    _titleLabel = [[UILabel alloc] initWithFrame:_bgView.bounds];
    _titleLabel.text = @"Picaso";
    _titleLabel.textColor = [UIColor blackColor];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_titleLabel setFont:[UIFont systemFontOfSize:20]];
    [_bgView addSubview:_titleLabel];
    
    self.navigationItem.titleView = _bgView;
    
    self.title = @"TableView";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [(HUScrollableNavigationController *)self.navigationController observeScrollView:self.tableView forDelayDistance:10];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)navigationController:(HUScrollableNavigationController *)navigationController didScrollWithProgress:(CGFloat)progress {
    _titleLabel.transform = CGAffineTransformMakeScale(progress, progress);
    _titleLabel.alpha = progress;
    self.navigationController.navigationBar.bottomLineView.alpha = progress;
}

- (void)navigationController:(HUScrollableNavigationController *)navigationController didChangeNavigationBarState:(NavigationBarState)state {
    if (state == NavigationBarStateCollapsed) {
        self.navigationController.navigationBar.bottomLineView.hidden = YES;
    } else {
        self.navigationController.navigationBar.bottomLineView.hidden = NO;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 50;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TestTableViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
