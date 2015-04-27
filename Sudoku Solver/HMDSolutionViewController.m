//
//  HMDSolutionViewController.m
//  Sudoku Solver
//
//  Created by Trent You on 1/26/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

#import "HMDMainMenuViewController.h"
#import "HMDSolutionViewController.h"
#import "HMDSolutionArchiveStore.h"
#import "HMDSudokuCell.h"

#import "UIColor+_SudokuSolver.h"

#import <QuartzCore/QuartzCore.h>

@interface HMDSolutionViewController ()

@property (weak, nonatomic) IBOutlet UILabel *timeToSolveLabel;


@property (nonatomic, copy) NSArray *arraySolution;
@property (nonatomic, strong) HMDSwiftSolution *stringSolution;

@property (nonatomic) BOOL isUsingArraySolution;

@property (nonatomic) double timeToSolve;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@end

@implementation HMDSolutionViewController

#pragma mark - Init

- (instancetype)initWithArraySolution:(NSArray *)solution andTimeToSolve:(double)timeToSolve
{
    self = [super initWithNibName:nil bundle:nil];
    
    if (self) {

        _timeToSolve = timeToSolve;
        _arraySolution = solution;
        _isUsingArraySolution = YES;
    }
    
    return self;
}

- (instancetype)initWithStringSolution:(HMDSwiftSolution *)solution andTimeToSolve:(double)timeToSolve
{
    self = [super initWithNibName:nil bundle:nil];
    
    if (self) {
        _timeToSolve = timeToSolve;
        _stringSolution = solution;
        _isUsingArraySolution = NO;
        
    }
    
    return self;
}



#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupBackgroundColors];
    [self setupTimeToSolveLabel];
    self.isUsingArraySolution ? [self setupSolutionBoardFromArray] : [self setupSolutionBoardFromString];
    self.isUsingArraySolution ? [self archiveArraySolution] : [self archiveStringSolution];
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
        NSString *prefix = @"in ";
        NSString *formattedTime = [self formatTimeToSolveToString:self.timeToSolve];
        
        self.timeToSolveLabel.text = [prefix stringByAppendingString:formattedTime];
    }
}

- (void)setupSolutionBoardFromArray
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
            
            HMDSudokuCell *sudokuCell = self.arraySolution[row][column];
      
            if (!sudokuCell.isPartOfInitialBoard) {
                cell.textColor = [UIColor solutionGreenColor];            }
            
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

- (void)setupSolutionBoardFromString
{
    self.view.backgroundColor = [UIColor beigeColor];
    
    NSString *solution = self.stringSolution.solution;
    NSString *initialBoard = self.stringSolution.initialBoard;
    
    CGFloat labelOffset = 10.0f;
    CGFloat labelSize = ([UIScreen mainScreen].bounds.size.width - (labelOffset * 2.0)) / 9.0;
    
    CGFloat xStartPosition = labelOffset;
    CGFloat yStartPosition = ([UIScreen mainScreen].bounds.size.height / 2.0) - (labelSize * 4.5);
    
    CGFloat xPosition = xStartPosition;
    CGFloat yPosition = yStartPosition;
    
    for (NSInteger i = 1; i <= 81; i++) {
            
        UILabel *cell = [[UILabel alloc] initWithFrame:CGRectMake(xPosition, yPosition, labelSize, labelSize)];
        
        cell.textAlignment = NSTextAlignmentCenter;
        cell.layer.borderColor = [UIColor lightGrayColor].CGColor;
        cell.layer.borderWidth = 0.5f;
        
        if ((i >= 19 && i <= 27) || (i >= 46 && i <= 54)) {
            CAShapeLayer *bottomBorder = [CAShapeLayer layer];
            
            bottomBorder.borderColor = [UIColor darkGrayColor].CGColor;
            bottomBorder.borderWidth = 2.0f;
            bottomBorder.frame = CGRectMake(0.0f, labelSize - 1.5f, labelSize, 1.0f);
            
            [cell.layer addSublayer:bottomBorder];
        }
        
        if (i % 3 == 0 && i % 9 != 0) {
            CAShapeLayer *rightBorder = [CAShapeLayer layer];
            
            rightBorder.borderColor = [UIColor darkGrayColor].CGColor;
            rightBorder.borderWidth = 2.0f;
            rightBorder.frame = CGRectMake(labelSize - 1.5f, 0.0f, 2.0f, labelSize);
            
            [cell.layer addSublayer:rightBorder];
        }
        
        cell.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
        
        NSString *solutionFirstDigit = [solution substringToIndex:1];
        solution = [solution substringFromIndex:1];
        
        NSString *initialBoardFirstDigit = [initialBoard substringToIndex:1];
        initialBoard = [initialBoard substringFromIndex:1];
        
        
        if ([initialBoardFirstDigit integerValue] == 0) {
            cell.textColor = [UIColor solutionGreenColor];
        }
        
        cell.text = [NSString stringWithFormat:@"%@", solutionFirstDigit];
        cell.font = [UIFont fontWithName:@"quicksand-regular" size:20];
        
        [self.view addSubview:cell];
        
        xPosition += labelSize;
        
        if (i % 9 == 0) {
            xPosition = xStartPosition;
            yPosition += labelSize;
        }
        
        
    }
    
}




#pragma mark - Archiving solution

- (void)archiveArraySolution
{
    NSString *solutionString = @"";
    NSString *initialBoardString = @"";
    NSString *zeroString = @"0";
    
    for (NSInteger row = 0; row < 9; row++) {
        for (NSInteger column = 0; column < 9; column++) {
            HMDSudokuCell *cell = self.arraySolution[row][column];
            NSString *answerString = [NSString stringWithFormat:@"%ld", (long)cell.answer];

            if (cell.isPartOfInitialBoard) {
                initialBoardString = [initialBoardString stringByAppendingString:answerString];
                solutionString = [solutionString stringByAppendingString:zeroString];
            } else {
                initialBoardString = [initialBoardString stringByAppendingString:zeroString];
                solutionString = [solutionString stringByAppendingString:answerString];
            }
            
        }
    }

    [[HMDSolutionArchiveStore sharedStore] archiveSolution:solutionString andInitialBoard:initialBoardString];
    
}

- (void)archiveStringSolution
{
    [[HMDSolutionArchiveStore sharedStore] archiveSolution:self.stringSolution.solution andInitialBoard:self.stringSolution.initialBoard];
}



#pragma mark - Navigation


- (IBAction)dismiss:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"resetBoardPicker" object:nil];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self.navigationController popToRootViewControllerAnimated:YES];
}






@end
