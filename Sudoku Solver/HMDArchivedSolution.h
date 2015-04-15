//
//  HMDArchivedSolution.h
//  Sudoku Solver
//
//  Created by Trent You on 4/15/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMDArchivedSolution : NSObject <NSCoding>

@property (nonatomic, copy) NSString *solutionString;
@property (nonatomic, strong) NSDate *solveDate;


- (instancetype)initWithSolution:(NSString *)solution;

@end
