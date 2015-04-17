//
//  HMDSolutionArchiveStore.h
//  Sudoku Solver
//
//  Created by Trent You on 4/15/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMDSolutionArchiveStore : NSObject

+ (instancetype)sharedStore;


- (void)archiveSolution:(NSString *)solution andInitialBoard:(NSString *)initialBoard;

- (NSArray *)solutionList;


@end
