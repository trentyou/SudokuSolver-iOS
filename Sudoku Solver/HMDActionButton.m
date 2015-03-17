//
//  HMDActionButton.m
//  Sudoku Solver
//
//  Created by Trent You on 3/17/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

#import "HMDActionButton.h"
#import "HMDMainMenuViewController.h"

#import "UIColor+_SudokuSolver.h"

@implementation HMDActionButton

+ (instancetype)buttonWithType:(UIButtonType)buttonType
{
    HMDActionButton *button = [super buttonWithType:buttonType];
    
    return button;
}

- (void)setHighlighted:(BOOL)highlighted
{
    if (highlighted) {
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:ACTION_BUTTON_HIGHLIGHTED];
    } else {
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:ACTION_BUTTON_NORMAL];
    }
}
@end
