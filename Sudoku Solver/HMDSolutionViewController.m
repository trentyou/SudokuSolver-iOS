//
//  HMDSolutionViewController.m
//  Sudoku Solver
//
//  Created by Trent You on 1/26/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

#import "HMDSolutionViewController.h"
#import "HMDSudokuCell.h"

#import <QuartzCore/QuartzCore.h>

@interface HMDSolutionViewController ()

@property (weak, nonatomic) IBOutlet UILabel *timeToSolveLabel;


@property (nonatomic, copy) NSArray *solution;
@property (nonatomic, copy) NSArray *originalBoard;

@property (nonatomic) double timeToSolve;

@end

@implementation HMDSolutionViewController

- (instancetype)initWithSolution:(NSArray *)solution originalBoard:(NSArray *)originalBoard andTimeToSolve:(double)timeToSolve
{
    self = [super initWithNibName:nil bundle:nil];
    
    if (self) {
        
        if (timeToSolve != 0.0) {
            _timeToSolve = timeToSolve;
        }
        
        
        _solution = solution;
        _originalBoard = originalBoard;
    }
    
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTimeToSolveLabel];
    [self setupSolutionBoard];
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
    self.timeToSolveLabel.text = [self formatTimeToSolveToString:self.timeToSolve];
}

- (void)setupSolutionBoard
{
    self.view.backgroundColor = [UIColor colorWithRed:253/255.0 green:245/255.0 blue:230/255.0 alpha:1.0];
    
    CGFloat labelSize = ([UIScreen mainScreen].bounds.size.width - 15.0f) / 9.0;
    
    CGFloat xStartPosition = ([UIScreen mainScreen].bounds.size.width - (labelSize * 9)) / 2.0;
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
                CALayer *bottomBorder = [CALayer layer];
                
                bottomBorder.borderColor = [UIColor darkGrayColor].CGColor;
                bottomBorder.borderWidth = 2.0f;
                bottomBorder.frame = CGRectMake(0.0f, labelSize, labelSize, 1.0f);
                
                [cell.layer addSublayer:bottomBorder];
            }
            
            if (column == 2 || column == 5) {
                CALayer *rightBorder = [CALayer layer];
                
                rightBorder.borderColor = [UIColor darkGrayColor].CGColor;
                rightBorder.borderWidth = 2.0f;
                rightBorder.frame = CGRectMake(labelSize, 0.0f, 2.0f, labelSize);
                
                [cell.layer addSublayer:rightBorder];
            }
            
            cell.backgroundColor = [UIColor whiteColor];
            
            HMDSudokuCell *answer = self.solution[row][column];
            HMDSudokuCell *originalBoardValue = self.originalBoard[row][column];
            
            if ([originalBoardValue.answer integerValue] != [answer.answer integerValue]) {
                cell.textColor = [UIColor colorWithRed:0/255.0 green:150/255.0 blue:50/255.0 alpha:1.0];
            }
            
            cell.font = [UIFont fontWithName:@"quicksand-regular" size:20];
            if ([answer.answer integerValue] == 0) {
                cell.text = @"";
            } else {
                cell.text = [answer.answer stringValue];
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
    [self dismissViewControllerAnimated:YES completion:nil];
}






@end
