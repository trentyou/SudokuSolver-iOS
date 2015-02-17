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
#import "HMDCellCoordinates.h"
#import "HMDSudokuTree.h"
#import "HMDSudokuTreeNode.h"
#import "HMDPossibleAnswer.h"
#import "MBProgressHUD.h"



@interface HMDBoardPickerViewController ()

@property (nonatomic, strong) NSMutableArray *internalSudokuBoard;
@property (nonatomic, strong) NSMutableArray *internalSudokuBoardCopy;

@property (nonatomic, strong) NSMutableArray *originalBoard;

@property (nonatomic, strong) NSMutableArray *listOfCellsToGuess;


@property (nonatomic, strong) HMDSudokuTree *sudokuTree;

@property (nonatomic, copy) NSString *startingNumbers;

@end

@implementation HMDBoardPickerViewController

static NSNumberFormatter *numberFormatter;

#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!numberFormatter) numberFormatter = [[NSNumberFormatter alloc] init];
    
    //self.startingNumbers = @"000260701680070090190004500820100040004602900050003028009300074040050036703018000";
    //self.startingNumbers = @"031200700040080019006000000007040001014090560800050400000000900260030040005008270";
    //self.startingNumbers = @"607039005400060009503000082069004103000010000304700560840000206900020001100980704";
    //self.startingNumbers = @"000502800400010090005000300370850000600000004000029053006000400040070002003406000";
    //self.startingNumbers = @"610700800000000000084095037750004300000060000001900076340150720000000000008002014";
    //self.startingNumbers = @"500600400800030002030009600003507000400000001000302700002800040300060007004001006";
    //self.startingNumbers = @"760100000108000002005060007804600000020901070000005201900080600200000704000006038";
    //self.startingNumbers = @"900006000000091408380000200005009004007080300600100900009000027803650000000900005";
    self.startingNumbers = @"000670050080000009070980100052403800000000000003507690005039010300000080010052000"; //Tested one
    
    //self.startingNumbers = @"700060300000500000090300875100600000004050200000008007436007090000006000001080006"; //evil
    //self.startingNumbers = @"592001000000500000470002050000250008200000005300076000060100072000008000000700134";
    //self.startingNumbers = @"000500048020040007530000960000780000009000400000056000013000025600010070890005000";
}

#pragma mark - Initial board setup

- (void)setupInternalSudokuBoard:(NSString *)startingNumbers
{
    if (!self.internalSudokuBoard) {
        self.internalSudokuBoard = [[NSMutableArray alloc] init];
        self.originalBoard = [[NSMutableArray alloc] init];
    }
    
    // Setup the internalSudokuBoard
    for (NSInteger row = 0; row < 9; row++) {
        NSMutableArray *column = [[NSMutableArray alloc] init];
        [self.internalSudokuBoard insertObject:column atIndex:row];
    }
    
    // Filling the internalSudokuBoard from initial numbers
    for (NSInteger row = 0; row < 9; row++) {
        for (NSInteger column = 0; column < 9; column++) {
            
            NSNumber *answer = [numberFormatter numberFromString:[startingNumbers substringToIndex:1]];
            HMDSudokuCell *cell = [[HMDSudokuCell alloc] initWithAnswer:answer possibleAnswers:nil];
            [self.originalBoard addObject:answer];
            
            [self.internalSudokuBoard[row] insertObject:cell atIndex:column];
            startingNumbers = [startingNumbers substringFromIndex:1];
        }
    }
    
    //[self printBoard];
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
                
                for (NSInteger number = 1; number <= 9; number++) {
                    if ([self checkValidPlacementOfAnswer:number inRow:row andColumn:column]) {
                        HMDPossibleAnswer *possibleAnswer = [[HMDPossibleAnswer alloc] init];
                        possibleAnswer.answer = number;
                        [possibleAnswers addObject:possibleAnswer];
                    }
                }
                
                cell.possibleAnswers = possibleAnswers;

            }
        }
    }
}

#pragma mark - Utility methods for checking number placement

- (void)updatePossibleAnswers
{
    for (NSInteger row = 0; row < 9; row++) {
        for (NSInteger column = 0; column < 9; column++) {
            
            HMDSudokuCell *cell = self.internalSudokuBoard[row][column];
            NSNumber *answer = cell.answer;
            
            if ([answer integerValue] == 0) {
                
                NSArray *possibleAnswers = [cell.possibleAnswers copy];
                
                for (HMDPossibleAnswer *possibleAnswer in possibleAnswers) {
                    
                    if (![self checkValidPlacementOfAnswer:possibleAnswer.answer inRow:row andColumn:column]) {
                        [cell.possibleAnswers removeObject:possibleAnswer];
                    }
                }
            }
        }
    }
}

- (void)updatePossibleAnswersForCellsToGuess
{
    for (HMDCellCoordinates *coordinates in self.listOfCellsToGuess) {
        HMDSudokuCell *cell = self.internalSudokuBoard[coordinates.row][coordinates.column];
        
        if ([cell.answer integerValue] == 0) {
            NSArray *possibleAnswers = [cell.possibleAnswers copy];
            
            for (HMDPossibleAnswer *possibleAnswer in possibleAnswers) {
                
                if (![self checkValidPlacementOfAnswer:possibleAnswer.answer inRow:coordinates.row andColumn:coordinates.column]) {
                    [cell.possibleAnswers removeObject:possibleAnswer];
                }
            }

        }
        
    }
}

- (void)restorePossibleAnswersForCellsToGuess
{
    for (HMDCellCoordinates *coordinates in self.listOfCellsToGuess) {
        HMDSudokuCell *cell = self.internalSudokuBoard[coordinates.row][coordinates.column];
        
        if ([cell.answer integerValue] == 0) {
            NSMutableArray *possibleAnswers = [[NSMutableArray alloc] init];
            
            for (NSInteger number = 1; number <= 9; number++) {
                if ([self checkValidPlacementOfAnswer:number inRow:coordinates.row andColumn:coordinates.column]) {
                    HMDPossibleAnswer *possibleAnswer = [[HMDPossibleAnswer alloc] init];
                    possibleAnswer.answer = number;
                    [possibleAnswers addObject:possibleAnswer];
                }
            }
            
            cell.possibleAnswers = possibleAnswers;
        }
    }
    
}

- (NSInteger)instancesOfAnswerInRowColumnAndQuadrant:(NSInteger)answer inRow:(NSInteger)row andColumn:(NSInteger)column
{
    
    NSInteger columnCount = [self instancesOfAnswerInColumn:column inRow:row forAnswer:answer];
    NSInteger rowCount = [self instancesOfAnswerInRow:row inColumn:column forAnswer:answer];
    NSInteger quadrantCount = [self instancesOfAnswerInQuadrantFromRow:row inColumn:column forAnswer:answer];

    
    return columnCount + rowCount + quadrantCount;
}

- (NSInteger)instancesOfAnswerInQuadrantFromRow:(NSInteger)inputRow inColumn:(NSInteger)inputColumn forAnswer:(NSInteger)answer
{
    NSInteger count = 0;
    
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
                
                if ([cell.answer integerValue] == 0) {
                    NSArray *possibleAnswers = [cell.possibleAnswers copy];

                    for (HMDPossibleAnswer *possibleAnswer in possibleAnswers) {
                        if (possibleAnswer.answer == answer) {
                            count++;
                        }
                    }
                }
            }
            
        }
    }
    
    return count;
}

- (NSInteger)instancesOfAnswerInRow:(NSInteger)inputRow inColumn:(NSInteger)inputColumn forAnswer:(NSInteger)answer
{
    NSInteger count = 0;
    
    for (NSInteger column = 0; column < 9; column++) {
        if (column != inputColumn) {
            HMDSudokuCell *cell = self.internalSudokuBoard[inputRow][column];
            
            if ([cell.answer integerValue] == 0) {
                NSArray *possibleAnswers = [cell.possibleAnswers copy];

                for (HMDPossibleAnswer *possibleAnswer in possibleAnswers) {
                    if (possibleAnswer.answer == answer) {
                        count++;
                    }
                }
            }
        }
    }
    
    return count;
}

- (NSInteger)instancesOfAnswerInColumn:(NSInteger)inputColumn inRow:(NSInteger)inputRow forAnswer:(NSInteger)answer
{
    NSInteger count = 0;
    
    for (NSInteger row = 0; row < 9; row++) {
        if (row != inputRow) {
            HMDSudokuCell *cell = self.internalSudokuBoard[row][inputColumn];
            
            if ([cell.answer integerValue] == 0) {
                NSArray *possibleAnswers = [cell.possibleAnswers copy];

                for (HMDPossibleAnswer *possibleAnswer in possibleAnswers) {
                    if (possibleAnswer.answer == answer) {
                        count++;
                    }
                }
            }
        }
    }
    
    return count;
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
            
            for (NSInteger answer = 1; answer <= 9; answer++) {
                
                NSInteger occurenceCount = 0;
                NSInteger rowCoordinateOfOccurence = 0;
                NSInteger columnCoordinateOfOccurence = 0;
                
                for (NSInteger quadrantRow = 0; quadrantRow <= 2; quadrantRow++) {
                    for (NSInteger quadrantColumn = 0; quadrantColumn <= 2; quadrantColumn++) {
                        
                        HMDSudokuCell *cell = self.internalSudokuBoard[row + quadrantRow][column + quadrantColumn];
                        NSMutableArray *possibleAnswers = cell.possibleAnswers;
                        
                        for (HMDPossibleAnswer *possibleAnswer in possibleAnswers) {
                            if (possibleAnswer.answer == answer) {
                                occurenceCount++;
                                rowCoordinateOfOccurence = row + quadrantRow;
                                columnCoordinateOfOccurence = column + quadrantColumn;
                            }
                        }
                    }
                }
                
                if (occurenceCount == 1) {
                    HMDSudokuCell *cell = self.internalSudokuBoard[rowCoordinateOfOccurence][columnCoordinateOfOccurence];
                    cell.answer = [NSNumber numberWithInteger:answer];
                    [cell.possibleAnswers removeAllObjects];
                    changed = YES;

                    [self updatePossibleAnswers];
                }
            }
        }
    }
    
    return changed;
}

#pragma mark - Solving board

- (BOOL)isSolved
{
    for (NSInteger row = 0; row < 9; row++) {
        for (NSInteger column = 0; column < 9; column++) {
            
            HMDSudokuCell *cell = self.internalSudokuBoard[row][column];
            if ([cell.answer integerValue] == 0) return NO;
            
            if (![self checkValidPlacementOfAnswer:[cell.answer integerValue] inRow:row andColumn:column]) return NO;
            
        }
    }
    
    return YES;
}


- (void)resetBoard
{
    for (NSInteger row = 0; row < 9; row++) {
        for (NSInteger column = 0; column < 9; column++) {
            
            HMDSudokuCell *cell = self.internalSudokuBoardCopy[row][column];
            HMDSudokuCell *cellCopy = [cell copyWithZone:nil];
            
            self.internalSudokuBoard[row][column] = cellCopy;
        }
    }
}


- (void)solveBoard
{
    BOOL changed;
    static NSInteger loopCount = 0;
    
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
                    
                    HMDPossibleAnswer *possibleAnswer = [cell.possibleAnswers firstObject];
                    cell.answer = [NSNumber numberWithInteger:possibleAnswer.answer];
                    [cell.possibleAnswers removeAllObjects];
                    NSLog(@"cell.possibleAnswers after: %@", cell.possibleAnswers);

                    
                    [self updatePossibleAnswers];
                    
                    changed = YES;
                }
            }
        }
        
        if (changed == NO) changed = [self subGroupExclusionCheck];
        
        NSLog(changed ? @"Yes" : @"No");
        NSLog(@"Loop");
        loopCount++;
    } while (changed);

    
    NSLog(@"loopCount: %ld", (long)loopCount);
    
    if ([self isSolved]) {
        [self printBoard];
        return;
    }
    
    [self setupTree];
    
    for (NSInteger i = 0; i < [self.listOfCellsToGuess count]; i++) {
        NSLog(@"----------");
        HMDCellCoordinates *coordinates = self.listOfCellsToGuess[i];
        HMDSudokuCell *cell = self.internalSudokuBoard[coordinates.row][coordinates.column];
        
        NSArray *possibleAnswers = [cell.possibleAnswers copy];
        
        for (HMDPossibleAnswer *possibleAnswer in possibleAnswers) {
            NSLog(@"Number of instances of %ld: %ld", (long)possibleAnswer.answer, (long)[self instancesOfAnswerInRowColumnAndQuadrant:possibleAnswer.answer inRow:coordinates.row andColumn:coordinates.column]);
        }
        NSLog(@"treeLevel: %ld", (long)i);

        NSLog(@"----------");

    }
    
    [self treeTraverseGuess:self.sudokuTree.root];
}

- (void)sortListOfCellsToGuess
{
    for (NSInteger i = 0; i < [self.listOfCellsToGuess count] - 1; i++) {
        HMDCellCoordinates *coordinates = self.listOfCellsToGuess[i];
        HMDSudokuCell *cell = self.internalSudokuBoard[coordinates.row][coordinates.column];
        
        NSInteger min = [cell.possibleAnswers count];
        NSInteger minIndex = i;

        for (NSInteger j = i + 1; j < [self.listOfCellsToGuess count]; j++) {
            
            coordinates = self.listOfCellsToGuess[j];
            cell = self.internalSudokuBoard[coordinates.row][coordinates.column];
            
            if (min > [cell.possibleAnswers count]) {
                min = [cell.possibleAnswers count];
                minIndex = j;
            }
            
        }
        HMDCellCoordinates *temp = self.listOfCellsToGuess[i];
        
        self.listOfCellsToGuess[i] = self.listOfCellsToGuess[minIndex];
        self.listOfCellsToGuess[minIndex] = temp;
        
    }
}

- (void)setupTree
{
    if (!self.listOfCellsToGuess) {
        
        self.listOfCellsToGuess = [[NSMutableArray alloc] init];
        
        for (NSInteger row = 0; row < 9; row++) {
            for (NSInteger column = 0; column < 9; column++) {
                
                HMDSudokuCell *cell = self.internalSudokuBoard[row][column];
                
                if ([cell.answer integerValue] == 0) {
                    HMDCellCoordinates *coordinates = [[HMDCellCoordinates alloc] initWithRowCoordinates:row column:column];
                    [self.listOfCellsToGuess addObject:coordinates];
                    
                }
            }
        }
    }
    
    //[self sortListOfCellsToGuess];
    

    
    self.sudokuTree = [[HMDSudokuTree alloc] init];
    HMDSudokuTreeNode *root = [[HMDSudokuTreeNode alloc] init];
    root.parent = nil;
    root.treeLevel = -1;
    
    self.sudokuTree.root = root;
    

}

- (void)evaluateOptimalPossibleAnswerPathForCell:(HMDSudokuCell *)cell
{
    NSArray *possibleAnswers = [cell.possibleAnswers copy];
    
    for (NSInteger i = 0; i < [possibleAnswers count]; i++) {
        
    }
}

- (HMDSudokuTreeNode *)getNextParentNodeWithSibling:(HMDSudokuTreeNode *)parent
{
    while (!parent.nextSibling) {
        parent = parent.parent;
    }
    
    return parent;
}

- (void)treeTraverseGuess:(HMDSudokuTreeNode *)root
{
    HMDSudokuTreeNode *parent = root;
    HMDSudokuTreeNode *nextSibling;
    NSInteger iterationCount = 0;
    
    while ((signed long)parent.treeLevel < (signed long)[self.listOfCellsToGuess count] - 1) {
        iterationCount++;
        
        HMDCellCoordinates *coordinates = self.listOfCellsToGuess[parent.treeLevel + 1];
        
        HMDSudokuCell *cell = self.internalSudokuBoard[coordinates.row][coordinates.column];
        NSArray *possibleAnswers = [cell.possibleAnswers copy];
        
        if ([possibleAnswers count] == 0) {
            HMDCellCoordinates *parentCoordinates = self.listOfCellsToGuess[parent.treeLevel];
            HMDSudokuCell *parentCell = self.internalSudokuBoard[parentCoordinates.row][parentCoordinates.column];
            
            if (parent.nextSibling) {
                NSLog(@"Encountered empty possible answers in treeLevel %ld, moving to sibling", (long)(parent.treeLevel + 1));

                parent.parent.firstChild = parent.nextSibling;
                parent = parent.nextSibling;
                parentCell.answer = [parent.answer copy];
                
                NSLog(@"New answer: %@ for treeLevel %ld", parentCell.answer, (long)parent.treeLevel);
                [self restorePossibleAnswersForCellsToGuess];
                [self updatePossibleAnswersForCellsToGuess];
                
                possibleAnswers = [cell.possibleAnswers copy];
                
                NSLog(@"--------------------------");
                NSLog(@"current treeLevel: %ld", (long)parent.treeLevel + 1);
                NSLog(@"possible answers for treeLevel:");
                for (NSInteger i = 0; i < [possibleAnswers count]; i++) {
                    HMDPossibleAnswer *pa = possibleAnswers[i];
                    NSLog(@"%ld", (long)pa.answer);
                }
                NSLog(@"--------------------------");

                
            } else {
                NSLog(@"Encountered empty possible answers in treeLevel %ld, searching for next higher parent with sibling", (long)(parent.treeLevel + 1));

                NSInteger previousTreeLevel = parent.treeLevel;
                
                parent = [self getNextParentNodeWithSibling:parent];
                NSLog(@"Coordinates of next parent with sibling, row: %ld, column: %ld", (long)parent.coordinates.row, (long)parent.coordinates.column);
                NSInteger newTreeLevel = parent.treeLevel;
                
                parent.parent.firstChild = parent.nextSibling;
                parent = parent.nextSibling;
                
                
                for (NSInteger level = previousTreeLevel; level > newTreeLevel; level--) {
                    HMDCellCoordinates *coordinatesForCellToReset = self.listOfCellsToGuess[level];
                    HMDSudokuCell *cellToReset = self.internalSudokuBoard[coordinatesForCellToReset.row][coordinatesForCellToReset.column];
                    
                    cellToReset.answer = @0;
                }
                
                parentCoordinates = self.listOfCellsToGuess[newTreeLevel];
                parentCell = self.internalSudokuBoard[parentCoordinates.row][parentCoordinates.column];
                
                parentCell.answer = [parent.answer copy];
                NSLog(@"New answer: %@ for treeLevel: %ld", parentCell.answer, (long)newTreeLevel);

                [self restorePossibleAnswersForCellsToGuess];
                [self updatePossibleAnswersForCellsToGuess];
                
                NSLog(@"--------------------------");

                for (NSInteger level = newTreeLevel + 1; level <= previousTreeLevel; level++) {
                    HMDCellCoordinates *coordinatesForCellToReset = self.listOfCellsToGuess[level];
                    HMDSudokuCell *cellToReset = self.internalSudokuBoard[coordinatesForCellToReset.row][coordinatesForCellToReset.column];
                    
                    NSLog(@"Cell row: %ld, column: %ld", (long)coordinatesForCellToReset.row, (long)coordinatesForCellToReset.column);
                    NSLog(@"possible answers:");
                    for (HMDPossibleAnswer *possibleAnswer in cellToReset.possibleAnswers) {
                        NSLog(@"%ld", (long)possibleAnswer.answer);
                    }
                    NSLog(@"\n");
                }
                
                NSLog(@"--------------------------");

                continue;
                
                //break;
            }
            
        }
        
        for (NSInteger i = [possibleAnswers count] - 1; i >= 0; i--) {
            HMDPossibleAnswer *possibleAnswer = possibleAnswers[i];
            HMDSudokuTreeNode *child = [[HMDSudokuTreeNode alloc] init];
            
            child.answer = [NSNumber numberWithInteger:possibleAnswer.answer];
            child.parent = parent;

            child.treeLevel = parent.treeLevel + 1;
            
            HMDCellCoordinates *childCoordinates = self.listOfCellsToGuess[child.treeLevel];
            child.coordinates = childCoordinates;
        
        
            if (i == 0) {
                parent.firstChild = child;
                child.nextSibling = nextSibling;
                nextSibling = nil;
                
                cell.answer = [NSNumber numberWithInteger:possibleAnswer.answer];
                [cell.possibleAnswers removeAllObjects];
                
                parent = child;
                NSLog(@"Selected answer:");
                
            } else {
                if (nextSibling) {
                    child.nextSibling = nextSibling;
                } else {
                    child.nextSibling = nil;
                }
                
                nextSibling = child;
            }
            
            NSLog(@"Node: %@", [child.answer stringValue]);
            

        }
        [self updatePossibleAnswers];
        
        NSLog(@"\n");
        NSLog(@"Tree Level %ld", (long)parent.treeLevel);
        NSLog(@"--");
        NSLog(@"\n");
        NSLog(@"\n");
        NSLog(@"\n");
        NSLog(@"--");

    }
    
    if ([self isSolved]) {
        NSLog(@"SOLVED!!");
        NSLog(@"Iteration count: %ld", (long)iterationCount);
        self.sudokuTree.root.firstChild = nil;
    }

    
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
    
    HMDSolutionViewController *solutionViewController = [[HMDSolutionViewController alloc] initWithSolution:[solution copy] andOriginalBoard:[self.originalBoard copy]];
    [self presentViewController:solutionViewController animated:YES completion:nil];
}


- (IBAction)solveButton:(id)sender
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Solving..";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self setupInternalSudokuBoard:self.startingNumbers];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self printBoard];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
    

}


@end
