//
//  HMDSudokuCell.m
//  Sudoku Solver
//
//  Created by Trent You on 1/27/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

#import "HMDSudokuCell.h"

@implementation HMDSudokuCell


- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.answer forKey:@"self.answer"];
    [coder encodeObject:self.possibleAnswers forKey:@"self.possibleAnswers"];
    
}




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

- (instancetype)copyWithZone:(NSZone *)zone
{
    HMDSudokuCell *copy = [[HMDSudokuCell allocWithZone:zone] init];
    copy.answer = [self.answer copy];
    copy.possibleAnswers = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.possibleAnswers]];
    
    return copy;
}



@end
