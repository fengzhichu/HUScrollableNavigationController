//
//  TestWebViewController.m
//  Picaso
//
//  Created by Hummer on 16/8/21.
//  Copyright © 2016年 Amazation. All rights reserved.
//

#import "TestWebViewController.h"
#import "HUScrollableNavigationController.h"

@interface TestWebViewController () <UIWebViewDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation TestWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"WebView";
    self.view.backgroundColor = [UIColor colorWithRed:.17 green:.24 blue:.32 alpha:1];
    _webView.backgroundColor = [UIColor colorWithRed:.17 green:.24 blue:.32 alpha:1];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:.2 green:.28 blue:.37 alpha:1];
    [_webView loadHTMLString:@"<html><body style='background-color:#34495e; color:white; font-family:Heiti SC, sans-serif'><h2>There's an old joke - um... two elderly women are at a Catskill mountain resort, and one of 'em says:<br/><br/> 'Boy, the food at this place is really terrible.'<br/><br/> The other one says: <br/><br/>'Yeah, I know; and such small portions.'<br/><br/> Well, that's essentially how I feel about life - full of loneliness, and misery, and suffering, and unhappiness, and it's all over much too quickly.<br/><br/> The... the other important joke, for me, is one that's usually attributed to Groucho Marx, but I think it appears originally in Freud's 'Wit and Its Relation to the Unconscious,' and it goes like this - I'm paraphrasing <br/><br/> 'I would never want to belong to any club that would have someone like me for a member.' <br/><br/> That's the key joke of my adult life, in terms of my relationships with women.</h2><i>Woody Allen</i></body></html>" baseURL:nil];
    _webView.scrollView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [(HUScrollableNavigationController *)self.navigationController observeScrollView:self.webView forDelayDistance:10];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
