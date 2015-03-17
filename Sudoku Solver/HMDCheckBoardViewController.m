//
//  HMDCheckBoardViewController.m
//  Sudoku Solver
//
//  Created by Trent You on 3/16/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//
#import "HMDMainMenuViewController.h"
#import "HMDCheckBoardViewController.h"
#import "HMDSolutionViewController.h"
#import "HMDSudokuCell.h"
#import "HMDSolver.h"
#import "MBProgressHUD.h"

#import "UIColor+_SudokuSolver.h"

@interface HMDCheckBoardViewController ()

@property (nonatomic, copy) NSMutableArray *initialBoard;

@property (nonatomic, copy) NSString *startingNumbers;
@property (nonatomic, strong) HMDSolver *solver;

@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UIButton *noButton;


@end

@implementation HMDCheckBoardViewController

- (instancetype)initWithInitialBoard:(NSMutableArray *)initialBoard
{
    self = [super initWithNibName:nil bundle:nil];
    
    if (self) {
        _initialBoard = initialBoard;
    }
    
    return self;
}

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigationController];
    [self setupButtons];
    [self setupSolutionBoard];
    
}

#pragma mark - Setup

- (void)setupNavigationController
{
    self.navigationController.navigationBar.hidden = YES;
}

- (void)setupButtons
{
    self.yesButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:ACTION_BUTTON_NORMAL];
    self.noButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:ACTION_BUTTON_NORMAL];


}

- (void)setupSolutionBoard
{
    self.view.backgroundColor = [UIColor beigeColor];
    
    CGFloat labelOffset = 30.0f;
    CGFloat labelSize = ([UIScreen mainScreen].bounds.size.width - (labelOffset * 2.0)) / 9.0;
    
    
    CGFloat xStartPosition = labelOffset;
    CGFloat yStartPosition = ([UIScreen mainScreen].bounds.size.height / 2.0) - (labelSize * 4.5);
    
    CGFloat xPosition = xStartPosition;
    CGFloat yPosition = yStartPosition;
    
    for (NSInteger row = 0; row < 9; row++) {
        for (NSInteger column = 0; column < 9; column++) {
            
            UILabel *cell = [[UILabel alloc] initWithFrame:CGRectMake(xPosition, yPosition, labelSize, labelSize)];
            
            cell.textAlignment = NSTextAlignmentCenter;
            cell.layer.borderColor = [UIColor lightGrayColor].CGColor;
            cell.layer.borderWidth = 0.5f;
            
            if (row == 2 || row == 5) {
                CAShapeLayer *bottomBorder = [CAShapeLayer layer];
                
                bottomBorder.borderColor = [UIColor darkGrayColor].CGColor;
                bottomBorder.borderWidth = 2.0f;
                bottomBorder.frame = CGRectMake(0.0f, labelSize - 1.5f, labelSize, 1.0f);
                
                [cell.layer addSublayer:bottomBorder];
            }
            
            if (column == 2 || column == 5) {
                CAShapeLayer *rightBorder = [CAShapeLayer layer];
                
                rightBorder.borderColor = [UIColor darkGrayColor].CGColor;
                rightBorder.borderWidth = 2.0f;
                rightBorder.frame = CGRectMake(labelSize - 1.5f, 0.0f, 2.0f, labelSize);
                
                [cell.layer addSublayer:rightBorder];
            }
            
            cell.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
            
            HMDSudokuCell *sudokuCell = self.initialBoard[row][column];

            cell.font = [UIFont fontWithName:@"quicksand-regular" size:20];
            
            if (sudokuCell.answer == 0) {
                cell.text = @"";
            } else {
                cell.text = [NSString stringWithFormat:@"%ld", (long)sudokuCell.answer];
            }
            
            [self.view addSubview:cell];
            
            xPosition += labelSize;
            
            if (column == 8) {
                yPosition += labelSize;
                xPosition = xStartPosition;
            }
        }
        
    }
    
    
}




- (IBAction)solve:(id)sender
{
    self.solver = [[HMDSolver alloc] init];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Solving..";
    hud.labelFont = [UIFont fontWithName:@"quicksand-regular" size:20];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDate *startTime = [NSDate date];
        NSArray *solution = [self.solver solvePuzzleWithStartingNumbers:[self.initialBoard copy]];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSDate *endTime = [NSDate date];
            NSTimeInterval timeToSolve = [endTime timeIntervalSinceDate:startTime];
            
            if (solution) {
                [self printBoardWithSolution:solution andTimeToSolve:timeToSolve];
                self.solver = nil;
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
            } else {
                //error message for incorrect starting puzzle
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh-oh" message:@"Did you enter the puzzle correctly?" delegate:nil cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
                [alert show];
            }
            
        });
    });
}

- (void)printBoardWithSolution:(NSArray *)solution andTimeToSolve:(double)timeToSolve
{
    HMDSolutionViewController *solutionViewController = [[HMDSolutionViewController alloc] initWithSolution:solution andTimeToSolve:timeToSolve];
    [self.navigationController pushViewController:solutionViewController animated:YES];
}

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
