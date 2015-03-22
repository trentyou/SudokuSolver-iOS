//
//  HMDSolutionViewController.m
//  Sudoku Solver
//
//  Created by Trent You on 1/26/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

#import "HMDMainMenuViewController.h"
#import "HMDSolutionViewController.h"
#import "HMDSudokuCell.h"

#import "UIColor+_SudokuSolver.h"

#import <QuartzCore/QuartzCore.h>

@interface HMDSolutionViewController ()

@property (weak, nonatomic) IBOutlet UILabel *timeToSolveLabel;


@property (nonatomic, copy) NSArray *solution;

@property (nonatomic) double timeToSolve;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@end

@implementation HMDSolutionViewController

#pragma mark - Init

- (instancetype)initWithSolution:(NSArray *)solution andTimeToSolve:(double)timeToSolve
{
    self = [super initWithNibName:nil bundle:nil];
    
    if (self) {

        _timeToSolve = timeToSolve;
        _solution = solution;
    }
    
    return self;
}

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupBackgroundColors];
    [self setupTimeToSolveLabel];
    [self setupSolutionBoard];
}

#pragma mark - Setup

- (void)setupBackgroundColors
{
    self.doneButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:ACTION_BUTTON_NORMAL];

}

- (NSString *)formatTimeToSolveToString:(double)timeToSolve
{
    NSString *timeString;
    
    NSInteger minutes = (NSInteger)(timeToSolve / 60);
    timeToSolve -= minutes * 60.0;
    
    NSString *secondsString = [NSString stringWithFormat:@"%f seconds", timeToSolve];
    
    if (minutes != 0) {
        if (minutes == 1) {
            timeString = [NSString stringWithFormat:@"%ld minute ", (long)minutes];
        } else {
            timeString = [NSString stringWithFormat:@"%ld minutes ", (long)minutes];
        }
        
        timeString = [timeString stringByAppendingString:secondsString];
    } else {
        timeString = secondsString;
    }
    
    return timeString;
}

#pragma mark - Setup sudoku board

- (void)setupTimeToSolveLabel
{
    if (self.timeToSolve != 0.0) {
        self.timeToSolveLabel.text = [self formatTimeToSolveToString:self.timeToSolve];
    }
}

- (void)setupSolutionBoard
{
    self.view.backgroundColor = [UIColor beigeColor];
    
    CGFloat labelOffset = 10.0f;
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
            
            HMDSudokuCell *sudokuCell = self.solution[row][column];
      
            if (!sudokuCell.isPartOfInitialBoard) {
                cell.textColor = [UIColor colorWithRed:0/255.0 green:150/255.0 blue:50/255.0 alpha:1.0];
            }
            
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

#pragma mark - Navigation


- (IBAction)dismiss:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"resetBoardPicker" object:nil];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self.navigationController popToRootViewControllerAnimated:YES];
}






@end
