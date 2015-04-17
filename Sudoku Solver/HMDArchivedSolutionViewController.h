//
//  HMDArchivedSolutionViewController.h
//  Sudoku Solver
//
//  Created by Trent You on 4/15/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMDArchivedSolution.h"

@protocol HMDArchivedSolutionViewControllerDelegate <NSObject>

- (void)viewControllerWithOrderWasSelected:(NSInteger)order;

@end

@interface HMDArchivedSolutionViewController : UIViewController

@property (nonatomic, weak) id<HMDArchivedSolutionViewControllerDelegate> delegate;

- (instancetype)initWithArchivedSolution:(HMDArchivedSolution *)archivedSolution;



@end
