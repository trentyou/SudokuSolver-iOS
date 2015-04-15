//
//  HMDMainMenuViewController.m
//  Sudoku Solver
//
//  Created by Trent You on 3/17/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

#import "HMDMainMenuViewController.h"
#import "HMDBoardPickerViewController.h"
#import "HMDPrevSolutionPageViewController.h"
#import "HMDSolutionArchiveStore.h"
#import "HMDArchivedSolution.h"

#import "UIColor+_SudokuSolver.h"

@interface HMDMainMenuViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation HMDMainMenuViewController

static HMDBoardPickerViewController *boardPicker;

const float ACTION_BUTTON_NORMAL = 0.6;
const float ACTION_BUTTON_HIGHLIGHTED = 0.2;

#pragma mark - View life cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupBoardPicker];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [self setupBackgroundColors];
    [self setupTitleLabel];
    NSMutableArray *unarchivedSolutions = [[HMDSolutionArchiveStore sharedStore] solutionList];
    
    for (HMDArchivedSolution *solution in unarchivedSolutions) {
        NSLog(@"solutionString: %@", solution.solutionString);
        NSLog(@"length: %ld", solution.solutionString.length);
        NSLog(@"%@", [solution.solutionString class]);
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupNavigationController];
}

#pragma mark - Setup

- (void)setupNavigationController
{
    self.navigationController.navigationBar.hidden = YES;
}

- (void)setupBoardPicker
{
    boardPicker = [[HMDBoardPickerViewController alloc] init];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(resetBoardPicker) name:@"resetBoardPicker" object:nil];
}

- (void)setupBackgroundColors
{
    self.tableView.backgroundColor = [UIColor beigeColor];
    self.titleLabel.backgroundColor = [UIColor lightBeigeColor];
}
- (void)setupTitleLabel
{
    self.titleLabel.text = @"Pocket Sudoku Solver";
    self.titleLabel.font = [UIFont fontWithName:@"quicksand-regular" size:40];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor lightGrayColor];
    self.titleLabel.numberOfLines = 2;
    
    self.titleLabel.backgroundColor = [UIColor beigeColor];
}

#pragma mark - Reset board picker

- (void)resetBoardPicker
{
    boardPicker = [[HMDBoardPickerViewController alloc] init];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 1;
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    if (indexPath.section == 0) {

        cell.textLabel.text = @"Solve a new puzzle";
        cell.textLabel.font = [UIFont fontWithName:@"quicksand-regular" size:17];
        cell.textLabel.textColor = [UIColor lightGrayColor];
            
    } else if (indexPath.section == 1) {
        cell.textLabel.text = @"See past solutions";
        cell.textLabel.font = [UIFont fontWithName:@"quicksand-regular" size:17];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 75.0f;
    } else if (section == 1) {
        return 5.0f;
    }
    
    return 0.0001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0001f;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            
            [self.navigationController pushViewController:boardPicker animated:YES];
            
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        
    } else if (indexPath.section == 1) {
        HMDPrevSolutionPageViewController *prevSolutions = [[HMDPrevSolutionPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        [self.navigationController pushViewController:prevSolutions animated:YES];
    }
}







@end