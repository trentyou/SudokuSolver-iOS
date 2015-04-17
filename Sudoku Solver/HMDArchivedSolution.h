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
@property (nonatomic, copy) NSString *initialBoardString;

@property (nonatomic, strong) NSDate *solveDate;
@property (nonatomic) NSInteger puzzleOrder;


- (instancetype)initWithSolution:(NSString *)solution andInitialBoardString:(NSString *)initialBoardString;

@end
