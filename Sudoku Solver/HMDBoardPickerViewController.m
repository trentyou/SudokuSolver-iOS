//
//  HMDBoardPickerViewController.m
//  Sudoku Solver
//
//  Created by Trent You on 1/26/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

#import "HMDBoardPickerViewController.h"
#import "HMDSolutionViewController.h"

@interface HMDBoardPickerViewController ()

@property (nonatomic, strong) NSMutableArray *internalSudokuBoard;
@property (nonatomic, copy) NSString *startingNumbers;

@end

@implementation HMDBoardPickerViewController

static NSNumberFormatter *numberFormatter;

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!numberFormatter) numberFormatter = [[NSNumberFormatter alloc] init];
    
    self.startingNumbers = @"000260701680070090190004500820100040004602900050003028009300074040050036703018000";
    
    [self setupInternalSudokuBoard:self.startingNumbers];
}


- (void)setupInternalSudokuBoard:(NSString *)startingNumbers
{
    self.internalSudokuBoard = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 9; i++) {
        NSMutableArray *column = [[NSMutableArray alloc] init];
        [self.internalSudokuBoard insertObject:column atIndex:i];
    }
    
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            [self.internalSudokuBoard[i] insertObject:[numberFormatter numberFromString:[startingNumbers substringToIndex:1]] atIndex:j];
            startingNumbers = [startingNumbers substringFromIndex:1];
        }
    }
    
}



- (void)printBoard:(NSString *)solutionString
{
    HMDSolutionViewController *solutionViewController = [[HMDSolutionViewController alloc] initWithSolution:solutionString];
    [self presentViewController:solutionViewController animated:YES completion:nil];
}


- (IBAction)solveButton:(id)sender
{
    [self printBoard:self.startingNumbers];
}









































@end
