//
//  HMDSolutionViewController.h
//  Sudoku Solver
//
//  Created by Trent You on 1/26/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMDSwiftSolution.h"

@interface HMDSolutionViewController : UIViewController

- (instancetype)initWithArraySolution:(NSArray *)solution andTimeToSolve:(double)timeToSolve;
- (instancetype)initWithStringSolution:(HMDSwiftSolution *)solution andTimeToSolve:(double)timeToSolve;


@end
