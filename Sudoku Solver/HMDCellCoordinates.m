//
//  HMDCellCoordinates.m
//  Sudoku Solver
//
//  Created by Trent You on 2/1/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

#import "HMDCellCoordinates.h"

@implementation HMDCellCoordinates

- (instancetype)initWithRowCoordinates:(NSInteger)row column:(NSInteger)column
{
    self = [super init];
    
    if (self) {
        _row = row;
        _column = column;
    }
    
    return self;
}

- (instancetype)init
{
    return [self initWithRowCoordinates:0 column:0];
}



@end
