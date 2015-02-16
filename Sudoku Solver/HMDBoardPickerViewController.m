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
#import "MBProgressHUD.h"


@interface HMDBoardPickerViewController ()

@property (nonatomic, strong) NSMutableArray *internalSudokuBoard;
@property (nonatomic, strong) NSMutableArray *internalSudokuBoardCopy;

@property (nonatomic, strong) NSMutableArray *listOfCellsToGuess;


@property (nonatomic, strong) HMDSudokuTree *sudokuTree;

@property (nonatomic, copy) NSString *startingNumbers;

@end

@implementation HMDBoardPickerViewController

static NSInteger treeLevel;
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
    self.startingNumbers = @"000670050080000009070980100052403800000000000003507690005039010300000080010052000";
}

#pragma mark - Initial board setup

- (void)setupInternalSudokuBoard:(NSString *)startingNumbers
{
    if (!self.internalSudokuBoard) self.internalSudokuBoard = [[NSMutableArray alloc] init];
    
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
                        [possibleAnswers addObject:[NSNumber numberWithInteger:number]];
                    }
                }
                
                cell.possibleAnswers = possibleAnswers;
                NSLog(@"Row: %ld", (long) row);
                NSLog(@"Column: %ld", (long) column);
                NSLog(@"%@", cell.possibleAnswers);
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
                
                for (NSNumber *possibleAnswer in possibleAnswers) {
                    
                    if (![self checkValidPlacementOfAnswer:[possibleAnswer integerValue] inRow:row andColumn:column]) {
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
            
            for (NSNumber *possibleAnswer in possibleAnswers) {
                
                if (![self checkValidPlacementOfAnswer:[possibleAnswer integerValue] inRow:coordinates.row andColumn:coordinates.column]) {
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
                    [possibleAnswers addObject:[NSNumber numberWithInteger:number]];
                }
            }
            
            cell.possibleAnswers = possibleAnswers;
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

- (void)setupBoardCopy
{
    self.internalSudokuBoardCopy = [[NSMutableArray alloc] init];
        
    for (NSInteger row = 0; row < 9; row++) {
        NSMutableArray *column = [[NSMutableArray alloc] init];
        [self.internalSudokuBoardCopy insertObject:column atIndex:row];
    }
    
    for (NSInteger row = 0; row < 9; row++) {
        for (NSInteger column = 0; column < 9; column++) {
            
            HMDSudokuCell *cell = self.internalSudokuBoard[row][column];
            HMDSudokuCell *cellCopy = [cell copyWithZone:nil];
            
            self.internalSudokuBoardCopy[row][column] = cellCopy;
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
                    
                    cell.answer = [cell.possibleAnswers firstObject];
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
    
    if (!self.internalSudokuBoardCopy) {
        [self setupBoardCopy];
    }
    
    //[self setupTree];
    
    //[self treeTraverseGuess:self.sudokuTree.root];
    [self printBoard];

    // Check board copy if it is really a deep copy
    
    /*
    NSLog(@"After solving: ");
    
    HMDSudokuCell *cell = self.internalSudokuBoard[0][0];
    cell.answer = [NSNumber numberWithInteger:20];
    
    cell = self.internalSudokuBoard[8][8];
    cell.answer = [NSNumber numberWithInteger:40];
    
    NSLog(@"self.internalSudokuBoard:");
    
    for (NSInteger row = 0; row < 9; row++) {
        for (NSInteger column = 0; column < 9; column++) {
            HMDSudokuCell *cell = self.internalSudokuBoard[row][column];
            NSLog(@"Row: %ld", row);
            NSLog(@"Column: %ld", column);
            
            NSLog(@"Answer: %ld", [cell.answer integerValue]);
        }
    }
    
    
    NSLog(@"self.internalSudokuBoardCopy:");
    
    for (NSInteger row = 0; row < 9; row++) {
        for (NSInteger column = 0; column < 9; column++) {
            HMDSudokuCell *cell = self.internalSudokuBoardCopy[row][column];
            NSLog(@"Row: %ld", row);
            NSLog(@"Column: %ld", column);
            
            NSLog(@"Answer: %ld", [cell.answer integerValue]);
        }
    }
     */
    
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
    
    self.sudokuTree = [[HMDSudokuTree alloc] init];
    HMDSudokuTreeNode *root = [[HMDSudokuTreeNode alloc] init];
    root.parent = nil;
    root.treeLevel = -1;
    
    self.sudokuTree.root = root;
    

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
    
    while (YES) {
        
        if ((signed long)parent.treeLevel >= (signed long)[self.listOfCellsToGuess count] - 1) {
            break;
        }
        
        HMDCellCoordinates *coordinates = self.listOfCellsToGuess[parent.treeLevel + 1];
        
        HMDSudokuCell *cell = self.internalSudokuBoard[coordinates.row][coordinates.column];
        NSArray *possibleAnswers = [cell.possibleAnswers copy];
        
        if ([possibleAnswers count] == 0) {
            NSLog(@"Encountered empty possible answers");
            HMDCellCoordinates *parentCoordinates = self.listOfCellsToGuess[parent.treeLevel];
            HMDSudokuCell *parentCell = self.internalSudokuBoard[parentCoordinates.row][parentCoordinates.column];
            
            if (parent.nextSibling) {
                
                parent.parent.firstChild = parent.nextSibling;
                parent = parent.nextSibling;
                parentCell.answer = [parent.answer copy];
                
                [self restorePossibleAnswersForCellsToGuess];
                [self updatePossibleAnswersForCellsToGuess];
                
                possibleAnswers = [cell.possibleAnswers copy];
                
                NSLog(@"--------------------------");
                NSLog(@"current treeLevel: %ld", (long)parent.treeLevel + 1);
                NSLog(@"possible answers for treeLevel: %@", possibleAnswers);
                NSLog(@"--------------------------");

                
            } else {
                NSInteger previousTreeLevel = parent.treeLevel;
                
                parent = [self getNextParentNodeWithSibling:parent];
                NSLog(@"Next parent with sibling: %@", parent.answer);
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
                
                [self restorePossibleAnswersForCellsToGuess];
                [self updatePossibleAnswersForCellsToGuess];
                
                NSLog(@"--------------------------");

                for (NSInteger level = newTreeLevel; level <= previousTreeLevel; level++) {
                    HMDCellCoordinates *coordinatesForCellToReset = self.listOfCellsToGuess[level];
                    HMDSudokuCell *cellToReset = self.internalSudokuBoard[coordinatesForCellToReset.row][coordinatesForCellToReset.column];
                    
                    NSLog(@"Cell row: %ld, column: %ld", (long)coordinatesForCellToReset.row, (long)coordinatesForCellToReset.column);
                    NSLog(@"possible answers: %@", cellToReset.possibleAnswers);
                    
                }
                
                NSLog(@"--------------------------");

                continue;
                
                //break;
            }
            
        }
        
        
        for (NSInteger i = [possibleAnswers count] - 1; i >= 0; i--) {
            NSNumber *possibleAnswer = possibleAnswers[i];
            HMDSudokuTreeNode *child = [[HMDSudokuTreeNode alloc] init];
            
            child.answer = possibleAnswer;
            child.parent = parent;

            child.treeLevel = parent.treeLevel + 1;
            
            HMDCellCoordinates *childCoordinates = self.listOfCellsToGuess[child.treeLevel];
            child.coordinates = childCoordinates;
        
        
            if (i == 0) {
                parent.firstChild = child;
                child.nextSibling = nextSibling;
                nextSibling = nil;
                
                cell.answer = possibleAnswer;
                [cell.possibleAnswers removeAllObjects];
                
                parent = child;
                
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
        NSLog(@"Tree Level %ld", (long)parent.treeLevel + 1);
        NSLog(@"\n");

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
    
    HMDSolutionViewController *solutionViewController = [[HMDSolutionViewController alloc] initWithSolution:[solution copy]];
    [self presentViewController:solutionViewController animated:YES completion:nil];
}


- (IBAction)solveButton:(id)sender
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Solving..";
    
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self setupInternalSudokuBoard:self.startingNumbers];

    });
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];

}











//HMDSudokuTreeNode *parent;
//HMDSudokuTreeNode *nextSibling;
//
//if (treeLevel == 0) {
//    parent = root;
//}
//
//HMDCellCoordinates *coordinates = self.listOfCellsToGuess[treeLevel];
//HMDSudokuCell *cell = self.internalSudokuBoard[coordinates.row][coordinates.column];
//NSArray *possibleAnswers = [cell.possibleAnswers copy];
//
//if ([possibleAnswers count] == 0) {
//    NSLog(@"Encountered empty possible answers");
//    treeLevel--;
//    coordinates = self.listOfCellsToGuess[treeLevel];
//    cell = self.internalSudokuBoard[coordinates.row][coordinates.column];
//    cell.answer = @0;
//    [self updatePossibleAnswers];
//    parent.parent.firstChild = parent.nextSibling;
//    
//    break;
//}
//
//
//
//NSLog(@"\n");
//NSLog(@"Tree Level %ld", (long) (treeLevel + 1));
//NSLog(@"\n");
//
//
//[self updatePossibleAnswers];
//treeLevel++;















@end
