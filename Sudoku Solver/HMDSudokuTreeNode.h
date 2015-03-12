//
//  HMDSudokuTreeNode.h
//  Sudoku Solver
//
//  Created by Trent You on 1/31/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMDCellCoordinates.h"

@interface HMDSudokuTreeNode : NSObject

//@property (nonatomic, strong) NSNumber *answer;
@property (nonatomic) NSInteger answer;

@property (nonatomic, weak) HMDSudokuTreeNode *parent;
@property (nonatomic, strong) HMDSudokuTreeNode *firstChild;
@property (nonatomic, strong) HMDSudokuTreeNode *nextSibling;

@property (nonatomic, strong) HMDCellCoordinates *coordinates;

@property (nonatomic) NSUInteger treeLevel;

@end
