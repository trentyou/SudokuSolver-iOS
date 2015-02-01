//
//  HMDSudokuTreeNode.h
//  Sudoku Solver
//
//  Created by Trent You on 1/31/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMDSudokuTreeNode : NSObject

@property NSMutableArray *item;
@property HMDSudokuTreeNode *parent;
@property HMDSudokuTreeNode *firstChild;
@property HMDSudokuTreeNode *nextSibling;


@end
