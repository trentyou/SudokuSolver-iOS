//
//  HMDPrevSolutionPageViewController.m
//  Sudoku Solver
//
//  Created by Trent You on 3/17/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

#import "HMDPrevSolutionPageViewController.h"

@interface HMDPrevSolutionPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@end

@implementation HMDPrevSolutionPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    return [[UIViewController alloc] init];
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    return [[UIViewController alloc] init];

}



@end
