//
//  HMDArchivedSolution.m
//  Sudoku Solver
//
//  Created by Trent You on 4/15/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

#import "HMDArchivedSolution.h"

@implementation HMDArchivedSolution

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.solutionString forKey:@"solutionString"];
    [aCoder encodeObject:self.initialBoardString forKey:@"initialBoardString"];
    [aCoder encodeObject:self.solveDate forKey:@"solveDate"];
    [aCoder encodeInteger:self.puzzleOrder forKey:@"puzzleOrder"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        _solutionString = [aDecoder decodeObjectForKey:@"solutionString"];
        _initialBoardString = [aDecoder decodeObjectForKey:@"initialBoardString"];
        _solveDate = [aDecoder decodeObjectForKey:@"solveDate"];
        _puzzleOrder = [aDecoder decodeIntegerForKey:@"puzzleOrder"];
    }
    
    return self;
}

- (instancetype)initWithSolution:(NSString *)solution andInitialBoardString:(NSString *)initialBoardString
{
    self = [super init];
    
    if (self) {
        _solutionString = solution;
        _initialBoardString = initialBoardString;
        _solveDate = [NSDate date];
    }
    
    return self;
}

@end
