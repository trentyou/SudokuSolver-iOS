//
//  HMDBoardPickerViewController.m
//  Sudoku Solver
//
//  Created by Trent You on 1/26/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

#import "HMDBoardPickerViewController.h"
#import "HMDSolutionViewController.h"
#import "HMDSudokuCell.h"

@interface HMDBoardPickerViewController ()

@property (nonatomic, strong) NSMutableArray *internalSudokuBoard;

@property (nonatomic, copy) NSString *startingNumbers;

@end

@implementation HMDBoardPickerViewController

static NSNumberFormatter *numberFormatter;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!numberFormatter) numberFormatter = [[NSNumberFormatter alloc] init];
    
    self.startingNumbers = @"000260701680070090190004500820100040004602900050003028009300074040050036703018000";
    
}


- (void)setupInternalSudokuBoard:(NSString *)startingNumbers
{
    self.internalSudokuBoard = [[NSMutableArray alloc] init];
    
    for (NSInteger row = 0; row < 9; row++) {
        NSMutableArray *column = [[NSMutableArray alloc] init];
        [self.internalSudokuBoard insertObject:column atIndex:row];
    }
    
    for (NSInteger row = 0; row < 9; row++) {
        for (NSInteger column = 0; column < 9; column++) {
            
            NSNumber *answer = [numberFormatter numberFromString:[startingNumbers substringToIndex:1]];
            HMDSudokuCell *cell = [[HMDSudokuCell alloc] initWithAnswer:answer possibleAnswers:nil];
            
            [self.internalSudokuBoard[row] insertObject:cell atIndex:column];
            startingNumbers = [startingNumbers substringFromIndex:1];
        }
    }
    
    [self fillPossibleAnswers];
    [self solveBoard];
    
}

- (void)fillPossibleAnswers
{
    NSLog(@"Fill possible answers:");
    
    for (NSInteger row = 0; row < 9; row++) {
        for (NSInteger column = 0; column < 9; column++) {
            
            HMDSudokuCell *cell = self.internalSudokuBoard[row][column];
            NSNumber *answer = cell.answer;
            
            if ([answer integerValue] == 0) {
                NSMutableArray *possibleAnswers = [[NSMutableArray alloc] init];
                
                if (row == 6 && column == 5) {
                    NSLog(@"Problem area");
                    NSLog(@"Quadrant: %d", [self getQuadrantFromRow:row andColumn:column]);
                }
                for (NSInteger i = 1; i <= 9; i++) {
                    if ([self checkValidPlacementOfAnswer:i inRow:row andColumn:column]) {
                        [possibleAnswers addObject:[NSNumber numberWithInteger:i]];
                    }
                }
                
                cell.possibleAnswers = possibleAnswers;
                NSLog(@"Row: %d", row);
                NSLog(@"Column: %d", column);
                NSLog(@"%@", cell.possibleAnswers);
            }
        }
    }
}

- (void)updatePossibleAnswers
{
    for (NSInteger row = 0; row < 9; row++) {
        for (NSInteger column = 0; column < 9; column++) {
            
            HMDSudokuCell *cell = self.internalSudokuBoard[row][column];
            NSNumber *answer = cell.answer;
            
            if ([answer integerValue] == 0) {
                
                NSArray *possibleAnswers = [cell.possibleAnswers copy];
                
                for (NSNumber *possibleAnswer in possibleAnswers) {
                    
                    if (![self checkValidPlacementOfAnswer:[possibleAnswer integerValue] inRow:row andColumn:column]) {
                        [cell.possibleAnswers removeObject:possibleAnswer];
                    }
                }
            }
        }
    }
}

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
            HMDSudokuCell *cell = self.internalSudokuBoard[row][inputColumn];
            NSNumber *cellAnswer = cell.answer;
            
            if ([cellAnswer integerValue] == answer) {
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
            
            HMDSudokuCell *cell = self.internalSudokuBoard[inputRow][column];
            NSNumber *cellAnswer = cell.answer;
            
            if ([cellAnswer integerValue] == answer) {
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
    NSInteger rowMin;
    NSInteger rowMax;
    
    NSInteger columnMin;
    NSInteger columnMax;
    
    switch ([self getQuadrantFromRow:inputRow andColumn:inputColumn]) {
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
    
    
    for (NSInteger row = rowMin; row <= rowMax; row++) {
        for (NSInteger column = columnMin; column <= columnMax; column++) {
            if (row != inputRow && column != inputColumn) {
                
                HMDSudokuCell *cell = self.internalSudokuBoard[row][column];
                NSNumber *cellAnswer = cell.answer;
                
                if ([cellAnswer integerValue] == answer) {
                    return YES;
                }
            }

        }
    }
    
    
    return NO;
    
}

- (BOOL)subGroupExclusionCheck
{
    BOOL changed = NO;
    
    for (NSInteger row = 0; row < 7; row += 3) {
        for (NSInteger column = 0; column < 7; column += 3) {
            
            for (NSInteger possibleAnswer = 1; possibleAnswer <= 9; possibleAnswer++) {
                
                NSInteger occurenceCount = 0;
                NSInteger rowCoordinateOfOccurence = 0;
                NSInteger columnCoordinateOfOccurence = 0;
                
                for (NSInteger quadrantRow = 0; quadrantRow <= 2; quadrantRow++) {
                    for (NSInteger quadrantColumn = 0; quadrantColumn <= 2; quadrantColumn++) {
                        
                        HMDSudokuCell *cell = self.internalSudokuBoard[row + quadrantRow][column + quadrantColumn];
                        NSMutableArray *possibleAnswers = cell.possibleAnswers;
                        
                        if ([possibleAnswers containsObject:[NSNumber numberWithInteger:possibleAnswer]]) {
                            occurenceCount++;
                            rowCoordinateOfOccurence = row + quadrantRow;
                            columnCoordinateOfOccurence = column + quadrantColumn;
                        }
                    }
                }
                
                if (occurenceCount == 1) {
                    HMDSudokuCell *cell = self.internalSudokuBoard[rowCoordinateOfOccurence][columnCoordinateOfOccurence];
                    cell.answer = [NSNumber numberWithInteger:possibleAnswer];
                    [cell.possibleAnswers removeAllObjects];
                    changed = YES;

                    [self updatePossibleAnswers];
                }
                
                
            }
        }
    }
    
    return changed;
}

- (void)solveBoard
{
    BOOL changed;
    
    do {
        changed = NO;
        
        for (NSInteger row = 0; row < 9; row++) {
            for (NSInteger column = 0; column < 9; column++) {
                
                HMDSudokuCell *cell = self.internalSudokuBoard[row][column];
                NSNumber *answer = cell.answer;
                
                NSLog(@"Row: %ld", (long)row);
                NSLog(@"Column %ld", (long)column);
                NSLog(@"cell.possibleAnswers before: %@", cell.possibleAnswers);

                if ([answer integerValue] == 0 && [cell.possibleAnswers count] == 1) {
                    
                    cell.answer = [cell.possibleAnswers firstObject];
                    [cell.possibleAnswers removeAllObjects];
                    NSLog(@"cell.possibleAnswers after: %@", cell.possibleAnswers);

                    
                    [self updatePossibleAnswers];
                    
                    changed = YES;
                }
            }
        }
        
        //changed = [self subGroupExclusionCheck];
        NSLog(changed ? @"Yes" : @"No");
        NSLog(@"Loop");
    } while (changed);
    
    [self printBoard];
}



- (void)printBoard
{
    NSMutableArray *solution = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            
            HMDSudokuCell *cell = self.internalSudokuBoard[i][j];
            NSNumber *value = cell.answer;
            
            [solution addObject:value];
        }
    }
    
    HMDSolutionViewController *solutionViewController = [[HMDSolutionViewController alloc] initWithSolution:[solution copy]];
    [self presentViewController:solutionViewController animated:YES completion:nil];
}


- (IBAction)solveButton:(id)sender
{
    [self setupInternalSudokuBoard:self.startingNumbers];
}




@end
