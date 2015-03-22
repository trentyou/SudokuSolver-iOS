//
//  HMDSolver.h
//  Sudoku Solver
//
//  Created by Trent You on 3/7/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMDSolver : NSObject

- (NSArray *)solvePuzzleWithStartingNumbers:(NSMutableArray *)startingNumbers andDirection:(TreeSolverDirection)direction;



@end
