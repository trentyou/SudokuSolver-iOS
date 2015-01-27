//
//  HMDSudokuCell.h
//  Sudoku Solver
//
//  Created by Trent You on 1/27/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMDSudokuCell : NSObject

@property (nonatomic, strong) NSNumber *answer;
@property (nonatomic, copy) NSMutableArray *possibleAnswers;

- (instancetype)initWithAnswer:(NSNumber *)answer possibleAnswers:(NSArray *)possibleAnswers;

@end
