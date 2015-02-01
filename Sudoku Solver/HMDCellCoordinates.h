//
//  HMDCellCoordinates.h
//  Sudoku Solver
//
//  Created by Trent You on 2/1/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMDCellCoordinates : NSObject

@property (nonatomic) NSInteger row;
@property (nonatomic) NSInteger column;


- (instancetype)initWithRowCoordinates:(NSInteger)row column:(NSInteger)column;

@end
