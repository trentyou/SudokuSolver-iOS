//
//  HMDMainMenuViewController.h
//  Sudoku Solver
//
//  Created by Trent You on 3/17/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const float ACTION_BUTTON_NORMAL;
extern const float ACTION_BUTTON_HIGHLIGHTED;

typedef NS_ENUM(NSInteger, TreeSolverDirection) {
    Forward,
    Backward
};

@interface HMDMainMenuViewController : UIViewController

@end
