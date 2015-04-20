//
//  HMDArchivedSolutionViewController.m
//  Sudoku Solver
//
//  Created by Trent You on 4/15/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

#import "HMDArchivedSolutionViewController.h"

#import "UIColor+_SudokuSolver.h"



@interface HMDArchivedSolutionViewController ()

@property (weak, nonatomic) IBOutlet UILabel *puzzleNumber;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (nonatomic, copy) NSString *solutionString;
@property (nonatomic, copy) NSString *initialBoardString;

@property (nonatomic, strong) NSDate *solveDate;
@property (nonatomic) NSInteger orderNumber;


@end

@implementation HMDArchivedSolutionViewController


- (instancetype)initWithArchivedSolution:(HMDArchivedSolution *)archivedSolution
{
    self = [super initWithNibName:nil bundle:nil];
    
    if (self) {
        _solutionString = archivedSolution.solutionString;
        _initialBoardString = archivedSolution.initialBoardString;
        _solveDate = archivedSolution.solveDate;
        _orderNumber = archivedSolution.puzzleOrder + 1;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupLabels];
    [self setupSolutionBoard];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.delegate viewControllerWithOrderWasSelected:self.orderNumber];
}

#pragma mark - Setup labels

- (void)setupLabels
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components: NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:self.solveDate];
    NSInteger day = components.day;
    NSInteger month = components.month;
    NSInteger year = components.year;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    NSString *monthString = [[df monthSymbols] objectAtIndex:(month - 1)];
    
    self.puzzleNumber.text = [NSString stringWithFormat:@"Puzzle #%ld", (long)self.orderNumber];
    self.dateLabel.text = [NSString stringWithFormat:@"Solved on %@ %ld, %ld", monthString, day, year];
}

#pragma mark - Setup board

- (void)setupSolutionBoard
{
    self.view.backgroundColor = [UIColor beigeColor];
        
    CGFloat labelOffset = 25.0f;
    CGFloat labelSize = ([[UIScreen mainScreen] bounds].size.width - (labelOffset * 2.0)) / 9.0;
    
    CGFloat xStartPosition = labelOffset;
    CGFloat xPosition = xStartPosition;
    
    CGFloat yStartPosition = ([[UIScreen mainScreen] bounds].size.height / 2.0) - (labelSize * 4.5);
    CGFloat yPosition = yStartPosition;
    
    for (NSInteger i = 1; i <= 81; i++) {
        NSString *firstSolutionDigit = [self.solutionString substringToIndex:1];
        self.solutionString = [self.solutionString substringFromIndex:1];
        
        NSString *firstInitialBoardDigit = [self.initialBoardString substringToIndex:1];
        self.initialBoardString = [self.initialBoardString substringFromIndex:1];
        
        UILabel *cell = [[UILabel alloc] initWithFrame:CGRectMake(xPosition, yPosition, labelSize, labelSize)];
        
        cell.textAlignment = NSTextAlignmentCenter;
        cell.layer.borderColor = [UIColor darkGrayColor].CGColor;
        cell.layer.borderWidth = 0.5f;
        cell.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
        cell.font = [UIFont fontWithName:@"quicksand-regular" size:20.0f];
        
        if ([firstSolutionDigit integerValue] == 0) {
            cell.text = [NSString stringWithFormat:@"%@", firstInitialBoardDigit];
        } else {
            cell.text = [NSString stringWithFormat:@"%@", firstSolutionDigit];
            cell.textColor = [UIColor solutionGreenColor];
        }
        
        if (i % 3 == 0 && i % 9 != 0) {
            CAShapeLayer *rightBorder = [CAShapeLayer layer];
            
            rightBorder.borderColor = [UIColor darkGrayColor].CGColor;
            rightBorder.borderWidth = 2.0f;
            rightBorder.frame = CGRectMake(labelSize - 1.5f, 0.0f, 2.0f, labelSize);
            
            [cell.layer addSublayer:rightBorder];
            
        }
        
        if ((i >= 19 && i <= 27) || (i >= 46 && i <= 54)) {
            CAShapeLayer *bottomBorder = [CAShapeLayer layer];
            
            bottomBorder.borderColor = [UIColor darkGrayColor].CGColor;
            bottomBorder.borderWidth = 2.0f;
            bottomBorder.frame = CGRectMake(0.0f, labelSize - 1.5f, labelSize, 1.0f);
            
            [cell.layer addSublayer:bottomBorder];
        }
        
        [self.view addSubview:cell];
        
        xPosition += labelSize;
        
        if (i % 9 == 0) {
            xPosition = xStartPosition;
            yPosition += labelSize;
        }
        
    }
    
}




@end
