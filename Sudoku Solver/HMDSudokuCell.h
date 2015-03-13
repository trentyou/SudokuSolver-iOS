//
//  HMDSudokuCell.h
//  Sudoku Solver
//
//  Created by Trent You on 1/27/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMDSudokuCell : NSObject <NSCopying>

//@property (nonatomic, strong) NSNumber *answer;
@property (nonatomic) NSInteger answer;
@property (nonatomic, strong) NSMutableArray *possibleAnswers;
@property (nonatomic, strong) NSMutableArray *initialPossibleAnswers;
@property (nonatomic) BOOL isPartOfInitialBoard;

- (instancetype)initWithAnswer:(NSInteger)answer possibleAnswers:(NSArray *)possibleAnswers;
- (instancetype)copyWithZone:(NSZone *)zone;

@end
