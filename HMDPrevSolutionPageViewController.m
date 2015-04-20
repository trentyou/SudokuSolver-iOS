//
//  HMDPrevSolutionPageViewController.m
//  Sudoku Solver
//
//  Created by Trent You on 3/17/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

#import "HMDPrevSolutionPageViewController.h"
#import "HMDArchivedSolution.h"
#import "HMDArchivedSolutionViewController.h"

#import "UIColor+_SudokuSolver.h"

@interface HMDPrevSolutionPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, HMDArchivedSolutionViewControllerDelegate>

@property (nonatomic, strong) UIPageViewController *pageViewController;

@property (nonatomic, copy) NSArray *solutionList;

@property (nonatomic) NSInteger numberOfPages;
@property (nonatomic) NSInteger currentPage;

@property (nonatomic, strong) HMDArchivedSolution *currentSolutionPage;

@end

@implementation HMDPrevSolutionPageViewController


#pragma mark - Init

- (instancetype)initWithSolutionList:(NSArray *)solutionList
{
    self = [super initWithNibName:nil bundle:nil];
    
    if (self) {
        _solutionList = solutionList;
        _numberOfPages = _solutionList.count;
        
    }
    
    return self;
}

#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor beigeColor];
    [self setupPageViewControllerContent];
    [self setupNavigationBar];
}



#pragma mark - Setup

- (void)setupNavigationBar
{
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor beigeColor];
    self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)setupPageViewControllerContent
{
    self.currentPage = 0;
    
    HMDArchivedSolution *firstSolution = [self.solutionList firstObject];
    HMDArchivedSolutionViewController *firstViewController = [[HMDArchivedSolutionViewController alloc] initWithArchivedSolution:firstSolution];
    firstViewController.delegate = self;
    
    NSArray *viewControllers = [[NSMutableArray alloc] initWithObjects:firstViewController, nil];
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;
    
    self.pageViewController.view.frame = self.view.bounds;
    
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
}

#pragma mark - Delegate methods for lazy loading

- (void)viewControllerWithOrderWasSelected:(NSInteger)order
{
    self.currentPage = order - 1;
}

#pragma mark - Page view controller data source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if (self.currentPage == self.numberOfPages - 1) {
        return nil;
    } else {
        HMDArchivedSolution *nextSolution = self.solutionList[self.currentPage + 1];
        HMDArchivedSolutionViewController *nextViewController = [[HMDArchivedSolutionViewController alloc] initWithArchivedSolution:nextSolution];
        nextViewController.delegate = self;
        
        return nextViewController;
    }
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    if (self.currentPage == 0) {
        return nil;
    } else {
        HMDArchivedSolution *prevSolution = self.solutionList[self.currentPage - 1];
        HMDArchivedSolutionViewController *prevViewController = [[HMDArchivedSolutionViewController alloc] initWithArchivedSolution:prevSolution];
        prevViewController.delegate = self;
        
        return prevViewController;
    }
    
}


- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return self.numberOfPages;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return self.currentPage;
}




@end
