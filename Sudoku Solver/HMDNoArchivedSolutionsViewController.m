//
//  HMDNoArchivedSolutionsViewController.m
//  Sudoku Solver
//
//  Created by Trent You on 4/15/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

#import "HMDNoArchivedSolutionsViewController.h"

#import "UIColor+_SudokuSolver.h"

@interface HMDNoArchivedSolutionsViewController ()

@end

@implementation HMDNoArchivedSolutionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor beigeColor];
    [self setupNavigationBar];

}


- (void)setupNavigationBar
{
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor beigeColor];
    self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
}


@end
