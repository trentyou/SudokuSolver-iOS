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
#import "HMDRowAndColumnMinMaxCoordinates.h"
#import "MBProgressHUD.h"

#import "UIColor+_SudokuSolver.h"

@interface HMDCheckBoardViewController ()

@property (nonatomic, copy) NSMutableArray *initialBoard;

@property (nonatomic, copy) NSString *startingNumbers;
@property (nonatomic, strong) HMDSolver *solver;

@property (nonatomic) BOOL hasErrors;

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
    [self setupSolutionBoard];
    [self setupButtons];

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
    
    if (self.hasErrors) {
        self.yesButton.enabled = NO;
        self.yesButton.alpha = 0.4;
    }
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
            
            if (sudokuCell.answer != 0 && ![self checkValidPlacementOfAnswer:sudokuCell.answer inRow:row andColumn:column]) {
                cell.textColor = [UIColor redColor];
                self.hasErrors = YES;
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

#pragma mark - Checking for input errors

- (BOOL)checkValidPlacementOfAnswer:(NSInteger)answer inRow:(NSInteger)row andColumn:(NSInteger)column
{
    if (![self checkColumnForAnswer:answer inRow:row andColumn:column] && ![self checkRowForAnswer:answer inRow:row andColumn:column] && ![self checkQuadrantForAnswer:answer inRow:row andColumn:column]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)checkColumnForAnswer:(NSInteger)answer inRow:(NSInteger)inputRow andColumn:(NSInteger)inputColumn
{
    for (NSInteger row = 0; row < 9; row++) {
        if (row != inputRow) {
            HMDSudokuCell *cell = self.initialBoard[row][inputColumn];
            NSInteger cellAnswer = cell.answer;
            
            if (cellAnswer == answer) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL)checkRowForAnswer:(NSInteger)answer inRow:(NSInteger)inputRow andColumn:(NSInteger)inputColumn
{
    for (NSInteger column = 0; column < 9; column++) {
        if (column != inputColumn) {
            
            HMDSudokuCell *cell = self.initialBoard[inputRow][column];
            NSInteger cellAnswer = cell.answer;
            
            if (cellAnswer == answer) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (NSInteger)getQuadrantFromRow:(NSInteger)row andColumn:(NSInteger)column
{
    if (row <= 2) {
        return (column / 3) + 1;
    } else if (row > 2 && row < 6) {
        return (column / 3) + 4;
    } else {
        return (column / 3) + 7;
    }
}

- (BOOL)checkQuadrantForAnswer:(NSInteger)answer inRow:(NSInteger)inputRow andColumn:(NSInteger)inputColumn
{
    HMDRowAndColumnMinMaxCoordinates *coordinates = [self quadrantBoundariesForRow:inputRow andColumn:inputColumn];
    
    for (NSInteger row = coordinates.rowMin; row <= coordinates.rowMax; row++) {
        for (NSInteger column = coordinates.columnMin; column <= coordinates.columnMax; column++) {
            if (row != inputRow && column != inputColumn) {
                
                HMDSudokuCell *cell = self.initialBoard[row][column];
                NSInteger cellAnswer = cell.answer;
                
                if (cellAnswer == answer) {
                    return YES;
                }
            }
            
        }
    }
    
    return NO;
    
}

- (HMDRowAndColumnMinMaxCoordinates *)quadrantBoundariesForRow:(NSInteger)row andColumn:(NSInteger)column
{
    NSInteger rowMin;
    NSInteger rowMax;
    
    NSInteger columnMin;
    NSInteger columnMax;
    
    switch ([self getQuadrantFromRow:row andColumn:column]) {
        case 1:
            rowMin = 0;
            rowMax = 2;
            
            columnMin = 0;
            columnMax = 2;
            break;
            
        case 2:
            rowMin = 0;
            rowMax = 2;
            
            columnMin = 3;
            columnMax = 5;
            break;
            
        case 3:
            rowMin = 0;
            rowMax = 2;
            
            columnMin = 6;
            columnMax = 8;
            break;
            
        case 4:
            rowMin = 3;
            rowMax = 5;
            
            columnMin = 0;
            columnMax = 2;
            break;
            
        case 5:
            rowMin = 3;
            rowMax = 5;
            
            columnMin = 3;
            columnMax = 5;
            break;
            
        case 6:
            rowMin = 3;
            rowMax = 5;
            
            columnMin = 6;
            columnMax = 8;
            break;
            
        case 7:
            rowMin = 6;
            rowMax = 8;
            
            columnMin = 0;
            columnMax = 2;
            break;
            
        case 8:
            rowMin = 6;
            rowMax = 8;
            
            columnMin = 3;
            columnMax = 5;
            break;
            
        case 9:
            rowMin = 6;
            rowMax = 8;
            
            columnMin = 6;
            columnMax = 8;
            break;
            
            
        default:
            rowMin = 0;
            rowMax = 2;
            
            columnMin = 0;
            columnMax = 2;
            break;
    }
    
    HMDRowAndColumnMinMaxCoordinates *coordinates = [[HMDRowAndColumnMinMaxCoordinates alloc] init];
    coordinates.rowMin = rowMin;
    coordinates.rowMax = rowMax;
    
    coordinates.columnMin = columnMin;
    coordinates.columnMax = columnMax;
    
    return coordinates;
}



#pragma mark - User actions

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
