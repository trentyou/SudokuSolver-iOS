//
//  HMDSolutionViewController.h
//  Sudoku Solver
//
//  Created by Trent You on 1/26/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HMDSolutionViewController : UIViewController

- (instancetype)initWithSolution:(NSArray *)solution originalBoard:(NSArray *)originalBoard andTimeToSolve:(double)timeToSolve;



@end
