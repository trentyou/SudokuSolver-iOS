//
//  HMDSudokuCell.h
//  Sudoku Solver
//
//  Created by Trent You on 1/27/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMDSudokuCell : NSObject <NSCopying>

@property (nonatomic, strong) NSNumber *answer;
@property (nonatomic, strong) NSMutableArray *possibleAnswers;

- (instancetype)initWithAnswer:(NSNumber *)answer possibleAnswers:(NSArray *)possibleAnswers;
- (instancetype)copyWithZone:(NSZone *)zone;

@end
