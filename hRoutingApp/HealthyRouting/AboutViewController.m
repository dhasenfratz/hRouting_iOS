//
//  AboutViewController.m
//  HealthyRouting
//
//  Created by David Hasenfratz on 24/09/14.
//  Copyright (c) 2014 TIK, ETH Zurich. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // If it is a phone with small screen size, use small font (i.e., iPhone 4s)
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if (result.height < 500) {
            [self.aboutTextView setFont:[UIFont systemFontOfSize:12.5]];
        }
    }
    
    // Load background image
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    if (self.view.frame.size.width == 768 && self.view.frame.size.height == 1024)
        imageView.image = [UIImage imageNamed:@"bg768x1024_4.png"];
    else
        imageView.image = [UIImage imageNamed:@"bg640x1136_4.png"];
    // Push image view to the back
    [self.view insertSubview:imageView atIndex:0];
    
    // Add on top of the background image a transparent white layer
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-112)];
    whiteView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
    [self.view insertSubview:whiteView atIndex:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
