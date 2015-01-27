//
//  HMDSudokuCell.m
//  Sudoku Solver
//
//  Created by Trent You on 1/27/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

#import "HMDSudokuCell.h"

@implementation HMDSudokuCell

- (instancetype)initWithAnswer:(NSNumber *)answer possibleAnswers:(NSArray *)possibleAnswers
{
    self = [super init];
    
    if (self) {
        if (answer) _answer = answer;
        if (possibleAnswers) _possibleAnswers = [[NSMutableArray alloc] initWithArray:possibleAnswers];
    }
    
    return self;
}

- (instancetype)init
{
    return [self initWithAnswer:0 possibleAnswers:@[]];
}




@end
