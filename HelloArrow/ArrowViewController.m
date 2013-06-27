//
//  ArrowViewController.m
//  HelloArrow
//
//  Created by Hamdan Javeed on 2013-06-27.
//  Copyright (c) 2013 Hamdan Javeed. All rights reserved.
//

#import "ArrowViewController.h"
#import "GLView.h"

@interface ArrowViewController ()

@end

@implementation ArrowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLView *view = [[GLView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:view];
}

@end
