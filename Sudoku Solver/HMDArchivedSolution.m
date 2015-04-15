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
    [aCoder encodeObject:self.solveDate forKey:@"solveDate"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        _solutionString = [aDecoder decodeObjectForKey:@"solutionString"];
        _solveDate = [aDecoder decodeObjectForKey:@"solveDate"];
    }
    
    return self;
}

- (instancetype)initWithSolution:(NSString *)solution
{
    self = [super init];
    
    if (self) {
        _solutionString = solution;
        _solveDate = [NSDate date];
    }
    
    return self;
}

@end
